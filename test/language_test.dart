import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/language.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/l10n/app_localizations.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';

void main() {
  setUpAll(() async => RustLib.init());

  test('the language follows the system list, first match wins', () {
    Locale pick(List<String> tags) => negotiateLocale([
      for (final tag in tags)
        Locale.fromSubtags(
          languageCode: tag.split('-')[0],
          scriptCode: tag.split('-').length == 3 ? tag.split('-')[1] : null,
          countryCode: tag.split('-').length > 1 ? tag.split('-').last : null,
        ),
    ]);
    expect(pick(['nl-NL', 'de-AT', 'en']), const Locale('de'));
    expect(pick(['ru-RU']), const Locale('ru'));
    expect(pick(['zh-CN']), const Locale('zh'));
    expect(pick(['zh-TW', 'ja']), const Locale('ja'));
    expect(pick(['zh-Hant-HK']), const Locale('en'));
    expect(pick(['zh-Hans-SG']), const Locale('zh'));
    expect(pick(['pt-PT']), const Locale('pt'));
    expect(pick([]), const Locale('en'));
  });

  test('every language has its file and the app knows them all', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      languages.keys.toSet(),
    );
  });

  test('translations keep the placeholders and the keys of English', () {
    Map<String, dynamic> read(String language) =>
        jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
            as Map<String, dynamic>;
    final placeholders = RegExp(r'\{(\w+)');
    Set<String> names(String text) =>
        placeholders.allMatches(text).map((m) => m[1]!).toSet();
    final english = read('en');
    for (final language in languages.keys) {
      for (final MapEntry(:key, :value) in read(language).entries) {
        if (key.startsWith('@')) continue;
        expect(english, contains(key), reason: '$language: $key');
        expect(
          names(value as String),
          names(english[key] as String),
          reason: '$language: $key',
        );
      }
    }
  });

  test('untranslated messages show in English', () {
    expect(lookupAppLocalizations(const Locale('ru')).callLeave, 'Выйти');
    expect(lookupAppLocalizations(const Locale('de')).callLeave, 'Leave');
    expect(
      lookupAppLocalizations(const Locale('ru')).brandingSignInWith('Wiseless'),
      'Войти через Wiseless',
    );
  });

  testWidgets('the language picked in Settings wins over the system', (
    tester,
  ) async {
    final secrets = MemorySecrets();
    await secrets.write('preferences', '{"language": "ru"}');
    final container = ProviderContainer(
      overrides: [secretsProvider.overrideWithValue(secrets)],
    );
    await container.read(serversProvider.future);
    await container
        .read(serversProvider.notifier)
        .add(SavedServer(origin: Uri.parse('https://a.example'), name: 'A'));
    container.dispose();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [secretsProvider.overrideWithValue(secrets)],
        child: const WisetalkApp(),
      ),
    );
    await tester.pumpAndSettle();
    // Tests have no network: the sign-in screen can't reach the server.
    expect(find.text('Повторить'), findsOneWidget);
  });
}
