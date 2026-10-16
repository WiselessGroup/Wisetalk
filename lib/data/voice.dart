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

import '../l10n/app_localizations.dart';
import '../src/rust/api/call.dart';
import 'call_service.dart';
import 'gateway.dart';
import 'input_filters.dart';
import 'language.dart';
import 'link.dart';
import 'link_stats.dart';
import 'preferences.dart';
import 'problem.dart';
import 'protocol.dart';
import 'shortcuts.dart';
import 'sounds.dart';
import 'stereo_audio.dart';
import 'trust.dart';

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

/// Whether a screen share can carry its sound: Windows only for now. There
/// libwebrtc records just the shared window's app, or for a whole screen
/// everything but Wisetalk, so the call's voices stay out. On Linux it would
/// record the speakers, the call included (everyone would hear themselves);
/// on macOS and Android it records nothing (WLK-3).
bool get screenSoundAvailable => Platform.isWindows;

/// Screen sound is music and films more than speech: no pauses in the quiet
/// parts (DTX), a music bitrate. Mono: LiveKit's Flutter SDK publishes no
/// stereo, and the Windows capture mixes down to one channel anyway.
const _screenSound = lk.AudioPublishOptions(
  name: 'screen_audio',
  encoding: lk.AudioEncoding.presetMusicHighQuality,
  dtx: false,
);

/// The tick a shortcut is expected to end with, played before the action
/// finishes (see [Voice.perform]). Away, the microphone is off already:
/// turning it on comes back; a server mute refuses it.
@visibleForTesting
Cue expectedCue(
  CallAction action, {
  required bool away,
  required bool muted,
  required bool serverMuted,
}) => switch (action) {
  CallAction.toggleAway => away ? Cue.back : Cue.away,
  CallAction.mute => Cue.mute,
  CallAction.toggleMute when away => Cue.back,
  CallAction.toggleMute when !muted => Cue.mute,
  CallAction.unmute when away => Cue.back,
  CallAction.toggleMute ||
  CallAction.unmute => serverMuted ? Cue.mute : Cue.unmute,
};

class Voice extends ChangeNotifier {
  Voice(this.gateway, this.preferences, {this.trust}) {
    _subscription = gateway.events.listen(_onEvent);
    preferences.addListener(_preferencesChanged);
    unawaited(_applyOutput());
  }

  final Gateway gateway;
  final Preferences preferences;

  /// Device keys of the people in my call (WLK-18); none in tests.
  final KeyWatch? trust;

  /// Whether this person's device key changed since I last met them.
  bool keyChanged(Participant p) => trust?.changed.contains(p.session) ?? false;

  void _reviewKeys(Iterable<Participant> participants) {
    final trust = this.trust;
    if (trust == null) return;
    unawaited(
      trust.review(participants, gateway.sessionId).then((changed) {
        if (changed) notifyListeners();
      }),
    );
  }

  /// What the microphone was published with, to notice a change.
  (String?, bool, AudioQuality)? _published;
  final _audio = StereoAudio();
  final _service = CallService();
  late final StreamSubscription<GatewayEvent> _subscription;

  String? channel;
  VoiceState state = VoiceState.idle;
  bool muted = false;
  bool serverMuted = false;

  /// Stepped away (ADR-0026): the microphone off and nobody heard. We
  /// unsubscribe from everyone's sound rather than turn it down, so none of
  /// it is received or decoded.
  bool away = false;

  /// Whether the microphone was off before stepping away, to come back the
  /// same way.
  bool _mutedBeforeAway = false;

  /// `set_away` sent and not answered yet. Servers before 1.7.0 can't read
  /// it and answer with a protocol_mismatch error instead.
  bool _awayAsked = false;

  /// This server can't show others that we stepped away: Away still works
  /// here, only nobody sees it.
  bool _awayUnsupported = false;

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

  /// Everyone's connection quality in the call, ours too. Changes don't go
  /// through [notifyListeners]: only the icons showing them rebuild.
  final qualities = Qualities();

  /// Our ping, loss and bitrate, measured while something shows them.
  late final link = LinkMonitor(_sampleLink);

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

  /// Someone came or went: hoot, once we're in the call ourselves and
  /// listening.
  void _cue(Cue cue) {
    if (state != VoiceState.connected || away || !preferences.cues) return;
    unawaited(sounds.play(cue));
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
    // Away the microphone is off: turning it on means coming back, to talk
    // and to hear the answer.
    if (away) return _comeBack(unmute: true);
    if (!muted) {
      await _unpublish(lk.TrackSource.microphone);
      muted = true;
    } else if (serverMuted) {
      error = _texts.voiceMutedByModerator;
    } else {
      muted = false;
      await _publishMicrophone();
    }
    _refreshMicStates();
  }

  /// Turns the microphone on or off, whichever way it is now. Turning it
  /// off while away keeps it off on coming back.
  Future<void> setMicrophone({required bool on}) async {
    if (away && !on) {
      _mutedBeforeAway = true;
      return;
    }
    if (on == muted) await toggleMute();
  }

  /// Does what a shortcut asks (ADR-0027) and ticks the outcome, since the
  /// window may be out of sight: away and back, or the microphone off and
  /// on. A refused unmute ticks off.
  Future<void> perform(CallAction action) async {
    if (_room == null || state != VoiceState.connected) return;
    // A key both the window and the system catch must not act twice.
    final now = DateTime.now();
    if (_performed case (final last, final at)
        when last == action && now.difference(at) < _sameKey) {
      return;
    }
    _performed = (action, now);
    final wasAway = away;
    // Tick at once: turning the microphone back on publishes it anew, which
    // takes seconds on a Mac while Apple's voice processing starts up. A
    // different outcome (a microphone that fails) ticks again after.
    final expected = expectedCue(
      action,
      away: away,
      muted: muted,
      serverMuted: serverMuted,
    );
    if (preferences.cues) unawaited(sounds.play(expected));
    switch (action) {
      case CallAction.toggleMute:
        await toggleMute();
      case CallAction.toggleAway:
        await toggleAway();
      case CallAction.mute:
        await setMicrophone(on: false);
      case CallAction.unmute:
        await setMicrophone(on: true);
    }
    final cue = away != wasAway
        ? (away ? Cue.away : Cue.back)
        : (muted ? Cue.mute : Cue.unmute);
    if (preferences.cues && cue != expected) unawaited(sounds.play(cue));
  }

  /// The last shortcut's action and when, see [perform].
  (CallAction, DateTime)? _performed;
  static const _sameKey = Duration(milliseconds: 300);

  /// Steps away or comes back (ADR-0026).
  Future<void> toggleAway() async {
    if (_room == null || state != VoiceState.connected) return;
    if (away) return _comeBack();
    away = true;
    _mutedBeforeAway = muted;
    _tellAway();
    _hearOthers(false);
    if (!muted) {
      muted = true;
      await _unpublish(lk.TrackSource.microphone);
    }
    _refreshMicStates();
  }

  /// Back from away: everyone's sound again, and the microphone as it was
  /// unless [unmute]. A moderator's mute stays.
  Future<void> _comeBack({bool unmute = false}) async {
    away = false;
    _tellAway();
    _hearOthers(true);
    if ((unmute || !_mutedBeforeAway) && muted && !serverMuted) {
      muted = false;
      await _publishMicrophone();
    } else if (unmute && serverMuted) {
      error = _texts.voiceMutedByModerator;
    }
    _refreshMicStates();
  }

  /// Whether [p] stepped away. Our own state is known here first, and on
  /// servers that can't show it, only here.
  bool isAway(Participant p) =>
      p.away || (away && p.session == gateway.sessionId);

  void _tellAway() {
    if (_awayUnsupported) return;
    _awayAsked = true;
    gateway.send('set_away', {'away': away});
  }

  /// Receives everyone's sound (microphones and screen shares), or stops
  /// receiving it. Tracks published while away are dealt with as they come
  /// (see [_connect]).
  void _hearOthers(bool hear) {
    final room = _room;
    if (room == null) return;
    for (final remote in room.remoteParticipants.values) {
      for (final publication in remote.audioTrackPublications) {
        unawaited(hear ? _listen(publication) : publication.unsubscribe());
      }
    }
  }

  Future<void> _listen(lk.RemoteTrackPublication publication) async {
    if (!publication.enabled) await publication.enable();
    await publication.subscribe();
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
      error = _texts.voiceCameraUnavailable;
    }
    // Read the state back: unpublish events fire while the call above runs.
    camera = _room?.localParticipant?.isCameraEnabled() ?? false;
    notifyListeners();
  }

  /// Whether the microphone is cleaned up: by the device where it can,
  /// otherwise as the person chose (WLK-2).
  bool get _processing => processingOn(
    byDevice: inputFilters.byDevice,
    chosen: preferences.processing,
  );

  /// What the microphone goes out with: the channel's quality, as the web
  /// client publishes it, but in stereo only where that brings something
  /// (see [stereoMicrophone]).
  AudioQuality _quality() {
    final audio =
        gateway.channel(channel ?? '')?.channel.audio ??
        const AudioQuality(bitrate: 64000, stereo: false);
    return AudioQuality(
      bitrate: audio.bitrate,
      stereo: stereoMicrophone(
        channelStereo: audio.stereo,
        processing: _processing,
        recordsStereo: Platform.isLinux || Platform.isWindows,
      ),
    );
  }

  /// Whether the microphone went out otherwise than it would now.
  bool get _publishedStale {
    final published = _published;
    if (published == null) return false;
    final (microphone, processing, quality) = published;
    final now = _quality();
    return microphone != preferences.microphone ||
        processing != _processing ||
        quality.bitrate != now.bitrate ||
        quality.stereo != now.stereo;
  }

  lk.AudioCaptureOptions _audioCapture() => lk.AudioCaptureOptions(
    deviceId: preferences.microphone,
    noiseSuppression: _processing,
    echoCancellation: _processing,
    autoGainControl: _processing,
    highPassFilter: _processing,
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
    if (!muted && _publishedStale) await _republishMicrophone();
    final camera = await _device('videoinput', preferences.camera);
    if (camera != null && this.camera) {
      try {
        await room.setVideoInputDevice(camera);
      } catch (e) {
        debugPrint('cannot switch the camera: $e');
        error = _texts.voiceCannotSwitchCamera;
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

  Future<void> _republishMicrophone() async {
    await _unpublish(lk.TrackSource.microphone);
    await _publishMicrophone();
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
  /// through its own dialog). With [sound] where [screenSoundAvailable].
  Future<void> startScreen({
    String? source,
    ScreenQuality quality = ScreenQuality.text,
    bool sound = false,
  }) async {
    final local = _room?.localParticipant;
    if (local == null) return;
    // Android asks first (whole screen or one app), then wants the
    // foreground service running before capture starts.
    if (Platform.isAndroid) {
      if (!await rtc.Helper.requestCapturePermission()) return;
      final name = gateway.channel(channel ?? '')?.channel.name ?? 'Wisetalk';
      if (!await _service.update(channel: name, sharing: true, texts: _texts)) {
        error = _texts.voiceScreenUnavailable;
        notifyListeners();
        return;
      }
    }
    final options = lk.ScreenShareCaptureOptions(
      sourceId: source,
      maxFrameRate: quality.parameters.encoding!.maxFramerate.toDouble(),
      params: quality.parameters,
    );
    try {
      if (sound && screenSoundAvailable) {
        await _shareWithSound(local, options);
      } else {
        await local.setScreenShareEnabled(
          true,
          screenShareCaptureOptions: options,
        );
      }
    } catch (e) {
      // Cancelling the system's share dialog lands here too.
      debugPrint('screen share stopped or refused: $e');
    }
    screen = _room?.localParticipant?.isScreenShareEnabled() ?? false;
    unawaited(_syncService());
    notifyListeners();
  }

  /// What setScreenShareEnabled does with captureScreenAudio, but with the
  /// sound's own publish options: it would publish it as a microphone (the
  /// room's speech settings, named "microphone"). Without sound from the
  /// system (Windows before 10 2004), the picture alone.
  Future<void> _shareWithSound(
    lk.LocalParticipant local,
    lk.ScreenShareCaptureOptions options,
  ) async {
    final tracks = await lk.LocalVideoTrack.createScreenShareTracksWithAudio(
      options,
    );
    final video = tracks.whereType<lk.LocalVideoTrack>().first;
    final audio = tracks.whereType<lk.LocalAudioTrack>().firstOrNull;
    try {
      await local.publishVideoTrack(video);
    } catch (_) {
      for (final track in tracks) {
        await track.stop();
      }
      rethrow;
    }
    if (audio == null) return;
    try {
      await local.publishAudioTrack(audio, publishOptions: _screenSound);
    } catch (e) {
      debugPrint('sharing without sound: $e');
      await audio.stop();
    }
  }

  Future<void> stopScreen() async {
    final local = _room?.localParticipant;
    if (local == null) return;
    try {
      // Takes the screen's sound down with it.
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
    qualities.dispose();
    link.dispose();
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
    away = false;
    _awayAsked = false;
    camera = false;
    screen = false;
    tiles = const [];
    qualities.clear();
    trust?.clear();
    link.reset();
    unawaited(_service.update(channel: null, texts: _texts));
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
      texts: _texts,
    );
  }

  /// For what is shown outside the app's windows, and the errors and names
  /// this makes itself.
  AppLocalizations get _texts => textsFor(preferences.language.value);

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
          ? _texts.videoYou
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
        _reviewKeys(_participants);
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
        final newcomer = Participant.fromJson(
          joined['participant'] as Map<String, dynamic>,
        );
        _reviewKeys([newcomer]);
        _welcome(newcomer);
        if (newcomer.session != gateway.sessionId) _cue(Cue.join);
      case 'voice_left':
        final left = data as Map<String, dynamic>;
        if (left['channel'] != channel) return;
        if (left['session'] == gateway.sessionId) {
          _reset();
        } else {
          unawaited(_rotate());
          _cue(Cue.leave);
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
        if (participant.away == away) _awayAsked = false;
        // Our own Away coming back to us: nothing changed here.
        if (participant.serverMuted == serverMuted) return;
        serverMuted = participant.serverMuted;
        if (serverMuted) {
          muted = true;
          error = _texts.voiceServerMuted;
        } else {
          error = _texts.voiceServerUnmuted;
        }
        _refreshMicStates();
      case 'channel_updated':
        // A new audio quality: publish again with it, as the web client does.
        final view = data as Map<String, dynamic>;
        final updated = (view['channel'] as Map<String, dynamic>)['id'];
        if (updated == channel &&
            state == VoiceState.connected &&
            !muted &&
            _publishedStale) {
          unawaited(_republishMicrophone());
        }
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
        // A known reason is a whole sentence; an older server's English
        // gets a lead-in.
        final reason = _texts.voiceKicked(kicked['reason'] as String? ?? '');
        error = problemText(_texts, kicked['problem'], reason);
        notifyListeners();
      case 'ready':
        // Maybe a newer server after a reconnect: ask again.
        _awayUnsupported = false;
      case 'error':
        final failure = data as Map<String, dynamic>;
        if (failure['code'] == 'chat_key') return;
        if (failure['code'] == 'protocol_mismatch' && _awayAsked) {
          // An older server that can't read set_away. Away goes on working
          // here; others just don't see it.
          _awayAsked = false;
          _awayUnsupported = true;
          return;
        }
        error = problemText(
          _texts,
          failure['problem'],
          failure['message'] as String? ?? '',
        );
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
      final room = _audio.room(
        lk.RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          encryption: lk.E2EEOptions(keyProvider: keys),
          defaultAudioCaptureOptions: _audioCapture(),
        ),
      );
      _room = room;
      _roomEvents = room.createListener()
        ..on<lk.ActiveSpeakersChangedEvent>((e) {
          speaking = {for (final p in e.speakers) p.identity};
          notifyListeners();
        })
        ..on<lk.TrackPublishedEvent>((e) {
          // Away: ask the server not to send the sound that the automatic
          // subscription is about to bring.
          if (away && e.publication.kind == lk.TrackType.AUDIO) {
            unawaited(e.publication.disable());
          }
          _refreshMicStates();
        })
        ..on<lk.TrackUnpublishedEvent>((_) => _refreshMicStates())
        ..on<lk.TrackSubscribedEvent>((e) {
          _quietStats();
          final track = e.track;
          if (track is lk.VideoTrack && !e.publication.muted) {
            _addTile(e.publication, e.participant, track, local: false);
          }
          if (track is lk.AudioTrack) {
            if (away) {
              // Silent at once, then gone: nothing to receive or decode.
              track.mediaStreamTrack.enabled = false;
              unawaited(e.publication.unsubscribe());
            } else {
              _applyVolumes();
            }
          }
        })
        ..on<lk.TrackUnsubscribedEvent>((e) => _removeTile(e.publication.sid))
        ..on<lk.LocalTrackPublishedEvent>((e) {
          _quietStats();
          final track = e.publication.track;
          if (track is lk.LocalVideoTrack) {
            _addTile(e.publication, e.participant, track, local: true);
          }
          _refreshMicStates();
        })
        ..on<lk.LocalTrackUnpublishedEvent>((e) {
          _removeTile(e.publication.sid);
          // The system's own "stop sharing" ends up here, or the shared
          // window closing: only the picture ends, the sound stays
          // published, silent.
          if (e.publication.source == lk.TrackSource.screenShareVideo) {
            screen = false;
            unawaited(_unpublish(lk.TrackSource.screenShareAudio));
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
          // Unmuting may restart the track, and with it the polling.
          _quietStats();
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
        // The server rates everyone's connection every few seconds and
        // LiveKit tells only of changes.
        ..on<lk.ParticipantConnectionQualityUpdatedEvent>(
          (e) => qualities.set(e.participant.identity, e.connectionQuality),
        )
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
      error = _texts.voiceCannotConnect;
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
    final local = room.localParticipant;
    if (local == null) return;
    try {
      await _selectMicrophone();
      // Low bitrates may pause in silence (DTX), RED repeats packets
      // against loss.
      final quality = _quality();
      _audio
        ..stereo = quality.stereo
        ..bitrate = quality.bitrate;
      await local.publishAudioTrack(
        await lk.LocalAudioTrack.create(_audioCapture()),
        publishOptions: lk.AudioPublishOptions(
          encoding: lk.AudioEncoding(maxBitrate: quality.bitrate),
          dtx: quality.bitrate <= 64000,
          red: true,
        ),
      );
      _published = (preferences.microphone, _processing, quality);
      muted = false;
    } catch (e) {
      debugPrint('microphone unavailable: $e');
      muted = true;
      error = _texts.voiceMicrophoneUnavailable;
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

  /// One round of stats for [link]: the microphone's sender, and the
  /// receivers of everything we're subscribed to plus our other senders
  /// (for the ping when the microphone is off). Each getStats() is one
  /// call into WebRTC, made only while the numbers are on screen.
  Future<LinkSample?> _sampleLink(Duration at) async {
    final room = _room;
    final local = room?.localParticipant;
    if (room == null || local == null || state != VoiceState.connected) {
      return null;
    }
    Future<List<rtc.StatsReport>> stats(
      Future<List<rtc.StatsReport>>? asked,
    ) async {
      try {
        return await asked ?? const [];
      } catch (e) {
        // A track that just went away; the next round won't ask for it.
        debugPrint('no stats this time: $e');
        return const [];
      }
    }

    final mic = local
        .getTrackPublicationBySource(lk.TrackSource.microphone)
        ?.track;
    final others = [
      for (final publication in local.trackPublications.values)
        if (publication.source != lk.TrackSource.microphone)
          publication.track?.sender?.getStats(),
      for (final remote in room.remoteParticipants.values)
        for (final publication in remote.trackPublications.values)
          publication.track?.receiver?.getStats(),
    ].nonNulls;
    final results = await Future.wait([
      stats(mic?.sender?.getStats()),
      for (final asked in others) stats(asked),
    ]);
    if (room != _room) return null;
    return readStats(
      at,
      microphone: results.first,
      others: results.skip(1).toList(),
    );
  }

  /// livekit_client polls `getStats()` every two seconds for every track it
  /// starts, only to emit bitrate events nothing here listens to: in a call
  /// of ten that is five calls a second for nothing (WLK-36, ADR-0019). The
  /// SDK starts a track right after the events announcing it, and again
  /// when it restarts one (unmuting, another device), so the sweep runs
  /// once those are done and covers every track. Our own numbers come from
  /// [LinkMonitor], which runs only while something shows them.
  void _quietStats() => Timer.run(() {
    final room = _room;
    if (room == null) return;
    final participants = <lk.Participant>[
      ?room.localParticipant,
      ...room.remoteParticipants.values,
    ];
    for (final participant in participants) {
      for (final publication in participant.trackPublications.values) {
        // Internal, but the only way short of a fork; check it at every
        // livekit_client update: track.dart, startMonitor().
        // ignore: invalid_use_of_internal_member
        publication.track?.stopMonitor();
      }
    }
  });

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
