// Shortcuts while Wisetalk's window is in front (ADR-0027): the bindings
// from Settings, acting on the call through Flutter's Shortcuts and
// Actions. Global ones, working from any window, come with WLK-30.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/preferences.dart';
import '../data/shortcuts.dart';
import '../data/voice.dart';

/// Asks for [action] on the call.
class CallActionIntent extends Intent {
  const CallActionIntent(this.action);

  final CallAction action;
}

/// Fires on [combo]'s physical key held with exactly its modifiers, so
/// Ctrl+Shift+M doesn't also fire on Ctrl+Alt+Shift+M, and a Russian
/// layout doesn't move it.
class KeyComboActivator extends ShortcutActivator {
  const KeyComboActivator(this.combo);

  final KeyCombo combo;

  /// Physical keys aren't triggers: every key press is checked.
  @override
  Iterable<LogicalKeyboardKey>? get triggers => null;

  @override
  bool accepts(KeyEvent event, HardwareKeyboard state) =>
      event is KeyDownEvent &&
      event.physicalKey == combo.key &&
      combo.heldIn(state);

  @override
  String debugDescribeKeys() => combo.label;

  @override
  bool operator ==(Object other) =>
      other is KeyComboActivator && other.combo == combo;

  @override
  int get hashCode => combo.hashCode;
}

/// Puts the call's shortcuts over [child]. Its subtree holds the focus
/// from the start, so the keys work before anything is clicked.
class CallShortcuts extends StatelessWidget {
  const CallShortcuts({
    super.key,
    required this.voice,
    required this.preferences,
    required this.child,
  });

  final Voice voice;
  final Preferences preferences;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!hasShortcuts) return child;
    return Shortcuts(
      shortcuts: {
        for (final action in CallAction.values)
          if (preferences.shortcut(action) case final combo?)
            KeyComboActivator(combo): CallActionIntent(action),
      },
      child: Actions(
        actions: {
          CallActionIntent: CallbackAction<CallActionIntent>(
            onInvoke: (intent) {
              unawaited(voice.perform(intent.action));
              return null;
            },
          ),
        },
        child: Focus(autofocus: true, child: child),
      ),
    );
  }
}
