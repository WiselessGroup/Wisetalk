// Android's foreground service for calls (CallService.kt): it keeps the
// microphone working with Wisetalk in the background, shows the ongoing
// call notification, and must run before screen capture starts.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CallService {
  static const _channel = MethodChannel('net.wiseless.wisetalk/call');

  (String?, bool)? _last;

  /// Runs the service for a call in [channel] (`null` stops it), with
  /// screen capture allowed while [sharing]. Answers whether it runs; on
  /// other platforms there's nothing to run and it answers `true`.
  Future<bool> update({required String? channel, bool sharing = false}) async {
    if (!Platform.isAndroid) return true;
    if (_last == (channel, sharing)) return channel != null;
    _last = (channel, sharing);
    try {
      final running =
          await _channel.invokeMethod<bool>('update', {
            'title': channel,
            'sharing': sharing,
          }) ??
          false;
      // Not running (no microphone permission yet, say): try again next time.
      if (!running) _last = null;
      return running;
    } on PlatformException catch (e) {
      debugPrint('call service: $e');
      _last = null;
      return false;
    }
  }
}
