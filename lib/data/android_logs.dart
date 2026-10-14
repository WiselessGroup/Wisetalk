// Keeps call keys out of Android's system log. The WebRTC build for Android
// (150.7871.01) prints every call key it derives at INFO, and nothing in
// its API turns that off (the same bug as on Linux, see
// cmake/libwebrtc.cmake). Android 11 lets a process raise the lowest level
// it logs at, for everything in it: release builds keep warnings and errors
// only. Debug builds log as usual, `flutter run` reads them.

import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// ANDROID_LOG_WARN.
const _warn = 5;

void quietAndroidLogs() {
  if (!Platform.isAndroid || kDebugMode) return;
  try {
    DynamicLibrary.open('liblog.so')
        .lookupFunction<Int32 Function(Int32), int Function(int)>(
          '__android_log_set_minimum_priority',
        )(_warn);
  } catch (e) {
    // Older than Android 11, which the app doesn't install on.
    debugPrint('cannot quiet the system log: $e');
  }
}
