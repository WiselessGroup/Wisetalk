// Keeping the app current. On desktop Velopack downloads updates from the
// client's releases in the background and "Restart to Update" applies them
// (the next start does it anyway). On Android, and on a desktop copy
// Velopack didn't install, the server's download list tells of a newer
// version, which the browser fetches.

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

  /// The server whose download list to read, the one in use; `null` before
  /// picking one.
  final Uri? Function() _server;
  Timer? _timer;
  bool _disposed = false;

  /// Desktop: a version downloaded and waiting for [restart].
  String? ready;

  /// Without Velopack (Android, say): a newer version, and where the
  /// browser gets it.
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
      await _lookup();
    } catch (e) {
      // Offline, or the releases are unreachable: next time.
      debugPrint('cannot check for updates: $e');
    }
  }

  /// Looks right away, for "Check for Updates"; says what it found.
  Future<String> checkNow() async {
    if (appVersion.isEmpty && installedVersion() == null) {
      return 'This build of Wisetalk doesn’t update itself.';
    }
    try {
      await _lookup();
    } catch (e) {
      debugPrint('cannot check for updates: $e');
      return 'Cannot check for updates. Try again later.';
    }
    if (ready case final version?) {
      return 'Wisetalk $version is ready: Restart to Update.';
    }
    if (available case (:final version, url: _)?) {
      return 'Wisetalk $version is out: Update to $version.';
    }
    return 'Wisetalk $versionName is the latest.';
  }

  Future<void> _lookup() async {
    if (Platform.isAndroid) {
      await _checkDownloads('android');
    } else if (installedVersion() != null) {
      final version = await downloadUpdate();
      if (version != null && version != ready) {
        debugPrint('Wisetalk $version is downloaded');
        ready = version;
        notifyListeners();
      }
    } else if (Platform.isMacOS) {
      await _checkDownloads('macos');
    } else if (Platform.isWindows) {
      await _checkDownloads('windows_x64');
    }
  }

  /// Looks for a newer file for [platform] in the server's download list.
  Future<void> _checkDownloads(String platform) async {
    final server = _server();
    if (appVersion.isEmpty || server == null) return;
    final downloads = await Api(server).downloads();
    final latest = downloads.version;
    final file = downloads.files
        .where((f) => f.platform == platform)
        .firstOrNull;
    if (latest == null || file == null || !isNewer(latest, appVersion)) return;
    available = (version: latest, url: Uri.parse(file.url));
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
