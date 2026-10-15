// ignore_for_file: implementation_imports

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/src/proto/livekit_models.pb.dart' as lk_models;
import 'package:livekit_client/src/proto/livekit_rtc.pb.dart' as lk_rtc;
import 'package:livekit_client/src/support/websocket.dart' as lk_ws;
import 'package:wisetalk/data/stereo_audio.dart';

class _Socket extends lk_ws.LiveKitWebSocket {
  final sent = <lk_rtc.SignalRequest>[];

  @override
  void send(List<int> data) => sent.add(lk_rtc.SignalRequest.fromBuffer(data));
}

/// Hands out canned descriptions and keeps the remote ones it gets.
class _PeerConnection extends Fake implements rtc.RTCPeerConnection {
  _PeerConnection(this.sdp);

  final String sdp;
  final remote = <rtc.RTCSessionDescription>[];

  @override
  Future<rtc.RTCSessionDescription> createOffer([
    Map<String, dynamic>? constraints,
  ]) async => rtc.RTCSessionDescription(sdp, 'offer');

  @override
  Future<rtc.RTCSessionDescription> createAnswer([
    Map<String, dynamic>? constraints,
  ]) async => rtc.RTCSessionDescription(sdp, 'answer');

  @override
  Future<void> setRemoteDescription(
    rtc.RTCSessionDescription description,
  ) async => remote.add(description);
}

String section(String mid, String fmtp) => [
  'm=audio 9 UDP/TLS/RTP/SAVPF 111',
  'a=mid:$mid',
  'a=rtpmap:111 opus/48000/2',
  'a=fmtp:111 $fmtp',
  '',
].join('\r\n');

lk_rtc.SignalRequest addTrack(
  lk_models.TrackType type,
  lk_models.TrackSource source,
) => lk_rtc.SignalRequest(
  addTrack: lk_rtc.AddTrackRequest(cid: 'c', type: type, source: source),
);

void main() {
  test('marks the microphone stereo, and only it', () {
    final socket = _Socket();
    final audio = StereoAudio();
    final stereo = StereoSocket(socket, audio);
    final microphone = addTrack(
      lk_models.TrackType.AUDIO,
      lk_models.TrackSource.MICROPHONE,
    );
    final camera = addTrack(
      lk_models.TrackType.VIDEO,
      lk_models.TrackSource.CAMERA,
    );

    stereo.send(microphone.writeToBuffer());
    audio.stereo = true;
    stereo.send(microphone.writeToBuffer());
    stereo.send(camera.writeToBuffer());
    stereo.send(
      lk_rtc.SignalRequest(leave: lk_rtc.LeaveRequest()).writeToBuffer(),
    );

    expect(socket.sent.map((r) => r.addTrack.audioFeatures.toList()), [
      isEmpty,
      [lk_models.AudioTrackFeature.TF_STEREO],
      isEmpty,
      isEmpty,
    ]);
    expect(socket.sent.last.hasLeave(), isTrue);
  });

  test('publishes in stereo while the microphone is stereo', () async {
    final audio = StereoAudio()..bitrate = 128000;
    final inner = _PeerConnection(section('0', 'minptime=10'));
    final pc = StereoPeerConnection(inner, audio);

    expect((await pc.createOffer()).sdp, inner.sdp);
    audio.stereo = true;
    final offer = await pc.createOffer();
    expect(offer.type, 'offer');
    expect(
      offer.sdp,
      contains('a=fmtp:111 minptime=10;stereo=1;sprop-stereo=1'),
    );

    await pc.setRemoteDescription(
      rtc.RTCSessionDescription(
        section('0', 'minptime=10;stereo=1;maxaveragebitrate=510000'),
        'answer',
      ),
    );
    expect(
      inner.remote.single.sdp,
      contains('a=fmtp:111 minptime=10;stereo=1;maxaveragebitrate=128000'),
    );
  });

  test('subscribes in stereo to what the server sends in stereo', () async {
    final audio = StereoAudio();
    final inner = _PeerConnection(
      section('0', 'minptime=10') + section('1', 'minptime=10'),
    );
    final pc = StereoPeerConnection(inner, audio);

    expect((await pc.createAnswer()).sdp, inner.sdp);
    await pc.setRemoteDescription(
      rtc.RTCSessionDescription(
        section('0', 'minptime=10') +
            section('1', 'minptime=10;sprop-stereo=1'),
        'offer',
      ),
    );
    final answer = await pc.createAnswer();
    expect(answer.type, 'answer');
    expect(
      answer.sdp,
      section('0', 'minptime=10') + section('1', 'minptime=10;stereo=1'),
    );
  });
}
