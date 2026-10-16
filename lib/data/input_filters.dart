// Whether the device cleans up the microphone itself (WLK-2). Where it can,
// Wisetalk leaves the filtering to it: no processing of its own on top, no
// Voice Processing switch, and the microphone goes out in mono.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _android = MethodChannel('net.wiseless.wisetalk/audio');

class InputFilters {
  /// Whether the device filters the microphone itself. Read once at start.
  bool get byDevice => _byDevice;
  bool _byDevice = false;

  /// Apple's voice processing (echo cancellation, noise suppression and the
  /// Voice Isolation mode) is on every Mac and iPhone, and WebRTC records
  /// through it. On Android it depends on the phone: hardware echo
  /// cancellation and noise suppression, which WebRTC uses when present.
  Future<void> detect() async {
    if (Platform.isMacOS || Platform.isIOS) {
      _byDevice = true;
    } else if (Platform.isAndroid) {
      try {
        _byDevice = await _android.invokeMethod<bool>('filtersInput') ?? false;
      } catch (e) {
        debugPrint('cannot ask about hardware audio effects: $e');
      }
    }
  }

  @visibleForTesting
  set byDevice(bool value) => _byDevice = value;
}

final inputFilters = InputFilters();

/// Whether the microphone is cleaned up at all: by the device where it can,
/// otherwise as the person chose.
bool processingOn({required bool byDevice, required bool chosen}) =>
    byDevice || chosen;

/// Whether the microphone goes out in stereo. Echo cancellation works on one
/// channel, so with any processing on both channels would carry the same
/// sound and only cost bits. Of the platforms that process by choice, Linux
/// and Windows record two channels; Android only bypassing its voice
/// processing for the whole app, which this does not do.
bool stereoMicrophone({
  required bool channelStereo,
  required bool processing,
  required bool recordsStereo,
}) => channelStereo && !processing && recordsStereo;
