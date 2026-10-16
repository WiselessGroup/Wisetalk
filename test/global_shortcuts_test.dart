import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/global_shortcuts.dart';
import 'package:wisetalk/data/shortcuts.dart';
import 'package:wisetalk/src/rust/api/hotkeys.dart';

void main() {
  const mute = KeyCombo(
    PhysicalKeyboardKey(0x00070010),
    control: true,
    shift: true,
  );
  KeyCombo? bindings(CallAction action) =>
      action == CallAction.toggleMute ? mute : null;

  test('bound actions are registered only while in a call', () {
    expect(wantedHotkeys(inCall: true, shortcut: bindings), [
      const GlobalHotkey(
        action: 'toggleMute',
        combo: 'control+shift+0x00070010',
      ),
    ]);
    expect(wantedHotkeys(inCall: false, shortcut: bindings), isEmpty);
  });
}
