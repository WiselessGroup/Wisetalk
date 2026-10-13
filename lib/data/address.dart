// Turning what people type into a server's address.

/// The origin of a Wisetalk server from what someone typed:
/// `talk.example.com`, `https://talk.example.com/`, or `localhost:8080`
/// while developing. Only https, except on this computer. `null` if it
/// can't be a server address.
Uri? parseServerAddress(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) {
    text =
        '${_isLocal(text.split(RegExp('[:/]')).first) ? 'http' : 'https'}://$text';
  }
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty || uri.userInfo.isNotEmpty) return null;
  if (uri.hasQuery || uri.hasFragment) return null;
  if (uri.path.isNotEmpty && uri.path != '/') return null;
  final secure = uri.scheme == 'https';
  if (!secure && !(uri.scheme == 'http' && _isLocal(uri.host))) return null;
  return Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
  );
}

bool _isLocal(String host) =>
    host == 'localhost' ||
    host == '127.0.0.1' ||
    host == '::1' ||
    host == '[::1]';

/// How an address is shown: without the https:// people didn't type.
String displayAddress(Uri origin) {
  final text = origin.toString();
  return origin.scheme == 'https' ? text.substring('https://'.length) : text;
}
