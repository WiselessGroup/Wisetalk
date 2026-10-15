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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart' as lk;

import '../src/rust/api/call.dart';
import 'call_service.dart';
import 'gateway.dart';
import 'preferences.dart';
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

/// A camera or screen share on screen.
class VideoTile {
  const VideoTile({
    required this.id,
    required this.session,
    required this.name,
    required this.screen,
    required this.local,
    required this.track,
  });

  /// Track sid, stable while the track lives.
  final String id;

  /// Session id of the participant, the LiveKit identity.
  final String session;
  final String name;
  final bool screen;
  final bool local;
  final lk.VideoTrack track;
}

/// What a screen share is tuned for. Text needs sharp frames but few of
/// them; motion needs many, and costs both ends more.
enum ScreenQuality {
  text(
    lk.VideoParameters(
      dimensions: lk.VideoDimensionsPresets.h1080_169,
      encoding: lk.VideoEncoding(maxBitrate: 1500 * 1000, maxFramerate: 5),
    ),
  ),
  motion(lk.VideoParametersPresets.screenShareH1080FPS30);

  const ScreenQuality(this.parameters);

  final lk.VideoParameters parameters;
}

class Voice extends ChangeNotifier {
  Voice(this.gateway, this.preferences) {
    _subscription = gateway.events.listen(_onEvent);
    preferences.addListener(_preferencesChanged);
    unawaited(_applyOutput());
  }

  final Gateway gateway;
  final Preferences preferences;

  /// What the microphone was published with, to notice a change.
  (String?, bool)? _published;
  final _service = CallService();
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

  bool camera = false;
  bool screen = false;

  /// Cameras and screen shares, in the order they appeared.
  List<VideoTile> tiles = const [];

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

  /// Moderators: turns someone's microphone off for everyone, or lets
  /// them speak again. The server checks the right and the rank.
  void serverMute(String session, {required bool muted}) =>
      gateway.send('server_mute', {'session': session, 'muted': muted});

  /// Moderators: takes someone out of the call.
  void kick(String session) => gateway.send('kick', {'session': session});

  Future<void> toggleMute() async {
    final room = _room;
    if (room == null) return;
    if (!muted) {
      await _unpublish(lk.TrackSource.microphone);
      muted = true;
    } else if (serverMuted) {
      error = 'A moderator muted you; only they can lift it.';
    } else {
      muted = false;
      await _publishMicrophone();
    }
    _refreshMicStates();
  }

  Future<void> toggleCamera() async {
    final local = _room?.localParticipant;
    if (local == null) return;
    try {
      if (camera) {
        await _unpublish(lk.TrackSource.camera);
      } else {
        await local.setCameraEnabled(
          true,
          // 720p: plenty for a face, and light on the machine sending it.
          cameraCaptureOptions: lk.CameraCaptureOptions(
            deviceId: preferences.camera,
            params: lk.VideoParametersPresets.h720_169,
          ),
        );
      }
    } catch (e) {
      debugPrint('camera unavailable: $e');
      error = 'Camera unavailable.';
    }
    // Read the state back: unpublish events fire while the call above runs.
    camera = _room?.localParticipant?.isCameraEnabled() ?? false;
    notifyListeners();
  }

  lk.AudioCaptureOptions _audioCapture() => lk.AudioCaptureOptions(
    deviceId: preferences.microphone,
    noiseSuppression: preferences.processing,
    echoCancellation: preferences.processing,
    autoGainControl: preferences.processing,
    highPassFilter: preferences.processing,
  );

  /// The chosen device among those there now; `null` when it's gone.
  Future<lk.MediaDevice?> _device(String kind, String? id) async {
    if (id == null) return null;
    final devices = await lk.Hardware.instance.enumerateDevices(type: kind);
    return devices.where((d) => d.deviceId == id).firstOrNull;
  }

  /// Desktop libwebrtc records from one device for the whole app, set
  /// apart from the track; Android picks it with the track's constraints.
  Future<void> _selectMicrophone() async {
    if (Platform.isAndroid || Platform.isIOS) return;
    final device = await _device('audioinput', preferences.microphone);
    if (device == null) return;
    try {
      await lk.Hardware.instance.selectAudioInput(device);
    } catch (e) {
      debugPrint('cannot select the microphone: $e');
    }
  }

  Future<void> _applyOutput() async {
    final device = await _device('audiooutput', preferences.speaker);
    if (device == null) return;
    try {
      await lk.Hardware.instance.selectAudioOutput(device);
    } catch (e) {
      debugPrint('cannot select the speakers: $e');
    }
  }

  /// Applies a changed setting to the call: speakers and volumes at once,
  /// the microphone by publishing it again, the camera by switching it.
  Future<void> _preferencesChanged() async {
    await _applyOutput();
    _applyVolumes();
    final room = _room;
    if (room == null || state != VoiceState.connected) return;
    if (!muted &&
        _published != (preferences.microphone, preferences.processing)) {
      await _unpublish(lk.TrackSource.microphone);
      await _publishMicrophone();
    }
    final camera = await _device('videoinput', preferences.camera);
    if (camera != null && this.camera) {
      try {
        await room.setVideoInputDevice(camera);
      } catch (e) {
        debugPrint('cannot switch the camera: $e');
        error = 'Cannot switch to that camera.';
        notifyListeners();
      }
    }
  }

  /// Everyone else as loud as this person set them, or silent.
  void _applyVolumes() {
    final room = _room;
    if (room == null) return;
    for (final remote in room.remoteParticipants.values) {
      final person = _participants
          .where((p) => p.session == remote.identity)
          .firstOrNull;
      if (person == null) continue;
      final volume = preferences.volumeOf(person);
      for (final publication in remote.audioTrackPublications) {
        final track = publication.track;
        if (track == null) continue;
        unawaited(
          rtc.Helper.setVolume(
            volume,
            track.mediaStreamTrack,
          ).catchError((Object e) => debugPrint('cannot set a volume: $e')),
        );
      }
    }
  }

  /// Turns the microphone or camera off by unpublishing it. LiveKit's own
  /// "off" mutes the track and stops its capture, and after a full
  /// reconnect it publishes that dead track again and throws ("track is
  /// null"). The others see a missing track as off, the same as a muted one.
  Future<void> _unpublish(lk.TrackSource source) async {
    final local = _room?.localParticipant;
    final publication = local?.getTrackPublicationBySource(source);
    if (local != null && publication != null) {
      await local.removePublishedTrack(publication.sid);
    }
  }

  /// Shares a screen or a window: [source] from the desktop source list,
  /// or `null` for whatever the system lets the person pick (Wayland asks
  /// through its own dialog).
  Future<void> startScreen({
    String? source,
    ScreenQuality quality = ScreenQuality.text,
  }) async {
    final local = _room?.localParticipant;
    if (local == null) return;
    // Android asks first (whole screen or one app), then wants the
    // foreground service running before capture starts.
    if (Platform.isAndroid) {
      if (!await rtc.Helper.requestCapturePermission()) return;
      final name = gateway.channel(channel ?? '')?.channel.name ?? 'Wisetalk';
      if (!await _service.update(channel: name, sharing: true)) {
        error = 'Screen sharing unavailable.';
        notifyListeners();
        return;
      }
    }
    try {
      await local.setScreenShareEnabled(
        true,
        screenShareCaptureOptions: lk.ScreenShareCaptureOptions(
          sourceId: source,
          maxFrameRate: quality.parameters.encoding!.maxFramerate.toDouble(),
          params: quality.parameters,
        ),
      );
    } catch (e) {
      // Cancelling the system's share dialog lands here too.
      debugPrint('screen share stopped or refused: $e');
    }
    screen = _room?.localParticipant?.isScreenShareEnabled() ?? false;
    unawaited(_syncService());
    notifyListeners();
  }

  Future<void> stopScreen() async {
    final local = _room?.localParticipant;
    if (local == null) return;
    try {
      await local.setScreenShareEnabled(false);
    } catch (e) {
      debugPrint('cannot stop screen share: $e');
    }
    screen = _room?.localParticipant?.isScreenShareEnabled() ?? false;
    unawaited(_syncService());
    notifyListeners();
  }

  @override
  void dispose() {
    preferences.removeListener(_preferencesChanged);
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
    camera = false;
    screen = false;
    tiles = const [];
    unawaited(_service.update(channel: null));
    notifyListeners();
  }

  /// Android: the call's foreground service follows the call.
  Future<bool> _syncService() {
    final id = channel;
    return _service.update(
      channel: id == null || state != VoiceState.connected
          ? null
          : gateway.channel(id)?.channel.name ?? 'Wisetalk',
      sharing: screen,
    );
  }

  void _addTile(
    lk.TrackPublication publication,
    lk.Participant participant,
    lk.VideoTrack track, {
    required bool local,
  }) {
    final tile = VideoTile(
      id: publication.sid,
      session: participant.identity,
      name: local
          ? 'You'
          : (participant.name.isEmpty
                ? participant.identity
                : participant.name),
      screen: publication.source == lk.TrackSource.screenShareVideo,
      local: local,
      track: track,
    );
    tiles = [
      for (final t in tiles)
        if (t.id != tile.id) t,
      tile,
    ];
    notifyListeners();
  }

  void _removeTile(String id) {
    if (!tiles.any((t) => t.id == id)) return;
    tiles = [
      for (final t in tiles)
        if (t.id != id) t,
    ];
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
      // The key may have come in while the provider was being made, with
      // nowhere to go: hand it over now.
      final early = _key;
      if (early != null) await keys.use(early);
      if (attempt != _attempt) return;
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
          defaultAudioCaptureOptions: _audioCapture(),
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
        ..on<lk.TrackSubscribedEvent>((e) {
          final track = e.track;
          if (track is lk.VideoTrack && !e.publication.muted) {
            _addTile(e.publication, e.participant, track, local: false);
          }
          if (track is lk.AudioTrack) _applyVolumes();
        })
        ..on<lk.TrackUnsubscribedEvent>((e) => _removeTile(e.publication.sid))
        ..on<lk.LocalTrackPublishedEvent>((e) {
          final track = e.publication.track;
          if (track is lk.LocalVideoTrack) {
            _addTile(e.publication, e.participant, track, local: true);
          }
          _refreshMicStates();
        })
        ..on<lk.LocalTrackUnpublishedEvent>((e) {
          _removeTile(e.publication.sid);
          // The system's own "stop sharing" ends up here.
          if (e.publication.source == lk.TrackSource.screenShareVideo) {
            screen = false;
            unawaited(_syncService());
          }
          if (e.publication.source == lk.TrackSource.camera) camera = false;
          _refreshMicStates();
        })
        // Other clients mute a camera instead of unpublishing it: drop its
        // tile so the person shows up with their avatar, not a black frame.
        ..on<lk.TrackMutedEvent>((e) {
          if (e.publication.kind == lk.TrackType.VIDEO) {
            _removeTile(e.publication.sid);
          }
          _refreshMicStates();
        })
        ..on<lk.TrackUnmutedEvent>((e) {
          final track = e.publication.track;
          if (track is lk.VideoTrack) {
            _addTile(
              e.publication,
              e.participant,
              track,
              local: e.participant is lk.LocalParticipant,
            );
          }
          _refreshMicStates();
        })
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
      unawaited(_syncService());
      notifyListeners();
      return;
    }
    try {
      await _selectMicrophone();
      await room.localParticipant?.setMicrophoneEnabled(
        true,
        audioCaptureOptions: _audioCapture(),
      );
      _published = (preferences.microphone, preferences.processing);
      muted = false;
    } catch (e) {
      debugPrint('microphone unavailable: $e');
      muted = true;
      error = 'Microphone unavailable: you can listen, but not speak.';
    }
    // After the microphone permission: the service needs it.
    unawaited(_syncService());
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
