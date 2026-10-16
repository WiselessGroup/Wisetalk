// Channel chats: history loaded when a chat is opened, then kept current
// from gateway events. The same protocol as the web client's
// lib/chat.svelte.ts.
//
// Chats are end-to-end encrypted with one key per chat (ChatKey in
// wisetalk-core). The server keeps that key sealed for every device the
// channel admits; a device it wasn't sealed for asks for it and someone
// online who holds it seals it over. When nobody online can, the asking
// device starts a new key: what came before stays unreadable for it, the
// rest of the chat carries on.
//
// Pictures are encrypted with the same key, uploaded, and then sent as part
// of a message. They are fetched and decrypted when they come into view.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../src/rust/api/chat.dart';
import '../src/rust/api/picture.dart';
import '../src/rust/api/text.dart';
import 'api.dart';
import 'device.dart';
import 'gateway.dart';
import 'protocol.dart';
import 'trust.dart';

/// One chat as this device knows it.
class ChatRoom {
  List<ChatMessage> messages = [];

  /// When the chat clears itself; `null` while it's empty.
  DateTime? expiresAt;
  bool loaded = false;

  /// The key new messages use.
  String? key;
}

/// Something typed (and maybe a picture) waiting for the chat key.
typedef _Outgoing = ({String body, Picture? picture});

/// How long a key request may go unanswered before starting a new key.
const _requestTimeout = Duration(seconds: 8);

class Chats extends ChangeNotifier {
  Chats(this.gateway, this.device, {required this.account, this.trust}) {
    _subscription = gateway.events.listen(_apply);
  }

  final Gateway gateway;
  final LocalDevice device;

  /// Our account id; `null` for guests.
  final String? account;

  /// Device keys remembered here, to warn about devices added to our
  /// account before sealing a chat key for them (WLK-37); none in tests.
  final KeyWatch? trust;

  /// The chat on screen, if any.
  String? open;

  /// Every chat opened since signing in: the ones we follow.
  final Set<String> opened = {};
  final Map<String, ChatRoom> _rooms = {};
  final Map<String, int> unread = {};

  /// Chats whose current key this device is still waiting for.
  final Set<String> waiting = {};

  /// Pictures on their way up, per chat.
  final Map<String, int> uploading = {};
  String? error;

  /// Decrypted pictures by image id; `null` for one that didn't load.
  final Map<String, Uint8List?> pictures = {};

  late final StreamSubscription<GatewayEvent> _subscription;
  final _incoming = StreamController<ChatMessage>.broadcast();
  final Map<String, Map<String, ChatKey>> _keys = {};

  /// Messages written before the key was there, sent once it is.
  final Map<String, List<_Outgoing>> _outbox = {};

  /// Messages go out one after another, pictures included, in order.
  Future<void> _delivering = Future.value();

  /// Pictures being fetched, so each is fetched once.
  final Set<String> _fetching = {};

  /// The key operation in flight, so a `chat_key` error finds its chat.
  ({String channel, bool request})? _working;
  Timer? _timer;
  bool _disposed = false;

  Api get _api => gateway.session.api;

  ChatRoom room(String channel) => _rooms[channel] ?? ChatRoom();

  /// Every message as it arrives, already decrypted if it can be, ours too.
  Stream<ChatMessage> get incoming => _incoming.stream;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    _incoming.close();
    _timer?.cancel();
    for (final ring in _keys.values) {
      for (final key in ring.values) {
        key.dispose();
      }
    }
    _keys.clear();
    super.dispose();
  }

  Future<void> show(String channel) async {
    open = channel;
    opened.add(channel);
    unread[channel] = 0;
    notifyListeners();
    if (!(_rooms[channel]?.loaded ?? false)) await _load(channel);
    // Reading needs the key too: ask for it, but don't start a new one just
    // to read.
    final room = _rooms[channel];
    if (room?.key != null && _currentKey(channel) == null && _working == null) {
      waiting.add(channel);
      _requestKey(channel);
      notifyListeners();
    }
  }

  void hide() {
    open = null;
    notifyListeners();
  }

  /// Encrypts and sends; waits for the chat key first if this device lacks
  /// it. With a picture the text may be empty.
  void send(String channel, String raw, {Picture? picture}) {
    final body = raw.trim().isNotEmpty || picture == null
        ? normalizeChatBody(raw: raw)
        : '';
    if (body == null || (body.isEmpty && picture == null)) {
      error = 'A message is 1 to 2000 characters, without control characters.';
      notifyListeners();
      return;
    }
    (_outbox[channel] ??= []).add((body: body, picture: picture));
    unawaited(_flush(channel));
  }

  /// Shows [message] as the chat's error.
  void report(String message) {
    error = message;
    notifyListeners();
  }

  void remove(String channel, String message) {
    gateway.send('delete_message', {'channel': channel, 'message': message});
  }

  /// Fetches and decrypts a message's picture, once its key is here.
  Future<void> picture(ChatMessage message) async {
    final image = message.image;
    if (image == null ||
        pictures.containsKey(image.id) ||
        _fetching.contains(image.id)) {
      return;
    }
    final key = _keys[message.channel]?[message.key];
    if (key == null) return;
    _fetching.add(image.id);
    try {
      final sealed = await _api.downloadChatImage(message.channel, image.id);
      pictures[image.id] = await key.openImage(
        channel: message.channel,
        author: message.author,
        image: jsonEncode(image.json),
        ciphertext: sealed,
      );
    } catch (e) {
      debugPrint('a chat picture did not load: $e');
      pictures[image.id] = null;
    } finally {
      _fetching.remove(image.id);
      notifyListeners();
    }
  }

  void _forget(ChatImage? image) {
    if (image != null) pictures.remove(image.id);
  }

  Future<void> _load(String channel) async {
    try {
      final history = await _api.chatHistory(channel, device.id);
      for (final grant in history.keys) {
        _accept(grant);
      }
      // Messages that arrived while loading stay; history fills in first.
      final live = _rooms[channel]?.messages ?? const <ChatMessage>[];
      final known = {for (final m in history.messages) m.id};
      _rooms[channel] = ChatRoom()
        ..messages = [
          for (final m in history.messages) _reveal(m),
          for (final m in live)
            if (!known.contains(m.id)) m,
        ]
        ..expiresAt = history.expiresAt
        ..loaded = true
        ..key = history.key;
    } on ApiException catch (e) {
      error = e.message;
    }
    notifyListeners();
  }

  ChatMessage _reveal(ChatMessage message) {
    final key = _keys[message.channel]?[message.key];
    if (key != null && message.text == null) {
      try {
        message.text = key.decrypt(
          channel: message.channel,
          author: message.author,
          sealed: jsonEncode(message.sealed),
        );
      } catch (e) {
        debugPrint('a chat message did not decrypt: $e');
      }
    }
    return message;
  }

  /// Opens a key sealed for this device and decrypts what was waiting for it.
  String? _accept(ChatKeyGrant grant) {
    final ring = _keys[grant.channel] ??= {};
    if (!ring.containsKey(grant.key)) {
      try {
        ring[grant.key] = ChatKey.open(
          envelope: jsonEncode(grant.envelope),
          recipient: device.keys,
          senderPublicKey: grant.from.publicKey,
        );
      } catch (e) {
        debugPrint('rejected a chat key envelope: $e');
        return null;
      }
    }
    for (final m in _rooms[grant.channel]?.messages ?? const <ChatMessage>[]) {
      if (m.text == null && m.key == grant.key) _reveal(m);
    }
    return grant.key;
  }

  ChatKey? _currentKey(String channel) {
    final id = _rooms[channel]?.key;
    return id == null ? null : _keys[channel]?[id];
  }

  /// Sends what is queued, or works on getting the key first.
  Future<void> _flush(String channel) async {
    if (!(_rooms[channel]?.loaded ?? false)) await _load(channel);
    final room = _rooms[channel];
    if (room == null) return;
    final key = _currentKey(channel);
    if (key != null) {
      waiting.remove(channel);
      final messages = [...?_outbox[channel]];
      _outbox[channel]?.clear();
      if (messages.isNotEmpty) {
        _delivering = _delivering
            .then((_) => _deliver(channel, key, messages))
            // A chat cleared meanwhile drops its key: keep the queue going.
            .catchError((Object e) => debugPrint('chat messages lost: $e'));
      }
      notifyListeners();
      return;
    }
    if (_working?.channel == channel) return;
    waiting.add(channel);
    notifyListeners();
    if (room.key == null) {
      await _createKey(channel, null);
    } else {
      _requestKey(channel);
    }
  }

  Future<void> _deliver(
    String channel,
    ChatKey key,
    List<_Outgoing> messages,
  ) async {
    for (final (:body, :picture) in messages) {
      Map<String, dynamic>? image;
      if (picture != null) {
        uploading[channel] = (uploading[channel] ?? 0) + 1;
        notifyListeners();
        try {
          final id = randomUuid();
          final sealed = key.sealImage(
            channel: channel,
            author: account,
            image: id,
            kind: picture.kind,
            width: picture.width,
            height: picture.height,
            bytes: picture.bytes,
          );
          image = jsonDecode(sealed.image) as Map<String, dynamic>;
          await _api.uploadChatImage(channel, id, sealed.ciphertext);
          // Our own picture shows at once, without a round trip.
          pictures[id] = picture.bytes;
        } on ApiException catch (e) {
          error = "The picture didn't go out: ${e.message}";
          continue;
        } finally {
          uploading[channel] = uploading[channel]! - 1;
          notifyListeners();
        }
      }
      final sealed = jsonDecode(
        key.encrypt(channel: channel, author: account, text: body),
      );
      gateway.send('send_message', {
        'channel': channel,
        'sealed': sealed,
        'image': ?image,
      });
    }
  }

  /// Asks a holder online for the current key.
  void _requestKey(String channel) {
    _working = (channel: channel, request: true);
    gateway.send('request_chat_key', {'channel': channel});
    _timer?.cancel();
    // Someone holds it but doesn't answer: start over with a new key.
    _timer = Timer(_requestTimeout, () {
      final working = _working;
      if (working != null && working.channel == channel && working.request) {
        _gaveUp(channel);
      }
    });
  }

  /// Nobody handed the key over: start a new one if there's something to send.
  void _gaveUp(String channel) {
    _working = null;
    _timer?.cancel();
    if (_outbox[channel]?.isNotEmpty ?? false) {
      unawaited(_createKey(channel, _rooms[channel]?.key));
    } else {
      waiting.remove(channel);
      notifyListeners();
    }
  }

  /// Starts a new key, sealed for every device the channel admits.
  Future<void> _createKey(String channel, String? previous) async {
    _working = (channel: channel, request: false);
    _timer?.cancel();
    try {
      final devices = await _api.chatDevices(channel);
      unawaited(trust?.watchMine(devices, account));
      final key = ChatKey.generate();
      final envelopes = [
        for (final d in devices)
          {
            'to': d.device,
            'envelope': jsonDecode(
              key.seal(
                channel: channel,
                sender: device.keys,
                recipientPublicKey: d.publicKey,
              ),
            ),
          },
        if (!devices.any((d) => d.device == device.id))
          {
            'to': device.id,
            'envelope': jsonDecode(
              key.seal(
                channel: channel,
                sender: device.keys,
                recipientPublicKey: device.keys.publicKey,
              ),
            ),
          },
      ];
      (_keys[channel] ??= {})[key.id] = key;
      gateway.send('create_chat_key', {
        'channel': channel,
        'previous': previous,
        'key': key.id,
        'envelopes': envelopes,
      });
    } on ApiException catch (e) {
      _working = null;
      waiting.remove(channel);
      error = e.message;
      notifyListeners();
    }
  }

  /// Seals the current key for a device that asked for it.
  Future<void> _share(String channel, DeviceKey to) async {
    unawaited(trust?.watchMine([to], account));
    if (!(_rooms[channel]?.loaded ?? false)) await _load(channel);
    final key = _currentKey(channel);
    if (key == null) return;
    gateway.send('share_chat_key', {
      'to': to.device,
      'envelope': jsonDecode(
        key.seal(
          channel: channel,
          sender: device.keys,
          recipientPublicKey: to.publicKey,
        ),
      ),
    });
  }

  void _apply(GatewayEvent event) {
    final data = event.data;
    switch (event.type) {
      case 'chat_message':
        final message = ChatMessage.fromJson(
          (data as Map<String, dynamic>)['message'] as Map<String, dynamic>,
        );
        final room = _rooms[message.channel] ??= ChatRoom();
        room.messages = [...room.messages, _reveal(message)];
        room.expiresAt = DateTime.fromMillisecondsSinceEpoch(
          data['expires_at'] as int,
        );
        if (open != message.channel) {
          unread[message.channel] = (unread[message.channel] ?? 0) + 1;
        }
        _incoming.add(message);
      case 'chat_deleted':
        final deleted = data as Map<String, dynamic>;
        final room = _rooms[deleted['channel']];
        if (room != null) {
          for (final m in room.messages) {
            if (m.id == deleted['message']) _forget(m.image);
          }
          room.messages = [
            for (final m in room.messages)
              if (m.id != deleted['message']) m,
          ];
        }
      case 'chat_cleared':
        final channel = (data as Map<String, dynamic>)['channel'] as String;
        for (final m in _rooms[channel]?.messages ?? const <ChatMessage>[]) {
          _forget(m.image);
        }
        _rooms[channel] = ChatRoom()..loaded = true;
        unread[channel] = 0;
        for (final key in _keys.remove(channel)?.values ?? <ChatKey>[]) {
          key.dispose();
        }
      case 'chat_key':
        final grant = ChatKeyGrant.fromJson(data as Map<String, dynamic>);
        final id = _accept(grant);
        if (id != null && _rooms[grant.channel]?.key == id) {
          if (_working?.channel == grant.channel) _working = null;
          unawaited(_flush(grant.channel));
        }
      case 'chat_key_changed':
        final changed = data as Map<String, dynamic>;
        final channel = changed['channel'] as String;
        _rooms[channel]?.key = changed['key'] as String;
        if (_working?.channel == channel) _working = null;
        _timer?.cancel();
        if (_outbox[channel]?.isNotEmpty ?? false) unawaited(_flush(channel));
      case 'chat_key_requested':
        final asked = data as Map<String, dynamic>;
        unawaited(
          _share(
            asked['channel'] as String,
            DeviceKey.fromJson(asked['device'] as Map<String, dynamic>),
          ),
        );
        return;
      case 'error':
        final working = _working;
        if ((data as Map<String, dynamic>)['code'] != 'chat_key' ||
            working == null) {
          return;
        }
        if (working.request) {
          // Nobody online holds the key: carry on with a new one if writing.
          _gaveUp(working.channel);
          return;
        }
        _working = null;
        _timer?.cancel();
        final room = _rooms[working.channel];
        if (room != null) {
          // Someone else started a key first: reload and use theirs.
          room.loaded = false;
          unawaited(_flush(working.channel));
        }
      case 'ready':
        // Reconnected: what we hold may be stale, reload on next open.
        for (final room in _rooms.values) {
          room.loaded = false;
        }
        _working = null;
        final shown = open;
        if (shown != null) unawaited(show(shown));
      default:
        return;
    }
    notifyListeners();
  }
}
