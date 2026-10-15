import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/preferences.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/shortcuts.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  void on(TargetPlatform platform) =>
      debugDefaultTargetPlatformOverride = platform;

  const ctrlShiftM = KeyCombo(
    PhysicalKeyboardKey.keyM,
    control: true,
    shift: true,
  );

  test('combinations are written down and read back', () {
    expect(ctrlShiftM.toString(), 'control+shift+0x00070010');
    expect(KeyCombo.parse('control+shift+0x00070010'), ctrlShiftM);
    const all = KeyCombo(
      PhysicalKeyboardKey.f13,
      control: true,
      alt: true,
      shift: true,
      meta: true,
    );
    expect(KeyCombo.parse(all.toString()), all);
    expect(
      KeyCombo.parse('0x0007006a'),
      const KeyCombo(PhysicalKeyboardKey.f15),
    );
  });

  test('anything else reads as nothing', () {
    for (final junk in [
      '',
      'control',
      'control+',
      'control+M',
      'hyper+0x00070010',
      'control+control+0x00070010',
      // A media key: not one a shortcut may use.
      'control+0x000c00cd',
    ]) {
      expect(KeyCombo.parse(junk), isNull, reason: junk);
    }
  });

  test('defaults use Command on a Mac and Ctrl elsewhere', () {
    on(TargetPlatform.linux);
    expect(CallAction.toggleMute.defaultCombo, ctrlShiftM);
    expect(CallAction.toggleMute.defaultCombo!.label, 'Ctrl+Shift+M');
    expect(CallAction.toggleAway.defaultCombo!.label, 'Ctrl+Shift+A');
    expect(CallAction.mute.defaultCombo, isNull);
    expect(CallAction.unmute.defaultCombo, isNull);

    on(TargetPlatform.macOS);
    expect(
      CallAction.toggleMute.defaultCombo,
      const KeyCombo(PhysicalKeyboardKey.keyM, meta: true, shift: true),
    );
    expect(CallAction.toggleMute.defaultCombo!.label, '⇧⌘M');
    expect(CallAction.toggleAway.defaultCombo!.label, '⇧⌘A');
  });

  test('defaults are allowed where they apply', () {
    for (final platform in [
      TargetPlatform.linux,
      TargetPlatform.windows,
      TargetPlatform.macOS,
    ]) {
      on(platform);
      for (final action in CallAction.values) {
        expect(action.defaultCombo?.refusal, isNull, reason: '$platform');
      }
    }
  });

  test('system combinations are refused on a Mac', () {
    on(TargetPlatform.macOS);
    for (final combo in [
      const KeyCombo(PhysicalKeyboardKey.keyQ, meta: true),
      const KeyCombo(PhysicalKeyboardKey.keyW, meta: true),
      const KeyCombo(PhysicalKeyboardKey.comma, meta: true),
      const KeyCombo(PhysicalKeyboardKey.keyH, meta: true),
      const KeyCombo(PhysicalKeyboardKey.tab, meta: true),
      const KeyCombo(PhysicalKeyboardKey.space, meta: true),
      const KeyCombo(PhysicalKeyboardKey.keyC, meta: true),
      const KeyCombo(PhysicalKeyboardKey.digit4, meta: true, shift: true),
      const KeyCombo(PhysicalKeyboardKey.escape, alt: true, meta: true),
      const KeyCombo(PhysicalKeyboardKey.keyQ, control: true, meta: true),
    ]) {
      expect(combo.refusal, contains('system'), reason: combo.label);
    }
    // Free on a Mac, where Command does the work of Ctrl.
    expect(
      const KeyCombo(PhysicalKeyboardKey.keyQ, control: true).refusal,
      isNull,
    );
  });

  test('system combinations are refused on Windows and Linux', () {
    for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
      on(platform);
      for (final combo in [
        const KeyCombo(PhysicalKeyboardKey.f4, alt: true),
        const KeyCombo(PhysicalKeyboardKey.keyQ, control: true),
        const KeyCombo(PhysicalKeyboardKey.keyW, control: true),
        const KeyCombo(PhysicalKeyboardKey.keyV, control: true),
        const KeyCombo(PhysicalKeyboardKey.tab, alt: true),
        const KeyCombo(PhysicalKeyboardKey.delete, control: true, alt: true),
        const KeyCombo(PhysicalKeyboardKey.f2, control: true, alt: true),
        const KeyCombo(PhysicalKeyboardKey.keyL, meta: true),
        const KeyCombo(PhysicalKeyboardKey.escape, control: true, shift: true),
      ]) {
        expect(combo.refusal, contains('system'), reason: combo.label);
      }
      expect(
        const KeyCombo(PhysicalKeyboardKey.keyQ, meta: true).refusal,
        isNull,
      );
    }
  });

  test('keys that type are refused without Ctrl, Alt or Command', () {
    on(TargetPlatform.linux);
    expect(const KeyCombo(PhysicalKeyboardKey.keyM).refusal, isNotNull);
    expect(
      const KeyCombo(PhysicalKeyboardKey.keyM, shift: true).refusal,
      isNotNull,
    );
    expect(const KeyCombo(PhysicalKeyboardKey.keyM, alt: true).refusal, isNull);
    // Function keys alone are fine: mouse buttons often send F13 to F24.
    expect(const KeyCombo(PhysicalKeyboardKey.f13).refusal, isNull);
    expect(const KeyCombo(PhysicalKeyboardKey.f9).refusal, isNull);

    on(TargetPlatform.macOS);
    // Option types special letters on a Mac.
    expect(
      const KeyCombo(PhysicalKeyboardKey.keyM, alt: true).refusal,
      isNotNull,
    );
    expect(
      const KeyCombo(PhysicalKeyboardKey.keyM, control: true).refusal,
      isNull,
    );
  });

  test('labels follow the platform', () {
    const combo = KeyCombo(
      PhysicalKeyboardKey.backspace,
      control: true,
      alt: true,
      shift: true,
      meta: true,
    );
    on(TargetPlatform.windows);
    expect(combo.label, 'Ctrl+Alt+Shift+Win+Backspace');
    on(TargetPlatform.linux);
    expect(combo.label, 'Ctrl+Alt+Shift+Super+Backspace');
    on(TargetPlatform.macOS);
    expect(combo.label, '⌃⌥⇧⌘⌫');
    expect(
      const KeyCombo(PhysicalKeyboardKey.numpad5, control: true).label,
      '⌃Num 5',
    );
  });

  test('preferences keep changed shortcuts, cleared ones too', () async {
    on(TargetPlatform.linux);
    final secrets = MemorySecrets();
    final before = Preferences(secrets);
    const f13 = KeyCombo(PhysicalKeyboardKey.f13);
    before.setShortcut(CallAction.mute, f13);
    before.setShortcut(CallAction.toggleAway, null);
    // Back to the default: nothing to keep.
    before.setShortcut(CallAction.toggleMute, ctrlShiftM);
    await pumpEventQueue();

    final after = Preferences(secrets);
    await after.load();
    expect(after.shortcut(CallAction.mute), f13);
    expect(after.shortcut(CallAction.toggleAway), isNull);
    expect(after.shortcut(CallAction.toggleMute), ctrlShiftM);
    expect(after.shortcut(CallAction.unmute), isNull);
    expect(after.shortcutChanges.keys, {
      CallAction.mute,
      CallAction.toggleAway,
    });
  });
}
