// Keeping the app current. On desktop Velopack downloads updates from the
// client's releases in the background and "Restart to Update" applies them
// (the next start does it anyway). On Android the server's download list
// tells of a newer APK, which the browser fetches and the system installs.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/rust/api/update.dart';
import 'api.dart';
import 'servers.dart';

/// This build's version, set by release builds (`--dart-define`); empty
/// while developing, which never asks for updates.
const appVersion = String.fromEnvironment('WISETALK_VERSION');

/// How often a running app looks again; checks cost one small request.
const _every = Duration(hours: 6);

class Updates extends ChangeNotifier {
  Updates(this._server) {
    // Not right at start: the app has better things to do then.
    _timer = Timer(const Duration(seconds: 20), () {
      unawaited(_check());
      _timer = Timer.periodic(_every, (_) => _check());
    });
  }

  /// The server to ask on Android, the one in use; `null` before picking one.
  final Uri? Function() _server;
  Timer? _timer;
  bool _disposed = false;

  /// Desktop: a version downloaded and waiting for [restart].
  String? ready;

  /// Android: a newer version, and where the browser gets it.
  ({String version, Uri url})? available;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    try {
      if (Platform.isAndroid) {
        await _checkAndroid();
      } else if (installedVersion() != null) {
        final version = await downloadUpdate();
        if (version != null && version != ready) {
          debugPrint('Wisetalk $version is downloaded');
          ready = version;
          notifyListeners();
        }
      }
    } catch (e) {
      // Offline, or the releases are unreachable: next time.
      debugPrint('cannot check for updates: $e');
    }
  }

  Future<void> _checkAndroid() async {
    final server = _server();
    if (appVersion.isEmpty || server == null) return;
    final downloads = await Api(server).downloads();
    final latest = downloads.version;
    final apk = downloads.files
        .where((f) => f.platform == 'android')
        .firstOrNull;
    if (latest == null || apk == null || !isNewer(latest, appVersion)) return;
    available = (version: latest, url: Uri.parse(apk.url));
    notifyListeners();
  }

  /// Quits, applies the update and starts the new version.
  Future<void> restart() => restartToUpdate();
}

/// This build's version for people, `dev` while developing.
String get versionName =>
    installedVersion() ?? (appVersion.isEmpty ? 'dev' : appVersion);

final updatesProvider = Provider<Updates>((ref) {
  final updates = Updates(
    () => ref.read(serversProvider).value?.currentServer?.origin,
  );
  ref.onDispose(updates.dispose);
  return updates;
});

/// Whether version [a] comes after [b], both `major.minor.patch`.
@visibleForTesting
bool isNewer(String a, String b) {
  List<int> parts(String v) => [
    for (final p in v.split('-').first.split('.')) int.tryParse(p) ?? 0,
  ];
  final (x, y) = (parts(a), parts(b));
  for (var i = 0; i < 3; i++) {
    final (p, q) = (i < x.length ? x[i] : 0, i < y.length ? y[i] : 0);
    if (p != q) return p > q;
  }
  return false;
}
