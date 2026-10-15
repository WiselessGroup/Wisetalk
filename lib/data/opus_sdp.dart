// Opus parameters in session descriptions. LiveKit's Flutter SDK leaves
// Opus as libwebrtc offers it, mono, where its JavaScript SDK (and so the
// web client) munges the SDP for stereo; these do the same for the app.
//
// libwebrtc sets up the Opus encoder from the remote description (stereo=1
// there: send two channels; maxaveragebitrate: the starting bitrate) and the
// decoder from the local one (stereo=1 there: decode two channels, mono
// otherwise). sprop-stereo=1 tells the other end the sender sends stereo;
// the LiveKit server writes it into its offers for tracks published as
// stereo.

/// [sdp] with [parameters] set on the Opus format of every audio section, or
/// of those whose mid [where] accepts. A section without an fmtp line for
/// Opus gets one.
String setOpusParameters(
  String sdp,
  Map<String, String> parameters, {
  bool Function(String? mid)? where,
}) {
  final eol = sdp.contains('\r\n') ? '\r\n' : '\n';
  final lines = sdp.split(eol);
  final out = <String>[];
  var start = 0;
  while (start < lines.length) {
    var end = start + 1;
    while (end < lines.length && !lines[end].startsWith('m=')) {
      end++;
    }
    final section = lines.sublist(start, end);
    if (section.first.startsWith('m=audio') &&
        (where == null || where(_mid(section)))) {
      _setInSection(section, parameters);
    }
    out.addAll(section);
    start = end;
  }
  return out.join(eol);
}

/// Mids of the audio sections whose Opus is declared stereo by its sender
/// (sprop-stereo=1).
Set<String> stereoMids(String sdp) {
  final lines = sdp.split(RegExp(r'\r?\n'));
  final mids = <String>{};
  var start = 0;
  while (start < lines.length) {
    var end = start + 1;
    while (end < lines.length && !lines[end].startsWith('m=')) {
      end++;
    }
    final section = lines.sublist(start, end);
    final mid = _mid(section);
    final payload = _opusPayload(section);
    if (section.first.startsWith('m=audio') && mid != null && payload != null) {
      final fmtp = section.where((l) => l.startsWith('a=fmtp:$payload '));
      if (fmtp.any((l) => _parameters(l)['sprop-stereo'] == '1')) mids.add(mid);
    }
    start = end;
  }
  return mids;
}

String? _mid(List<String> section) {
  for (final line in section) {
    if (line.startsWith('a=mid:')) return line.substring(6).trim();
  }
  return null;
}

final _opusRtpmap = RegExp(r'^a=rtpmap:(\d+) opus/', caseSensitive: false);

String? _opusPayload(List<String> section) {
  for (final line in section) {
    final match = _opusRtpmap.firstMatch(line);
    if (match != null) return match.group(1);
  }
  return null;
}

/// The key=value pairs of an fmtp line, in order.
Map<String, String> _parameters(String fmtp) {
  final space = fmtp.indexOf(' ');
  if (space < 0) return {};
  return {
    for (final pair in fmtp.substring(space + 1).split(';'))
      if (pair.trim().isNotEmpty)
        pair.split('=').first.trim(): pair.contains('=')
            ? pair.substring(pair.indexOf('=') + 1).trim()
            : '',
  };
}

void _setInSection(List<String> section, Map<String, String> parameters) {
  final payload = _opusPayload(section);
  if (payload == null) return;
  final prefix = 'a=fmtp:$payload';
  final index = section.indexWhere(
    (l) => l == prefix || l.startsWith('$prefix '),
  );
  final merged = {
    if (index >= 0) ..._parameters(section[index]),
    ...parameters,
  };
  final line =
      '$prefix ${merged.entries.map((e) => e.value.isEmpty ? e.key : '${e.key}=${e.value}').join(';')}';
  if (index >= 0) {
    section[index] = line;
  } else {
    final rtpmap = section.indexWhere((l) => _opusRtpmap.hasMatch(l));
    section.insert(rtpmap + 1, line);
  }
}
