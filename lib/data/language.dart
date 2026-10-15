// Which language the interface speaks (ADR-0024): the one picked in
// Settings, or the best match for the system's list. Widgets read their
// texts with `AppLocalizations.of(context)`; what has no context (the
// Android call notification, system notifications) asks [textsFor].

import 'dart:ui';

import '../l10n/app_localizations.dart';

/// Every language there is, in its own words, to be found by whoever reads
/// it. `zh` is Simplified Chinese and `pt` Brazilian Portuguese.
const languages = {
  'en': 'English',
  'ru': 'Русский',
  'zh': '简体中文',
  'ja': '日本語',
  'pt': 'Português (Brasil)',
  'de': 'Deutsch',
  'fr': 'Français',
  'es': 'Español',
};

/// The best of ours for [wanted], most wanted first; the same rules as the
/// web client's `negotiate()`.
Locale negotiateLocale(Iterable<Locale>? wanted) {
  for (final locale in wanted ?? const <Locale>[]) {
    final language = locale.languageCode;
    if (language == 'zh') {
      // Traditional Chinese readers go on down their list rather than
      // getting Simplified.
      final traditional = switch (locale.scriptCode) {
        'Hant' => true,
        'Hans' => false,
        _ => const {'TW', 'HK', 'MO'}.contains(locale.countryCode),
      };
      if (traditional) continue;
    }
    if (languages.containsKey(language)) return Locale(language);
  }
  return const Locale('en');
}

/// Texts in [language] (a key of [languages]), or the system's when `null`.
AppLocalizations textsFor(String? language) => lookupAppLocalizations(
  language != null
      ? Locale(language)
      : negotiateLocale(PlatformDispatcher.instance.locales),
);
