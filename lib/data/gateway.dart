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

  /// Every event, after the channel list took it in.
  Stream<GatewayEvent> get events => _events.stream;

  /// Where someone's avatar is, if they have one.
  Uri? avatar(String? account, int? version) =>
      account == null || version == null
      ? null
      : avatarUrl(session.server.origin, account, version);

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
    final delay = Duration(
      milliseconds: (1000 * (1 << _retry)).clamp(1000, 30000),
    );
    _retry = (_retry + 1).clamp(0, 5);
    _reconnect = Timer(delay, connect);
  }

  void _receive(String message) {
    final json = jsonDecode(message) as Map<String, dynamic>;
    final event = (type: json['type'] as String, data: json['data']);
    _apply(event);
    if (!_events.isClosed) _events.add(event);
  }

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
        status = GatewayStatus.ready;
        error = null;
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
