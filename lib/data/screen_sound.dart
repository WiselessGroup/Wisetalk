// The shared screen's sound on Android (ScreenSound.kt, WLK-3): what other
// apps play, mixed into what the microphone sends. Wisetalk's own sound,
// the call's voices with it, stays out.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenSound {
  static const _channel = MethodChannel('net.wiseless.wisetalk/screen_sound');

  /// Starts recording the phone's sound for the screen share whose video
  /// track is [trackId]; whether it runs.
  Future<bool> start(String trackId) async {
    try {
      return await _channel.invokeMethod<bool>('start', {'track': trackId}) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('screen sound: $e');
      return false;
    }
  }

  /// Whether the voice goes out with the sound, or the sound alone.
  Future<void> microphone({required bool on}) =>
      _channel.invokeMethod<void>('microphone', {'on': on});

  Future<void> stop() => _channel.invokeMethod<void>('stop');
}
