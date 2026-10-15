// Crash reports, off until the person turns them on in Settings. They go to
// the developers' GlitchTip (the Sentry protocol) and say what broke and
// where in the code: never messages, names, keys or server addresses.
//
// Only release builds made by the release scripts know where to send them
// (--dart-define=WISETALK_SENTRY_DSN); forks and development builds don't.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';

import 'updates.dart';

const _dsn = String.fromEnvironment('WISETALK_SENTRY_DSN');

class CrashReports {
  bool _on = false;

  /// Whether this build can send reports at all.
  bool get available => _dsn.isNotEmpty;

  /// Catches what Flutter and Dart don't handle, for when reports are on.
  /// Runs once in main, before the app.
  void watch() {
    final flutter = FlutterError.onError;
    FlutterError.onError = (details) {
      flutter?.call(details);
      _send(details.exception, details.stack);
    };
    final dart = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _send(error, stack);
      return dart?.call(error, stack) ?? false;
    };
  }

  Future<void> setEnabled(bool on) async {
    if (!available || on == _on) return;
    _on = on;
    if (!on) return Sentry.close();
    await Sentry.init((options) {
      options
        ..dsn = _dsn
        ..release = 'wisetalk@$versionName'
        ..environment = kReleaseMode ? 'production' : 'development'
        ..sendDefaultPii = false
        ..attachStacktrace = true
        ..beforeSend = _scrub;
    });
  }

  void _send(Object error, StackTrace? stack) {
    if (_on) unawaited(Sentry.captureException(error, stackTrace: stack));
  }

  /// Keeps what broke and where; addresses, hosts and e-mail addresses
  /// leave the messages first.
  static SentryEvent _scrub(SentryEvent event, Hint hint) => event
    ..user = null
    ..serverName = null
    ..request = null
    ..breadcrumbs = null
    ..message = null
    ..exceptions = [
      for (final e in event.exceptions ?? <SentryException>[])
        e..value = e.value == null ? null : scrub(e.value!),
    ];
}

/// [text] without URLs, e-mail addresses, IP addresses and host names.
@visibleForTesting
String scrub(String text) => text
    .replaceAll(RegExp(r'\b\w+://\S+'), '<url>')
    .replaceAll(RegExp(r'[\w.+-]+@[\w-]+(\.[\w-]+)+'), '<email>')
    .replaceAll(RegExp(r'\b\d{1,3}(\.\d{1,3}){3}(:\d+)?\b'), '<ip>')
    .replaceAll(RegExp(r'\[?[0-9a-fA-F]*:[0-9a-fA-F:]{2,}\]?'), '<ip>')
    .replaceAll(RegExp(r'\b([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(:\d+)?\b'), '<host>');

/// The app's one reporter.
final crashReports = CrashReports();
