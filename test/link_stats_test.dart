import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show StatsReport;
import 'package:wisetalk/data/link_stats.dart';

StatsReport report(String id, String type, Map<String, Object?> values) =>
    StatsReport(id, type, 0, values);

/// What libwebrtc answers for the microphone's sender: its stream, the
/// codec, the server's receiver report and the transport's chosen pair.
List<StatsReport> microphone({int bytesSent = 10000, double rtt = 0.042}) => [
  report('OT01A1', 'outbound-rtp', {
    'kind': 'audio',
    'bytesSent': bytesSent,
    'packetsSent': 500,
    'codecId': 'COT01_111',
    'transportId': 'T01',
  }),
  report('COT01_111', 'codec', {'mimeType': 'audio/opus', 'clockRate': 48000}),
  report('RI01A1', 'remote-inbound-rtp', {
    'kind': 'audio',
    'fractionLost': 0.015,
    'jitter': 0.003,
    'roundTripTime': 0.05,
  }),
  report('T01', 'transport', {'selectedCandidatePairId': 'CP01'}),
  report('CP01', 'candidate-pair', {
    'state': 'succeeded',
    'nominated': true,
    'currentRoundTripTime': rtt,
  }),
  // Another pair still being checked: not the one in use.
  report('CP02', 'candidate-pair', {
    'state': 'in-progress',
    'currentRoundTripTime': 0.3,
  }),
];

/// A receiver's answer for one incoming stream.
List<StatsReport> receiver(
  String id, {
  required int lost,
  required int received,
  String kind = 'audio',
  double jitter = 0.004,
}) => [
  report(id, 'inbound-rtp', {
    'kind': kind,
    'packetsLost': lost,
    'packetsReceived': received,
    'jitter': jitter,
  }),
  report('T02', 'transport', {'selectedCandidatePairId': 'CP03'}),
  report('CP03', 'candidate-pair', {
    'state': 'succeeded',
    'nominated': true,
    'currentRoundTripTime': 0.040,
  }),
];

void main() {
  test('reads ping, outgoing loss, jitter and codec from one round', () {
    final stats = compareStats(
      readStats(Duration.zero, microphone: microphone()),
      null,
    );
    expect(stats.ping, 42);
    expect(stats.outgoingLoss, closeTo(1.5, 1e-9));
    expect(stats.codec, 'Opus');
    expect(stats.microphone, isTrue);
    // Nobody to hear: the jitter is the server's view of our microphone.
    expect(stats.jitter, 3);
    // These need a round before.
    expect(stats.incomingLoss, isNull);
    expect(stats.bitrate, isNull);
  });

  test('counts incoming loss and bitrate between two rounds', () {
    final before = readStats(
      Duration.zero,
      microphone: microphone(bytesSent: 10000),
      others: [receiver('IA1', lost: 10, received: 1000)],
    );
    final now = readStats(
      const Duration(seconds: 1),
      microphone: microphone(bytesSent: 16000),
      others: [receiver('IA1', lost: 13, received: 1097)],
    );
    final stats = compareStats(now, before);
    // 3 lost out of 3 + 97.
    expect(stats.incomingLoss, closeTo(3, 1e-9));
    // 6000 bytes in a second.
    expect(stats.bitrate, 48);
    expect(stats.loss, closeTo(3, 1e-9));
  });

  test('sums incoming loss over every stream there both times', () {
    final before = readStats(
      Duration.zero,
      others: [
        receiver('IA1', lost: 0, received: 100),
        receiver('IV1', lost: 0, received: 100, kind: 'video'),
      ],
    );
    final now = readStats(
      const Duration(seconds: 1),
      others: [
        receiver('IA1', lost: 1, received: 150),
        receiver('IV1', lost: 9, received: 240, kind: 'video'),
        // Came in since: nothing to compare with yet.
        receiver('IA2', lost: 500, received: 10),
      ],
    );
    // 10 lost out of 10 + 190.
    expect(compareStats(now, before).incomingLoss, closeTo(5, 1e-9));
  });

  test('takes the worst incoming audio jitter', () {
    final sample = readStats(
      Duration.zero,
      microphone: microphone(),
      others: [
        receiver('IA1', lost: 0, received: 1, jitter: 0.002),
        receiver('IA2', lost: 0, received: 1, jitter: 0.021),
        receiver('IV1', lost: 0, received: 1, jitter: 0.5, kind: 'video'),
      ],
    );
    expect(compareStats(sample, null).jitter, 21);
  });

  test('ignores packetsLost going back', () {
    final before = readStats(
      Duration.zero,
      others: [receiver('IA1', lost: 5, received: 100)],
    );
    final now = readStats(
      const Duration(seconds: 1),
      others: [receiver('IA1', lost: 4, received: 200)],
    );
    expect(compareStats(now, before).incomingLoss, 0);
  });

  test('takes the ping from a receiver while the microphone is off', () {
    final stats = compareStats(
      readStats(Duration.zero, others: [receiver('IA1', lost: 0, received: 1)]),
      null,
    );
    expect(stats.ping, 40);
    expect(stats.microphone, isFalse);
    expect(stats.outgoingLoss, isNull);
    expect(stats.codec, isNull);
  });

  test('finds the pair in use without a transport report', () {
    final reports = [
      for (final r in microphone())
        if (r.type != 'transport') r,
    ];
    expect(
      compareStats(readStats(Duration.zero, microphone: reports), null).ping,
      42,
    );
  });

  test('reads numbers that came as strings', () {
    final stats = compareStats(
      readStats(
        Duration.zero,
        microphone: [
          report('RI', 'remote-inbound-rtp', {
            'fractionLost': '0.25',
            'roundTripTime': '0.1',
          }),
        ],
      ),
      null,
    );
    expect(stats.outgoingLoss, closeTo(25, 1e-9));
    expect(stats.ping, 100);
  });

  test('knows nothing from nothing', () {
    final stats = compareStats(readStats(Duration.zero), null);
    expect(stats.ping, isNull);
    expect(stats.loss, isNull);
    expect(stats.jitter, isNull);
    expect(stats.microphone, isFalse);
  });

  test('names codecs', () {
    expect(codecName('audio/opus'), 'Opus');
    expect(codecName('audio/red'), 'Opus + RED');
    expect(codecName(null), isNull);
  });

  test('formats numbers', () {
    expect(formatMs(42), '42 ms');
    expect(formatMs(null), '—');
    expect(formatLoss(0), '0.0%');
    expect(formatLoss(2.345), '2.3%');
    expect(formatLoss(12.6), '13%');
    expect(formatLoss(null), '—');
  });
}
