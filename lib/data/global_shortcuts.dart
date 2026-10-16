// Shortcuts that work while another app is in front (WLK-30, ADR-0027):
// the same bindings as in the window, registered through the Rust bridge
// only while in a call, so Ctrl+Shift+A stays the browser's the rest of the
// time. Wayland gives apps no such thing (WLK-31); there the window's own
// shortcuts are all there is.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../src/rust/api/hotkeys.dart';
import 'preferences.dart';
import 'shortcuts.dart';
import 'voice.dart';

/// Whether shortcuts work outside the window here; read once.
final bool globalShortcutsAvailable = hasShortcuts && _available();

bool _available() {
  try {
    return globalHotkeysAvailable();
  } catch (e) {
    debugPrint('cannot ask about global shortcuts: $e');
    return false;
  }
}

/// What to register: every bound action while in a call, nothing otherwise.
@visibleForTesting
List<GlobalHotkey> wantedHotkeys({
  required bool inCall,
  required KeyCombo? Function(CallAction) shortcut,
}) => [
  if (inCall)
    for (final action in CallAction.values)
      if (shortcut(action) case final combo?)
        GlobalHotkey(action: action.name, combo: combo.toString()),
];

class GlobalShortcuts {
  GlobalShortcuts(this.voice, this.preferences) {
    if (!globalShortcutsAvailable) return;
    _events = watchGlobalHotkeys().listen(_pressed);
    voice.addListener(_update);
    preferences.addListener(_update);
  }

  final Voice voice;
  final Preferences preferences;

  StreamSubscription<String>? _events;
  List<GlobalHotkey> _registered = const [];

  void _update() {
    final wanted = wantedHotkeys(
      inCall: voice.state == VoiceState.connected,
      shortcut: preferences.shortcut,
    );
    if (listEquals(wanted, _registered)) return;
    _registered = wanted;
    unawaited(_register(wanted));
  }

  Future<void> _register(List<GlobalHotkey> hotkeys) async {
    try {
      // Keys another app holds still work in the window.
      final failed = await setGlobalHotkeys(hotkeys: hotkeys);
      if (failed.isNotEmpty) debugPrint('taken by another app: $failed');
    } catch (e) {
      debugPrint('cannot register global shortcuts: $e');
    }
  }

  void _pressed(String name) {
    final action = CallAction.values.asNameMap()[name];
    if (action != null) unawaited(voice.perform(action));
  }

  void dispose() {
    if (!globalShortcutsAvailable) return;
    voice.removeListener(_update);
    preferences.removeListener(_update);
    unawaited(_events?.cancel());
    if (_registered.isNotEmpty) unawaited(_register(const []));
  }
}
