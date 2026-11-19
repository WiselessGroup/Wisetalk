// Android's picture-in-picture (WLK-63): leaving Wisetalk while someone
// else shares a screen in the call shrinks it to a small window over the
// other apps, with that share alone in it. MainActivity.kt goes into it;
// this says when it may, and whether it's on now.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'voice.dart';

class PictureInPicture extends ChangeNotifier {
  PictureInPicture(this._voice) {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler(_called);
    _voice.addListener(_follow);
    _follow();
  }

  static const _channel = MethodChannel('net.wiseless.wisetalk/pip');

  final Voice _voice;
  bool _wanted = false;

  /// Wisetalk is the small window now.
  bool active = false;

  /// What the small window shows: someone else's screen in the call. The
  /// rest of the stage isn't drawn meanwhile, and LiveKit stops receiving
  /// video nobody sees (adaptive stream).
  VideoTile? get tile {
    for (final t in _voice.tiles) {
      if (t.screen && !t.local) return t;
    }
    return null;
  }

  void _follow() {
    final wanted = tile != null;
    if (wanted == _wanted) return;
    _wanted = wanted;
    _channel.invokeMethod('want', {'on': wanted}).catchError((Object e) {
      debugPrint('picture in picture: $e');
    });
  }

  Future<void> _called(MethodCall call) async {
    if (call.method != 'changed') return;
    active = call.arguments == true;
    notifyListeners();
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      _voice.removeListener(_follow);
      if (_wanted) _channel.invokeMethod('want', {'on': false}).ignore();
      _channel.setMethodCallHandler(null);
    }
    super.dispose();
  }
}
