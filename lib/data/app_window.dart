// The app's own window: full screen for a video (WLK-63). On the desktop
// the runners do it (linux/runner/my_application.cc,
// windows/runner/flutter_window.cpp, macos/Runner/MainFlutterWindow.swift);
// on phones the system bars go away and a screen share turns sideways.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _window = MethodChannel('net.wiseless.wisetalk/window');

/// Goes full screen or back; [landscape] turns a phone sideways meanwhile.
Future<void> setFullScreen(bool on, {bool landscape = false}) async {
  try {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await _window.invokeMethod<void>('fullScreen', on);
    } else {
      await SystemChrome.setEnabledSystemUIMode(
        on ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
      await SystemChrome.setPreferredOrientations(
        on && landscape
            ? const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : const [],
      );
    }
  } on Exception catch (e) {
    // An older runner, say: the video still fills the window.
    debugPrint('full screen: $e');
  }
}
