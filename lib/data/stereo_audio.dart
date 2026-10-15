// Stereo Opus for the microphone, which LiveKit's Flutter SDK can't publish
// on its own: it has no stereo publish option and never touches Opus in the
// SDP. The room gets an engine of its own instead, with two hooks the SDK
// takes as constructor arguments, so nothing of it is forked:
//
// - the signal socket marks the microphone's AddTrackRequest TF_STEREO,
//   as the JavaScript SDK does with forceStereo. The server then answers
//   with stereo=1 (the encoder sends two channels) and offers the track to
//   everyone else with sprop-stereo=1, so browsers decode it in stereo;
// - every peer connection goes through StereoPeerConnection, which sets
//   the Opus parameters (see opus_sdp.dart) as the JavaScript SDK does:
//   stereo in the offers and answers it publishes with, and stereo=1 in the
//   answers it subscribes with wherever the server offers a stereo track,
//   without which libwebrtc decodes a browser's stereo as mono.
//
// Engine, SignalClient and the protocol messages aren't exported by
// livekit_client: these hooks import them from its sources, so they need a
// look on every livekit_client upgrade.

// ignore_for_file: implementation_imports

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:livekit_client/src/core/engine.dart' as lk_engine;
import 'package:livekit_client/src/core/signal_client.dart' as lk_signal;
import 'package:livekit_client/src/proto/livekit_models.pb.dart' as lk_models;
import 'package:livekit_client/src/proto/livekit_rtc.pb.dart' as lk_rtc;
import 'package:livekit_client/src/support/websocket.dart' as lk_ws;

import 'opus_sdp.dart';

/// How the microphone goes out of the rooms made by [room]. Read when the
/// track is published and while it negotiates, so set it before publishing.
class StereoAudio {
  /// Two channels instead of one.
  bool stereo = false;

  /// The channel's audio bitrate, which caps the stereo encoder from the
  /// start (the server's answer says 510 kbps).
  int bitrate = 64000;

  lk.Room room(lk.RoomOptions options) => lk.Room(
    engine: lk_engine.Engine(
      connectOptions: const lk.ConnectOptions(),
      roomOptions: options,
      // ignore: invalid_use_of_internal_member
      signalClient: lk_signal.SignalClient(StereoSocket.connector(this)),
      peerConnectionCreate: (configuration, [constraints = const {}]) async =>
          StereoPeerConnection(
            await rtc.createPeerConnection(configuration, constraints),
            this,
          ),
    ),
  );
}

/// The signal connection to LiveKit, marking the microphone's AddTrackRequest
/// on its way out: SignalClient sends it from an extension method, which
/// can't be overridden.
@visibleForTesting
class StereoSocket extends lk_ws.LiveKitWebSocket {
  StereoSocket(this._socket, this._audio) {
    onDispose(() async => _socket.dispose());
  }

  final lk_ws.LiveKitWebSocket _socket;
  final StereoAudio _audio;

  static lk_ws.WebSocketConnector connector(StereoAudio audio) =>
      (uri, {options, headers, networkOptions}) async => StereoSocket(
        await lk_ws.LiveKitWebSocket.connect(
          uri,
          options: options,
          headers: headers,
          networkOptions: networkOptions,
        ),
        audio,
      );

  @override
  void send(List<int> data) {
    if (_audio.stereo) {
      final request = lk_rtc.SignalRequest.fromBuffer(data);
      if (request.hasAddTrack()) {
        final track = request.addTrack;
        if (track.type == lk_models.TrackType.AUDIO &&
            track.source == lk_models.TrackSource.MICROPHONE &&
            !track.audioFeatures.contains(
              lk_models.AudioTrackFeature.TF_STEREO,
            )) {
          track.audioFeatures.add(lk_models.AudioTrackFeature.TF_STEREO);
          data = request.writeToBuffer();
        }
      }
    }
    _socket.send(data);
  }
}

/// A peer connection that sets the Opus parameters of what it offers and
/// answers, and of the answers it gets; the rest passes through.
///
/// Which side it is follows from the SDP: the connection that offers is the
/// one LiveKit publishes with, the one that answers subscribes.
@visibleForTesting
class StereoPeerConnection implements rtc.RTCPeerConnection {
  StereoPeerConnection(this._pc, this._audio);

  final rtc.RTCPeerConnection _pc;
  final StereoAudio _audio;

  /// Mids of the tracks the server sends in stereo, from its last offer.
  Set<String> _stereoMids = const {};

  @override
  Future<rtc.RTCSessionDescription> createOffer([
    Map<String, dynamic>? constraints,
  ]) async {
    // Left out, the platform side picks its own defaults.
    final offer = constraints == null
        ? await _pc.createOffer()
        : await _pc.createOffer(constraints);
    final sdp = offer.sdp;
    if (!_audio.stereo || sdp == null) return offer;
    return rtc.RTCSessionDescription(
      setOpusParameters(sdp, const {'stereo': '1', 'sprop-stereo': '1'}),
      offer.type,
    );
  }

  @override
  Future<rtc.RTCSessionDescription> createAnswer([
    Map<String, dynamic>? constraints,
  ]) async {
    final answer = constraints == null
        ? await _pc.createAnswer()
        : await _pc.createAnswer(constraints);
    final sdp = answer.sdp;
    final mids = _stereoMids;
    if (mids.isEmpty || sdp == null) return answer;
    return rtc.RTCSessionDescription(
      setOpusParameters(sdp, const {'stereo': '1'}, where: mids.contains),
      answer.type,
    );
  }

  @override
  Future<void> setRemoteDescription(rtc.RTCSessionDescription description) {
    final sdp = description.sdp;
    if (sdp == null) return _pc.setRemoteDescription(description);
    if (description.type == 'offer') {
      _stereoMids = stereoMids(sdp);
    } else if (description.type == 'answer' && _audio.stereo) {
      return _pc.setRemoteDescription(
        rtc.RTCSessionDescription(
          setOpusParameters(sdp, {
            'stereo': '1',
            'maxaveragebitrate': '${_audio.bitrate}',
          }),
          description.type,
        ),
      );
    }
    return _pc.setRemoteDescription(description);
  }

  // Everything else as the real connection does it.

  @override
  Function(rtc.RTCSignalingState state)? get onSignalingState =>
      _pc.onSignalingState;
  @override
  set onSignalingState(Function(rtc.RTCSignalingState state)? f) =>
      _pc.onSignalingState = f;

  @override
  Function(rtc.RTCPeerConnectionState state)? get onConnectionState =>
      _pc.onConnectionState;
  @override
  set onConnectionState(Function(rtc.RTCPeerConnectionState state)? f) =>
      _pc.onConnectionState = f;

  @override
  Function(rtc.RTCIceGatheringState state)? get onIceGatheringState =>
      _pc.onIceGatheringState;
  @override
  set onIceGatheringState(Function(rtc.RTCIceGatheringState state)? f) =>
      _pc.onIceGatheringState = f;

  @override
  Function(rtc.RTCIceConnectionState state)? get onIceConnectionState =>
      _pc.onIceConnectionState;
  @override
  set onIceConnectionState(Function(rtc.RTCIceConnectionState state)? f) =>
      _pc.onIceConnectionState = f;

  @override
  Function(rtc.RTCIceCandidate candidate)? get onIceCandidate =>
      _pc.onIceCandidate;
  @override
  set onIceCandidate(Function(rtc.RTCIceCandidate candidate)? f) =>
      _pc.onIceCandidate = f;

  @override
  Function(rtc.MediaStream stream)? get onAddStream => _pc.onAddStream;
  @override
  set onAddStream(Function(rtc.MediaStream stream)? f) => _pc.onAddStream = f;

  @override
  Function(rtc.MediaStream stream)? get onRemoveStream => _pc.onRemoveStream;
  @override
  set onRemoveStream(Function(rtc.MediaStream stream)? f) =>
      _pc.onRemoveStream = f;

  @override
  Function(rtc.MediaStream stream, rtc.MediaStreamTrack track)?
  get onAddTrack => _pc.onAddTrack;
  @override
  set onAddTrack(
    Function(rtc.MediaStream stream, rtc.MediaStreamTrack track)? f,
  ) => _pc.onAddTrack = f;

  @override
  Function(rtc.MediaStream stream, rtc.MediaStreamTrack track)?
  get onRemoveTrack => _pc.onRemoveTrack;
  @override
  set onRemoveTrack(
    Function(rtc.MediaStream stream, rtc.MediaStreamTrack track)? f,
  ) => _pc.onRemoveTrack = f;

  @override
  Function(rtc.RTCDataChannel channel)? get onDataChannel => _pc.onDataChannel;
  @override
  set onDataChannel(Function(rtc.RTCDataChannel channel)? f) =>
      _pc.onDataChannel = f;

  @override
  Function()? get onRenegotiationNeeded => _pc.onRenegotiationNeeded;
  @override
  set onRenegotiationNeeded(Function()? f) => _pc.onRenegotiationNeeded = f;

  @override
  Function(rtc.RTCTrackEvent event)? get onTrack => _pc.onTrack;
  @override
  set onTrack(Function(rtc.RTCTrackEvent event)? f) => _pc.onTrack = f;

  @override
  rtc.RTCSignalingState? get signalingState => _pc.signalingState;
  @override
  Future<rtc.RTCSignalingState?> getSignalingState() => _pc.getSignalingState();

  @override
  rtc.RTCIceGatheringState? get iceGatheringState => _pc.iceGatheringState;
  @override
  Future<rtc.RTCIceGatheringState?> getIceGatheringState() =>
      _pc.getIceGatheringState();

  @override
  rtc.RTCIceConnectionState? get iceConnectionState => _pc.iceConnectionState;
  @override
  Future<rtc.RTCIceConnectionState?> getIceConnectionState() =>
      _pc.getIceConnectionState();

  @override
  rtc.RTCPeerConnectionState? get connectionState => _pc.connectionState;
  @override
  Future<rtc.RTCPeerConnectionState?> getConnectionState() =>
      _pc.getConnectionState();

  @override
  Future<void> dispose() => _pc.dispose();

  @override
  Map<String, dynamic> get getConfiguration => _pc.getConfiguration;
  @override
  Future<void> setConfiguration(Map<String, dynamic> configuration) =>
      _pc.setConfiguration(configuration);

  @override
  Future<void> addStream(rtc.MediaStream stream) => _pc.addStream(stream);
  @override
  Future<void> removeStream(rtc.MediaStream stream) => _pc.removeStream(stream);

  @override
  Future<rtc.RTCSessionDescription?> getLocalDescription() =>
      _pc.getLocalDescription();
  @override
  Future<void> setLocalDescription(rtc.RTCSessionDescription description) =>
      _pc.setLocalDescription(description);
  @override
  Future<rtc.RTCSessionDescription?> getRemoteDescription() =>
      _pc.getRemoteDescription();

  @override
  Future<void> addCandidate(rtc.RTCIceCandidate candidate) =>
      _pc.addCandidate(candidate);

  @override
  Future<List<rtc.StatsReport>> getStats([rtc.MediaStreamTrack? track]) =>
      _pc.getStats(track);

  @override
  List<rtc.MediaStream?> getLocalStreams() => _pc.getLocalStreams();
  @override
  List<rtc.MediaStream?> getRemoteStreams() => _pc.getRemoteStreams();

  @override
  Future<rtc.RTCDataChannel> createDataChannel(
    String label,
    rtc.RTCDataChannelInit dataChannelDict,
  ) => _pc.createDataChannel(label, dataChannelDict);

  @override
  Future<void> restartIce() => _pc.restartIce();
  @override
  Future<void> close() => _pc.close();

  @override
  rtc.RTCDTMFSender createDtmfSender(rtc.MediaStreamTrack track) =>
      _pc.createDtmfSender(track);

  @override
  Future<List<rtc.RTCRtpSender>> getSenders() => _pc.getSenders();
  @override
  Future<List<rtc.RTCRtpSender>> get senders => _pc.senders;
  @override
  Future<List<rtc.RTCRtpReceiver>> getReceivers() => _pc.getReceivers();
  @override
  Future<List<rtc.RTCRtpReceiver>> get receivers => _pc.receivers;
  @override
  Future<List<rtc.RTCRtpTransceiver>> getTransceivers() =>
      _pc.getTransceivers();
  @override
  Future<List<rtc.RTCRtpTransceiver>> get transceivers => _pc.transceivers;

  @override
  Future<rtc.RTCRtpSender> addTrack(
    rtc.MediaStreamTrack track, [
    rtc.MediaStream? stream,
  ]) => stream == null ? _pc.addTrack(track) : _pc.addTrack(track, stream);
  @override
  Future<bool> removeTrack(rtc.RTCRtpSender sender) => _pc.removeTrack(sender);

  @override
  Future<rtc.RTCRtpTransceiver> addTransceiver({
    rtc.MediaStreamTrack? track,
    rtc.RTCRtpMediaType? kind,
    rtc.RTCRtpTransceiverInit? init,
  }) =>
      // The interface types these as non-null, the platform side takes each
      // as optional: hand them over exactly as given.
      (_pc as dynamic).addTransceiver(track: track, kind: kind, init: init)
          as Future<rtc.RTCRtpTransceiver>;
}
