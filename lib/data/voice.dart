// Voice in a channel: a LiveKit room with end-to-end encrypted media and
// the call key handling around it, the same as the web client's
// lib/voice.svelte.ts so the two hear each other.
//
// Every participant's media is encrypted with one call key per channel. The
// first person in an empty channel makes it. After that the "leader" (the
// smallest session id) seals the key for each newcomer, and when someone
// leaves the leader rotates it for everyone still there. The server only
// relays sealed envelopes.
//
// Two things differ from LiveKit's defaults to match the browser: the key
// is stretched with HKDF (the web client hands LiveKit raw key material),
// and the key slot (epoch % 16) is set explicitly, since LiveKit's shared
// key mode would start every new track on slot 0.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart' as lk;

import '../src/rust/api/call.dart';
import 'gateway.dart';
import 'protocol.dart';

/// LiveKit keeps this many keys; our key epoch picks the slot.
const _keyringSize = 16;

/// The participant who hands out call keys: the smallest session id.
String? leaderOf(Iterable<Participant> participants) {
  final sessions = participants.map((p) => p.session).toList()..sort();
  return sessions.isEmpty ? null : sessions.first;
}

/// LiveKit's key provider with HKDF, and every track on the current slot.
class _CallKeyProvider extends lk.BaseKeyProvider {
  _CallKeyProvider(super.keyProvider, super.options);

  int slot = 0;

  static Future<_CallKeyProvider> create() async {
    final options = rtc.KeyProviderOptions(
      sharedKey: true,
      ratchetSalt: Uint8List.fromList(lk.defaultRatchetSalt.codeUnits),
      uncryptedMagicBytes: Uint8List.fromList(lk.defaultMagicBytes.codeUnits),
      // We never ratchet: keys rotate through the gateway instead.
      ratchetWindowSize: 0,
      keyRingSize: _keyringSize,
      keyDerivationAlgorithm: rtc.KeyDerivationAlgorithm.kHKDF,
    );
    return _CallKeyProvider(
      await rtc.frameCryptorFactory.createDefaultKeyProvider(options),
      options,
    );
  }

  Future<void> use(CallKey key) async {
    slot = key.epoch % _keyringSize;
    await keyProvider.setSharedKey(key: key.bytes, index: slot);
  }

  @override
  int getLatestIndex(String participantId) => slot;
}

enum VoiceState { idle, joining, waitingForKey, connected }

class Voice extends ChangeNotifier {
  Voice(this.gateway) {
    _subscription = gateway.events.listen(_onEvent);
  }

  final Gateway gateway;
  late final StreamSubscription<GatewayEvent> _subscription;

  String? channel;
  VoiceState state = VoiceState.idle;
  bool muted = false;
  bool serverMuted = false;

  /// Session ids of who is talking right now.
  Set<String> speaking = {};

  /// Session ids whose microphone is off or missing.
  Set<String> micOff = {};
  String? error;

  /// Our account is in a call on another device: (channel here, channel there).
  (String, String)? elsewhere;

  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _roomEvents;
  _CallKeyProvider? _keys;
  CallKey? _key;

  /// Bumped on every leave, so a join still connecting knows it's over.
  int _attempt = 0;
  bool _disposed = false;

  void join(String id, {bool takeOver = false}) {
    if (channel == id) return;
    leave();
    channel = id;
    state = VoiceState.joining;
    error = null;
    elsewhere = null;
    gateway.send('join_voice', {
      'channel': id,
      if (takeOver) 'take_over': true,
    });
    notifyListeners();
  }

  void takeOver() {
    final asked = elsewhere;
    if (asked != null) join(asked.$1, takeOver: true);
  }

  void leave() {
    if (channel == null) return;
    gateway.send('leave_voice');
    _reset();
  }

  Future<void> toggleMute() async {
    final room = _room;
    if (room == null) return;
    if (!muted) {
      await room.localParticipant?.setMicrophoneEnabled(false);
      muted = true;
    } else if (serverMuted) {
      error = 'A moderator muted you; only they can lift it.';
    } else {
      muted = false;
      await _publishMicrophone();
    }
    _refreshMicStates();
  }

  @override
  void dispose() {
    leave();
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }

  /// Joins and leaves finish after awaits, maybe after the sign-out that
  /// closed this connection.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  List<Participant> get _participants => channel == null
      ? const []
      : (gateway.channel(channel!)?.participants ?? const []);

  void _reset() {
    _attempt++;
    _roomEvents?.dispose();
    _roomEvents = null;
    unawaited(_close(_room, _keys));
    _room = null;
    _keys = null;
    _key?.dispose();
    _key = null;
    channel = null;
    state = VoiceState.idle;
    speaking = {};
    micOff = {};
    muted = false;
    serverMuted = false;
    notifyListeners();
  }

  void _onEvent(GatewayEvent event) {
    final data = event.data;
    switch (event.type) {
      case 'voice_granted':
        final granted = data as Map<String, dynamic>;
        if (granted['channel'] != channel) return;
        final me = _participants
            .where((p) => p.session == gateway.sessionId)
            .firstOrNull;
        serverMuted = me?.serverMuted ?? false;
        unawaited(
          _connect(
            granted['livekit_url'] as String,
            granted['token'] as String,
            first: (granted['peers'] as List<dynamic>).isEmpty,
          ),
        );
      case 'key_envelope':
        final envelope = data as Map<String, dynamic>;
        unawaited(
          _receiveKey(
            envelope['from'] as String,
            jsonEncode(envelope['envelope']),
          ),
        );
      case 'voice_joined':
        final joined = data as Map<String, dynamic>;
        if (joined['channel'] != channel) return;
        _welcome(
          Participant.fromJson(joined['participant'] as Map<String, dynamic>),
        );
      case 'voice_left':
        final left = data as Map<String, dynamic>;
        if (left['channel'] != channel) return;
        if (left['session'] == gateway.sessionId) {
          _reset();
        } else {
          unawaited(_rotate());
        }
      case 'participant_updated':
        final updated = data as Map<String, dynamic>;
        final participant = Participant.fromJson(
          updated['participant'] as Map<String, dynamic>,
        );
        if (updated['channel'] != channel ||
            participant.session != gateway.sessionId) {
          return;
        }
        serverMuted = participant.serverMuted;
        if (serverMuted) {
          muted = true;
          error = 'A moderator muted you.';
        } else {
          error = 'A moderator lifted your mute. Unmute when you are ready.';
        }
        _refreshMicStates();
      case 'channel_removed':
        if ((data as Map<String, dynamic>)['channel'] == channel) _reset();
      case 'voice_elsewhere':
        final asked = data as Map<String, dynamic>;
        if (state == VoiceState.joining && asked['channel'] == channel) {
          final here = asked['channel'] as String;
          _reset();
          elsewhere = (here, asked['elsewhere'] as String);
          notifyListeners();
        }
      case 'kicked':
        final kicked = data as Map<String, dynamic>;
        if (kicked['channel'] == channel) _reset();
        error = 'You left the channel: ${kicked['reason']}.';
        notifyListeners();
      case 'error':
        final failure = data as Map<String, dynamic>;
        if (failure['code'] == 'chat_key') return;
        error = failure['message'] as String?;
        if (state == VoiceState.joining) _reset();
        notifyListeners();
    }
  }

  /// Leaves a room and drops its key provider, which LiveKit leaves alone and
  /// which would otherwise keep the call key in memory.
  Future<void> _close(lk.Room? room, _CallKeyProvider? keys) async {
    try {
      await room?.disconnect();
      await room?.dispose();
    } finally {
      await keys?.keyProvider.dispose();
    }
  }

  Future<void> _connect(String url, String token, {required bool first}) async {
    final attempt = _attempt;
    try {
      final keys = await _CallKeyProvider.create();
      if (attempt != _attempt) {
        await keys.keyProvider.dispose();
        return;
      }
      _keys = keys;
      // The channel's audio quality, as the web client publishes it: low
      // bitrates may pause in silence (DTX), RED repeats packets against loss.
      final audio =
          gateway.channel(channel!)?.channel.audio ??
          const AudioQuality(bitrate: 64000, stereo: false);
      final room = lk.Room(
        roomOptions: lk.RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          encryption: lk.E2EEOptions(keyProvider: keys),
          // Echo cancellation and friends on, the web client's default until
          // the app has settings.
          defaultAudioCaptureOptions: const lk.AudioCaptureOptions(),
          defaultAudioPublishOptions: lk.AudioPublishOptions(
            encoding: lk.AudioEncoding(maxBitrate: audio.bitrate),
            dtx: audio.bitrate <= 64000,
            red: true,
          ),
        ),
      );
      _room = room;
      _roomEvents = room.createListener()
        ..on<lk.ActiveSpeakersChangedEvent>((e) {
          speaking = {for (final p in e.speakers) p.identity};
          notifyListeners();
        })
        ..on<lk.TrackPublishedEvent>((_) => _refreshMicStates())
        ..on<lk.TrackUnpublishedEvent>((_) => _refreshMicStates())
        ..on<lk.TrackMutedEvent>((_) => _refreshMicStates())
        ..on<lk.TrackUnmutedEvent>((_) => _refreshMicStates())
        ..on<lk.ParticipantConnectedEvent>((_) => _refreshMicStates())
        ..on<lk.ParticipantDisconnectedEvent>((_) => _refreshMicStates())
        ..on<lk.RoomDisconnectedEvent>((_) {
          if (_room == room) leave();
        });

      if (first) await _useKey(CallKey.generate());
      if (attempt != _attempt) return;
      await room.connect(url, token);
      if (attempt != _attempt) {
        // Closed while connecting, which a connect may outlive.
        await room.disconnect();
        return;
      }
      if (_key != null) {
        await _publishMicrophone();
      } else {
        state = VoiceState.waitingForKey;
      }
      _refreshMicStates();
    } catch (e) {
      // Left while connecting: the room closed under us, nothing went wrong.
      if (attempt != _attempt) return;
      debugPrint('cannot join voice: $e');
      error = 'Cannot connect to voice.';
      leave();
    }
  }

  Future<void> _useKey(CallKey key) async {
    final current = _key;
    if (current != null && key.epoch < current.epoch) return;
    _key = key;
    if (current != null && !identical(current, key)) current.dispose();
    await _keys?.use(key);
    // Tracks already published keep their slot until told otherwise.
    await _room?.e2eeManager?.setKeyIndex(key.epoch % _keyringSize);
  }

  Future<void> _publishMicrophone() async {
    final room = _room;
    if (room == null || channel == null) return;
    state = VoiceState.connected;
    if (serverMuted) {
      muted = true;
      notifyListeners();
      return;
    }
    try {
      await room.localParticipant?.setMicrophoneEnabled(true);
      muted = false;
    } catch (e) {
      debugPrint('microphone unavailable: $e');
      muted = true;
      error = 'Microphone unavailable: you can listen, but not speak.';
    }
    _refreshMicStates();
  }

  Future<void> _receiveKey(String from, String envelope) async {
    final sender = _participants.where((p) => p.device == from).firstOrNull;
    if (sender == null) return;
    try {
      final hadKey = _key != null;
      await _useKey(
        CallKey.open(
          envelope: envelope,
          recipient: gateway.device.keys,
          senderPublicKey: sender.publicKey,
        ),
      );
      if (!hadKey && state == VoiceState.waitingForKey) {
        await _publishMicrophone();
      }
    } catch (e) {
      debugPrint('rejected a call key envelope: $e');
    }
  }

  bool _iAmLeader(Iterable<Participant> among) =>
      _key != null && leaderOf(among) == gateway.sessionId;

  /// Hands the current key to someone who just came in.
  void _welcome(Participant newcomer) {
    final key = _key;
    if (newcomer.session == gateway.sessionId ||
        key == null ||
        channel == null) {
      return;
    }
    if (!_iAmLeader(
      _participants.where((p) => p.session != newcomer.session),
    )) {
      return;
    }
    _sendKey(key, newcomer);
  }

  /// After someone left: a new key for everyone still here.
  Future<void> _rotate() async {
    final key = _key;
    final remaining = _participants;
    if (key == null || !_iAmLeader(remaining)) return;
    final next = key.next();
    for (final p in remaining) {
      if (p.session != gateway.sessionId) _sendKey(next, p);
    }
    await _useKey(next);
  }

  void _sendKey(CallKey key, Participant to) {
    final envelope = key.seal(
      channel: channel!,
      sender: gateway.device.keys,
      recipientPublicKey: to.publicKey,
    );
    gateway.send('send_key_envelope', {
      'to': to.device,
      'envelope': jsonDecode(envelope),
    });
  }

  void _refreshMicStates() {
    final room = _room;
    if (room == null) return;
    micOff = {
      if (room.localParticipant case final local?
          when !local.isMicrophoneEnabled())
        local.identity,
      for (final remote in room.remoteParticipants.values)
        if (!remote.isMicrophoneEnabled()) remote.identity,
    };
    notifyListeners();
  }
}
