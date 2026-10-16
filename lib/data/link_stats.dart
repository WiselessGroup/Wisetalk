// The call's connection in numbers: ping, loss both ways, jitter, and the
// microphone's codec and bitrate, read from WebRTC's getStats(). Pure: what
// the reports say goes in, numbers come out, so it's tested without a call.
//
// The reports come from the microphone's sender and from the receivers of
// the tracks we are subscribed to. WebRTC answers a sender's or receiver's
// getStats() with its RTP stream and everything that stream refers to: the
// codec, the server's receiver report (remote-inbound-rtp) and the
// transport with its selected candidate pair, which carries the ping.

import 'package:flutter_webrtc/flutter_webrtc.dart' show StatsReport;

import '../l10n/app_localizations.dart';

/// Packets of one incoming stream so far.
typedef Packets = ({int lost, int received});

/// One round of getStats(), before it's compared with the round before.
class LinkSample {
  const LinkSample({
    required this.at,
    this.rtt,
    this.outgoingLoss,
    this.outgoingJitter,
    this.incomingJitter,
    this.codec,
    this.micBytes,
    this.incoming = const {},
  });

  /// When the round was taken, on any clock that only goes forward.
  final Duration at;

  /// Round trip to the media server, seconds.
  final double? rtt;

  /// Share of the microphone's packets the server didn't get, 0 to 1, from
  /// its last receiver report.
  final double? outgoingLoss;

  /// Jitter of the microphone as the server receives it, seconds.
  final double? outgoingJitter;

  /// The worst jitter among the voices we receive, seconds.
  final double? incomingJitter;

  /// The microphone's codec as WebRTC names it, e.g. `audio/opus`.
  final String? codec;

  /// Bytes the microphone has sent; `null` when nothing is published.
  final int? micBytes;

  /// Every stream we receive, by its stats id.
  final Map<String, Packets> incoming;
}

/// What the popover and the numbers next to the icon show. `null` is
/// unknown, shown as a dash.
class LinkStats {
  const LinkStats({
    this.ping,
    this.outgoingLoss,
    this.incomingLoss,
    this.jitter,
    this.codec,
    this.bitrate,
    this.microphone = false,
  });

  /// Milliseconds.
  final int? ping;

  /// Percent.
  final double? outgoingLoss;
  final double? incomingLoss;

  /// Milliseconds.
  final int? jitter;

  /// e.g. `Opus`.
  final String? codec;

  /// The microphone's, kbit/s.
  final int? bitrate;

  /// Whether a microphone is published at all.
  final bool microphone;

  /// The worse of the two losses, for the numbers next to the icon.
  double? get loss => switch ((outgoingLoss, incomingLoss)) {
    (final a?, final b?) => a > b ? a : b,
    (final a?, null) => a,
    (null, final b?) => b,
    (null, null) => null,
  };
}

double? _number(Object? value) => switch (value) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

int? _integer(Object? value) => _number(value)?.round();

/// The selected candidate pair's round trip, else the server's receiver
/// report's, in seconds.
double? _rtt(List<StatsReport> reports) {
  final byId = {for (final r in reports) r.id: r};
  for (final transport in reports.where((r) => r.type == 'transport')) {
    final pair = byId[transport.values['selectedCandidatePairId']];
    final rtt = _number(pair?.values['currentRoundTripTime']);
    if (rtt != null) return rtt;
  }
  // Android leaves the transport out of a sender's report at times.
  for (final pair in reports.where((r) => r.type == 'candidate-pair')) {
    final values = pair.values;
    final selected = values['nominated'] == true || values['selected'] == true;
    final rtt = _number(values['currentRoundTripTime']);
    if (selected && values['state'] == 'succeeded' && rtt != null) return rtt;
  }
  for (final report in reports.where((r) => r.type == 'remote-inbound-rtp')) {
    final rtt = _number(report.values['roundTripTime']);
    if (rtt != null) return rtt;
  }
  return null;
}

/// Reads one round of reports: [microphone] from the microphone's sender
/// (empty when it's off), [others] from every other sender and receiver.
LinkSample readStats(
  Duration at, {
  List<StatsReport> microphone = const [],
  List<List<StatsReport>> others = const [],
}) {
  double? outgoingLoss;
  double? outgoingJitter;
  String? codec;
  int? micBytes;
  final byId = {for (final r in microphone) r.id: r};
  for (final report in microphone) {
    final values = report.values;
    switch (report.type) {
      case 'outbound-rtp':
        micBytes = (micBytes ?? 0) + (_integer(values['bytesSent']) ?? 0);
        final mime = byId[values['codecId']]?.values['mimeType'];
        if (mime is String) codec = mime;
      case 'remote-inbound-rtp':
        outgoingLoss ??= _number(values['fractionLost']);
        outgoingJitter ??= _number(values['jitter']);
    }
  }
  // An older libwebrtc may leave out the codecId.
  codec ??= microphone
      .where((r) => r.type == 'codec')
      .map((r) => r.values['mimeType'])
      .whereType<String>()
      .firstOrNull;

  double? incomingJitter;
  final incoming = <String, Packets>{};
  for (final reports in others) {
    for (final report in reports.where((r) => r.type == 'inbound-rtp')) {
      final values = report.values;
      incoming[report.id] = (
        lost: _integer(values['packetsLost']) ?? 0,
        received: _integer(values['packetsReceived']) ?? 0,
      );
      final jitter = _number(values['jitter']);
      if (values['kind'] == 'audio' &&
          jitter != null &&
          (incomingJitter == null || jitter > incomingJitter)) {
        incomingJitter = jitter;
      }
    }
  }

  return LinkSample(
    at: at,
    rtt: _rtt(microphone) ?? others.map(_rtt).nonNulls.firstOrNull,
    outgoingLoss: outgoingLoss,
    outgoingJitter: outgoingJitter,
    incomingJitter: incomingJitter,
    codec: codec,
    micBytes: micBytes,
    incoming: incoming,
  );
}

/// `audio/opus` as `Opus`. LiveKit sends Opus inside RED (redundant
/// packets against loss) when the other side takes it.
String? codecName(String? mime) {
  if (mime == null || mime.isEmpty) return null;
  final name = mime.split('/').last;
  if (name.toLowerCase() == 'red') return 'Opus + RED';
  return name[0].toUpperCase() + name.substring(1);
}

/// The numbers for [now]. Incoming loss and the bitrate are counted since
/// [before], the round a moment ago, and stay unknown without it.
LinkStats compareStats(LinkSample now, LinkSample? before) {
  double? incomingLoss;
  int? bitrate;
  if (before != null) {
    var lost = 0;
    var received = 0;
    for (final MapEntry(:key, :value) in now.incoming.entries) {
      final was = before.incoming[key];
      if (was == null) continue;
      // Duplicates and late packets can take packetsLost back a little.
      final newlyLost = value.lost - was.lost;
      final newlyReceived = value.received - was.received;
      if (newlyLost > 0) lost += newlyLost;
      if (newlyReceived > 0) received += newlyReceived;
    }
    if (lost + received > 0) incomingLoss = 100 * lost / (lost + received);

    final seconds = (now.at - before.at).inMicroseconds / 1e6;
    final sent = now.micBytes;
    final sentBefore = before.micBytes;
    if (sent != null &&
        sentBefore != null &&
        sent >= sentBefore &&
        seconds > 0) {
      bitrate = ((sent - sentBefore) * 8 / seconds / 1000).round();
    }
  }
  final jitter = now.incomingJitter ?? now.outgoingJitter;
  return LinkStats(
    ping: now.rtt == null ? null : (now.rtt! * 1000).round(),
    outgoingLoss: now.outgoingLoss == null ? null : now.outgoingLoss! * 100,
    incomingLoss: incomingLoss,
    jitter: jitter == null ? null : (jitter * 1000).round(),
    codec: codecName(now.codec),
    bitrate: bitrate,
    microphone: now.micBytes != null,
  );
}

/// `42 ms` in [texts]' language, or a dash.
String formatMs(int? ms, {AppLocalizations? texts}) =>
    ms == null ? '—' : texts?.connectionMilliseconds(ms) ?? '$ms ms';

/// `0.3%` under ten percent, `12%` above, or a dash.
String formatLoss(double? percent) => switch (percent) {
  null => '—',
  < 10 => '${percent.toStringAsFixed(1)}%',
  _ => '${percent.round()}%',
};
