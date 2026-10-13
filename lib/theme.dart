// The design system, the same one the web client uses: Catppuccin colors
// (Mocha with Mauve in the dark, Latte with Peach in the light) and Apple's
// Human Interface Guidelines for everything else. Names match the CSS tokens
// in webclient/src/routes/+layout.svelte.

import 'package:flutter/material.dart';

@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.bg,
    required this.sidebar,
    required this.window,
    required this.cell,
    required this.text,
    required this.muted,
    required this.tertiary,
    required this.fill,
    required this.separator,
    required this.accent,
    required this.onAccent,
    required this.speaking,
    required this.error,
  });

  final Color bg;
  final Color sidebar;
  final Color window;
  final Color cell;
  final Color text;
  final Color muted;
  final Color tertiary;
  final Color fill;
  final Color separator;
  final Color accent;
  final Color onAccent;
  final Color speaking;
  final Color error;

  static const dark = Palette(
    bg: Color(0xFF1E1E2E),
    sidebar: Color(0xFF181825),
    window: Color(0xFF11111B),
    cell: Color(0xFF232334),
    text: Color(0xFFCDD6F4),
    muted: Color(0xFFA6ADC8),
    tertiary: Color(0xFF7F849C),
    fill: Color(0x339399B2),
    separator: Color(0x299399B2),
    accent: Color(0xFFCBA6F7),
    onAccent: Color(0xFF11111B),
    speaking: Color(0xFFA6E3A1),
    error: Color(0xFFF38BA8),
  );

  static const light = Palette(
    bg: Color(0xFFEFF1F5),
    sidebar: Color(0xFFE6E9EF),
    window: Color(0xFFDCE0E8),
    cell: Color(0xFFF6F7F9),
    text: Color(0xFF4C4F69),
    muted: Color(0xFF5C5F77),
    tertiary: Color(0xFF7C7F93),
    fill: Color(0x246C6F85),
    separator: Color(0x336C6F85),
    accent: Color(0xFFFE640B),
    onAccent: Color(0xFF1E1E2E),
    speaking: Color(0xFF40A02B),
    error: Color(0xFFD20F39),
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(Palette? other, double t) => t < 0.5 ? this : (other ?? this);
}

ThemeData themeFor(Brightness brightness) {
  final palette = brightness == Brightness.dark ? Palette.dark : Palette.light;
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: palette.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      primary: palette.accent,
      onPrimary: palette.onAccent,
      surface: palette.bg,
      onSurface: palette.text,
      error: palette.error,
    ),
    // No ink splashes: HIG controls highlight, they don't ripple.
    splashFactory: NoSplash.splashFactory,
    extensions: [palette],
  );
}

extension PaletteOf on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}
