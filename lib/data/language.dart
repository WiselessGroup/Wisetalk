// Which language the interface speaks (ADR-0024): the one picked in
// Settings, or the best match for the system's list. Widgets read their
// texts with `AppLocalizations.of(context)`; what has no context (the
// Android call notification, system notifications) asks [textsFor].

import 'dart:ui';

import '../l10n/app_localizations.dart';

/// Every language there is, by the web client's tags, in its own words, to
/// be found by whoever reads it. Chinese is Traditional only (ADR-0024).
const languages = {
  'en': 'English',
  'ru': 'Русский',
  'zh-Hant': '繁體中文',
  'ja': '日本語',
  'pt-BR': 'Português (Brasil)',
  'de': 'Deutsch',
  'fr': 'Français',
  'es': 'Español',
};

/// The locale of the ARB file for [language], a key of [languages]. Brazilian
/// Portuguese is `app_pt`, so Portugal falls back to it too; `app_zh` is an
/// empty fallback gen-l10n demands next to `app_zh_Hant`.
Locale localeOf(String language) => switch (language) {
  'zh-Hant' => const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  'pt-BR' => const Locale('pt'),
  _ => Locale(language),
};

/// The best of ours for [wanted], most wanted first; the same rules as the
/// web client's `negotiate()`: any Portuguese reads Brazilian, Traditional
/// Chinese (Hant, Taiwan, Hong Kong, Macau) is ours, and Simplified readers
/// get it too, but only when nothing else on their list is here.
Locale negotiateLocale(Iterable<Locale>? wanted) {
  var simplified = false;
  for (final locale in wanted ?? const <Locale>[]) {
    final language = locale.languageCode;
    if (language == 'zh') {
      final traditional = switch (locale.scriptCode) {
        'Hant' => true,
        'Hans' => false,
        _ => const {'TW', 'HK', 'MO'}.contains(locale.countryCode),
      };
      if (traditional) return localeOf('zh-Hant');
      simplified = true;
      continue;
    }
    if (language == 'pt') return localeOf('pt-BR');
    if (languages.containsKey(language)) return Locale(language);
  }
  return simplified ? localeOf('zh-Hant') : const Locale('en');
}

/// The language picked in Settings, kept here by [Preferences] for code with
/// neither a context nor the preferences at hand, such as API errors.
String? appLanguage;

/// Texts in the language the app speaks now.
AppLocalizations get appTexts => textsFor(appLanguage);

/// Texts in [language] (a key of [languages]), or the system's when `null`.
AppLocalizations textsFor(String? language) => lookupAppLocalizations(
  language != null && languages.containsKey(language)
      ? localeOf(language)
      : negotiateLocale(PlatformDispatcher.instance.locales),
);
