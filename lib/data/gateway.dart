// The gateway WebSocket: the channel list and who sits where, kept current
// from server events, reconnecting when the connection drops. The same
// protocol as the web client's lib/gateway.svelte.ts.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../src/rust/api/text.dart';
import 'api.dart';
import 'device.dart';
import 'language.dart';
import 'problem.dart';
import 'protocol.dart';
import 'session.dart';

enum GatewayStatus { connecting, ready, offline }

/// One gateway event: its `type` and `data` as the server sent them.
typedef GatewayEvent = ({String type, dynamic data});

class Gateway extends ChangeNotifier {
  Gateway(this.session, this.device);

  final Session session;
  final LocalDevice device;

  GatewayStatus status = GatewayStatus.connecting;

  /// This connection's id, also its identity in calls; `null` until ready.
  String? sessionId;
  List<Space> spaces = [];

  /// The server's custom emoji, for channel and space icons (WLK-50).
  List<CustomEmoji> emoji = [];
  List<ChannelView> channels = [];
  String? error;

  /// Why this session is over: banned, signed out elsewhere.
  String? ended;

  /// Our role on the server: owner, admin, moderator or member; `null` for
  /// guests. Changes while connected (`role_changed`).
  late String? role = session.me.role;

  bool get isAdmin => role == 'owner' || role == 'admin';

  /// Our own picture's version, changed from Settings.
  late int? myAvatar = session.me.avatar;

  void avatarChanged(int? version) {
    myAvatar = version;
    notifyListeners();
  }

  /// Admins manage every space; an owner manages their own.
  bool managesSpace(Space space) =>
      isAdmin || (space.owner != null && space.owner == session.me.id);

  WebSocket? _socket;
  final _events = StreamController<GatewayEvent>.broadcast();
  int _retry = 0;
  Timer? _reconnect;
  bool _closed = false;
  bool _disposed = false;
  bool _background = false;

  /// The phone has no network (Stay Connected says so): nothing to retry.
  bool _networkGone = false;

  /// The server is older than background mode (before 1.9) and can't read
  /// `set_background`: the connection stays as it is.
  bool _backgroundUnsupported = false;
  bool _sentBackground = false;

  /// Coming back from the background: the full `ready` that should follow,
  /// or the connection died quietly while the phone slept.
  Timer? _awaitingReady;

  /// The connection only carries summons, kicks and chat keys (ADR-0035,
  /// lib/data/stay_connected.dart): an app in the background on Android.
  bool get background => _background;

  /// Goes to the background or comes back. Coming back brings a full
  /// `ready`, which replaces whatever went stale meanwhile.
  void setBackground(bool on) {
    if (_background == on) return;
    _background = on;
    if (_backgroundUnsupported || _socket == null) return;
    _sentBackground = true;
    send('set_background', {'background': on});
    _awaitingReady?.cancel();
    if (!on) {
      // One check per coming back, not a timer that keeps running.
      _awaitingReady = Timer(const Duration(seconds: 10), () {
        if (_socket != null) unawaited(_socket!.close());
      });
    }
  }

  /// The phone's network changed ([available]) or went: a connection over
  /// the old one is gone even if nothing said so yet. Reconnects at once
  /// instead of waiting for the backoff; nothing at all without a network.
  void networkChanged(bool available) {
    if (_closed) return;
    _reconnect?.cancel();
    _reconnect = null;
    _retry = 0;
    _networkGone = !available;
    if (!available) return;
    final socket = _socket;
    if (socket == null) {
      if (status != GatewayStatus.connecting) unawaited(connect());
    } else if (_background) {
      // Closing ends in _dropped, which reconnects after a second. Not in
      // the foreground: a call rides on this connection, and a working
      // one is better left alone.
      unawaited(socket.close());
    }
  }

  /// Every event, after the channel list took it in.
  Stream<GatewayEvent> get events => _events.stream;

  /// Where someone's avatar is, if they have one.
  Uri? avatar(String? account, int? version) =>
      account == null || version == null
      ? null
      : avatarUrl(session.server.origin, account, version);

  /// Where the picture of custom emoji [name] is; `null` once it is gone.
  Uri? emojiPicture(String name) {
    for (final e in emoji) {
      if (e.name == name) return emojiUrl(session.server.origin, e);
    }
    return null;
  }

  ChannelView? channel(String id) {
    for (final view in channels) {
      if (view.channel.id == id) return view;
    }
    return null;
  }

  Future<void> connect() async {
    _closed = false;
    status = GatewayStatus.connecting;
    notifyListeners();
    final origin = session.server.origin;
    final url = origin.replace(
      scheme: origin.scheme == 'https' ? 'wss' : 'ws',
      path: '/api/gateway',
    );
    try {
      final socket = await WebSocket.connect(
        url.toString(),
        headers: {'authorization': 'Bearer ${session.token}'},
      ).timeout(const Duration(seconds: 15));
      if (_closed) {
        await socket.close();
        return;
      }
      _socket = socket;
      _retry = 0;
      // Before hello: then the ready that answers it is small.
      if (_background && !_backgroundUnsupported) {
        _sentBackground = true;
        send('set_background', {'background': true});
      }
      send('hello', {
        'protocol': protocolVersion(),
        'device': device.id,
        'public_key': device.keys.publicKey,
      });
      socket.listen(
        (message) => _receive(message as String),
        onDone: _dropped,
        onError: (_) => _dropped(),
        cancelOnError: true,
      );
    } catch (_) {
      _dropped();
    }
  }

  void send(String type, [Object? data]) {
    final socket = _socket;
    if (socket == null || socket.readyState != WebSocket.open) return;
    socket.add(jsonEncode({'type': type, 'data': ?data}));
  }

  @override
  void dispose() {
    _closed = true;
    _disposed = true;
    _reconnect?.cancel();
    _awaitingReady?.cancel();
    _socket?.close();
    _events.close();
    super.dispose();
  }

  /// A dropped connection finds out why after an await, maybe after the
  /// sign-out that disposed this gateway.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  Future<void> _dropped() async {
    _socket = null;
    sessionId = null;
    _awaitingReady?.cancel();
    if (_closed) return;
    status = GatewayStatus.offline;
    notifyListeners();
    // A deleted session can't reconnect: stop instead of retrying forever.
    if (ended == null) {
      try {
        await session.api.me();
      } on ApiException catch (e) {
        if (e.unauthorized) ended = appTexts.connectionSignedOut;
      }
    }
    if (ended != null || _closed) {
      _closed = true;
      notifyListeners();
      return;
    }
    // Stay Connected says when there is a network again (networkChanged):
    // no tries in the meantime.
    if (_networkGone) return;
    final delay = Duration(
      milliseconds: (1000 * (1 << _retry)).clamp(1000, 30000),
    );
    _retry = (_retry + 1).clamp(0, 5);
    _reconnect = Timer(delay, connect);
  }

  void _receive(String message) {
    final json = jsonDecode(message) as Map<String, dynamic>;
    final event = (type: json['type'] as String, data: json['data']);
    if (_quiet(event)) return;
    _apply(event);
    if (!_events.isClosed) _events.add(event);
  }

  /// What background mode says to this connection only: a `ready` without
  /// channels, which must not empty the list, and an older server's answer
  /// that it can't read `set_background`. Nobody else hears these.
  bool _quiet(GatewayEvent event) {
    final data = event.data;
    if (event.type == 'ready' &&
        data is Map<String, dynamic> &&
        data['background'] == true) {
      sessionId = data['session'] as String;
      status = GatewayStatus.ready;
      error = null;
      notifyListeners();
      return true;
    }
    if (event.type == 'ready') _awaitingReady?.cancel();
    if (event.type == 'error' &&
        data is Map<String, dynamic> &&
        (data['problem'] as Map<String, dynamic>?)?['key'] ==
            'unreadable_command' &&
        !_backgroundUnsupported &&
        _sentBackground) {
      // Only set_background is newer than the servers we talk to.
      _backgroundUnsupported = true;
      _awaitingReady?.cancel();
      return true;
    }
    return false;
  }

  static List<CustomEmoji> _emojiList(dynamic json) => [
    for (final e in json as List<dynamic>? ?? const [])
      CustomEmoji.fromJson(e as Map<String, dynamic>),
  ];

  void _apply(GatewayEvent event) {
    final data = event.data;
    switch (event.type) {
      case 'ready':
        final ready = data as Map<String, dynamic>;
        sessionId = ready['session'] as String;
        spaces = [
          for (final s in ready['spaces'] as List<dynamic>)
            Space.fromJson(s as Map<String, dynamic>),
        ];
        channels = [
          for (final c in ready['channels'] as List<dynamic>)
            ChannelView.fromJson(c as Map<String, dynamic>),
        ];
        emoji = _emojiList(ready['emoji']);
        status = GatewayStatus.ready;
        error = null;
      case 'emoji_updated':
        emoji = _emojiList((data as Map<String, dynamic>)['emoji']);
      case 'channel_updated':
        final view = ChannelView.fromJson(data as Map<String, dynamic>);
        final index = channels.indexWhere(
          (v) => v.channel.id == view.channel.id,
        );
        if (index >= 0) {
          channels[index] = view;
        } else {
          channels.add(view);
        }
        channels.sort(
          (a, b) => a.channel.position.compareTo(b.channel.position),
        );
      case 'channel_removed':
        channels.removeWhere(
          (v) => v.channel.id == (data as Map<String, dynamic>)['channel'],
        );
      case 'space_updated':
        final space = Space.fromJson(data as Map<String, dynamic>);
        final index = spaces.indexWhere((s) => s.id == space.id);
        if (index >= 0) {
          spaces[index] = space;
        } else {
          spaces.add(space);
        }
      case 'space_removed':
        spaces.removeWhere(
          (s) => s.id == (data as Map<String, dynamic>)['space'],
        );
      case 'voice_joined':
        final joined = data as Map<String, dynamic>;
        final participant = Participant.fromJson(
          joined['participant'] as Map<String, dynamic>,
        );
        final view = channel(joined['channel'] as String);
        if (view != null &&
            !view.participants.any((p) => p.session == participant.session)) {
          view.participants.add(participant);
        }
      case 'participant_updated':
        final updated = data as Map<String, dynamic>;
        final participant = Participant.fromJson(
          updated['participant'] as Map<String, dynamic>,
        );
        final list = channel(updated['channel'] as String)?.participants;
        final index =
            list?.indexWhere((p) => p.session == participant.session) ?? -1;
        if (index >= 0) list![index] = participant;
      case 'voice_left':
        final left = data as Map<String, dynamic>;
        channel(left['channel'] as String)?.participants
            .removeWhere((p) => p.session == left['session']);
      case 'role_changed':
        role = (data as Map<String, dynamic>)['role'] as String?;
      case 'error':
        final failure = data as Map<String, dynamic>;
        final text = problemText(
          appTexts,
          failure['problem'],
          failure['message'] as String? ?? '',
        );
        if (failure['code'] == 'banned') {
          ended = text;
          _closed = true;
        } else if (failure['code'] != 'chat_key') {
          error = text;
        }
      default:
        return;
    }
    notifyListeners();
  }
}
