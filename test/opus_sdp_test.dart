import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/opus_sdp.dart';

String sdp(List<String> lines) => '${lines.join('\r\n')}\r\n';

final session = [
  'v=0',
  'o=- 4611731400430051336 2 IN IP4 127.0.0.1',
  's=-',
  't=0 0',
  'a=group:BUNDLE 0 1 2',
];

List<String> audio(String mid, {String? fmtp = 'minptime=10;useinbandfec=1'}) =>
    [
      'm=audio 9 UDP/TLS/RTP/SAVPF 111 63',
      'c=IN IP4 0.0.0.0',
      'a=mid:$mid',
      'a=sendonly',
      'a=rtpmap:111 opus/48000/2',
      'a=rtcp-fb:111 transport-cc',
      if (fmtp != null) 'a=fmtp:111 $fmtp',
      'a=rtpmap:63 red/48000/2',
      'a=fmtp:63 111/111',
    ];

final video = [
  'm=video 9 UDP/TLS/RTP/SAVPF 96',
  'c=IN IP4 0.0.0.0',
  'a=mid:2',
  'a=rtpmap:96 VP8/90000',
  'a=fmtp:96 x-google-start-bitrate=900',
];

List<String> fmtpLines(String sdp, String payload) =>
    sdp.split('\r\n').where((l) => l.startsWith('a=fmtp:$payload')).toList();

void main() {
  test('offers stereo Opus in every audio section and nothing else', () {
    final offer = sdp([...session, ...audio('0'), ...audio('1'), ...video]);
    final munged = setOpusParameters(offer, {
      'stereo': '1',
      'sprop-stereo': '1',
    });
    expect(fmtpLines(munged, '111'), [
      'a=fmtp:111 minptime=10;useinbandfec=1;stereo=1;sprop-stereo=1',
      'a=fmtp:111 minptime=10;useinbandfec=1;stereo=1;sprop-stereo=1',
    ]);
    // RED, video and the rest stay as they were, line endings included.
    expect(fmtpLines(munged, '63'), ['a=fmtp:63 111/111', 'a=fmtp:63 111/111']);
    expect(fmtpLines(munged, '96'), ['a=fmtp:96 x-google-start-bitrate=900']);
    expect(munged.replaceAll(';stereo=1;sprop-stereo=1', ''), offer);
  });

  test('replaces a parameter instead of repeating it', () {
    // What the LiveKit server answers for a stereo track.
    final answer = sdp([
      ...session,
      ...audio(
        '0',
        fmtp:
            'minptime=10;useinbandfec=1;stereo=1;'
            'maxaveragebitrate=510000',
      ),
    ]);
    final munged = setOpusParameters(answer, {
      'stereo': '1',
      'maxaveragebitrate': '128000',
    });
    expect(fmtpLines(munged, '111'), [
      'a=fmtp:111 minptime=10;useinbandfec=1;stereo=1;maxaveragebitrate=128000',
    ]);
    expect(setOpusParameters(munged, {'stereo': '1'}), munged);
  });

  test('sprop-stereo is not stereo', () {
    final offer = sdp([...session, ...audio('0', fmtp: 'sprop-stereo=1')]);
    expect(fmtpLines(setOpusParameters(offer, {'stereo': '1'}), '111'), [
      'a=fmtp:111 sprop-stereo=1;stereo=1',
    ]);
  });

  test('adds an fmtp line where Opus has none', () {
    final offer = sdp([...session, ...audio('0', fmtp: null)]);
    final lines = setOpusParameters(offer, {'stereo': '1'}).split('\r\n');
    final rtpmap = lines.indexOf('a=rtpmap:111 opus/48000/2');
    expect(lines[rtpmap + 1], 'a=fmtp:111 stereo=1');
  });

  test('answers stereo only for the tracks offered in stereo', () {
    // The server's offer: mid 1 is a stereo track, mid 0 a mono one.
    final offer = sdp([
      ...session,
      ...audio('0'),
      ...audio('1', fmtp: 'minptime=10;useinbandfec=1;sprop-stereo=1'),
    ]);
    final mids = stereoMids(offer);
    expect(mids, {'1'});

    final answer = sdp([...session, ...audio('0'), ...audio('1')]);
    final munged = setOpusParameters(answer, {
      'stereo': '1',
    }, where: mids.contains);
    expect(fmtpLines(munged, '111'), [
      'a=fmtp:111 minptime=10;useinbandfec=1',
      'a=fmtp:111 minptime=10;useinbandfec=1;stereo=1',
    ]);
  });

  test('finds no stereo where there is none', () {
    expect(stereoMids(sdp([...session, ...audio('0'), ...video])), isEmpty);
    expect(stereoMids(''), isEmpty);
    expect(setOpusParameters('', {'stereo': '1'}), '');
  });
}
