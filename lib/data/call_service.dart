// Android's foreground service for calls (CallService.kt): it keeps the
// call, and the microphone in it, working with Wisetalk in the background,
// shows the ongoing call notification, and must run before screen capture
// starts.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class CallService {
  static const _channel = MethodChannel('net.wiseless.wisetalk/call');

  (String?, bool, bool, String)? _last;

  /// Runs the service for a call in [channel] (`null` stops it), with
  /// screen capture allowed while [sharing], its notification in [texts]'
  /// language. Answers whether it runs; on other platforms there's nothing
  /// to run and it answers `true`. The service takes the microphone in when
  /// its permission is there, which turning the microphone on ([talking])
  /// may have just brought: that runs it again.
  Future<bool> update({
    required String? channel,
    required AppLocalizations texts,
    bool sharing = false,
    bool talking = false,
  }) async {
    if (!Platform.isAndroid) return true;
    final language = texts.localeName;
    final wanted = (channel, sharing, talking, language);
    if (_last == wanted) return channel != null;
    _last = wanted;
    try {
      final types =
          await _channel.invokeMethod<int>('update', {
            'title': channel,
            'sharing': sharing,
            // Android has no strings of its own: one set of texts, here.
            'text': sharing
                ? texts.callServiceSharing
                : texts.callServiceInCall,
            'channelName': texts.callServiceChannel,
          }) ??
          0;
      // Not running: try again next time.
      if (types == 0 && channel != null) _last = null;
      return types != 0;
    } on PlatformException catch (e) {
      debugPrint('call service: $e');
      _last = null;
      return false;
    }
  }
}
