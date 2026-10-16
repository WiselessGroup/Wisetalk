import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/android_logs.dart';
import 'data/crash_reports.dart';
import 'data/desktop_entry.dart';
import 'data/input_filters.dart';
import 'data/language.dart';
import 'data/links.dart';
import 'data/preferences.dart';
import 'data/unified_push.dart';
import 'data/updates.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';
import 'src/rust/api/update.dart';
import 'src/rust/frb_generated.dart';
import 'theme.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (args.contains(pushBackgroundArgument)) {
    // A summons came while Wisetalk was closed (Android): only what shows
    // its notification, no window, no Rust, no connection.
    await unifiedPushes.start(background: true);
    return;
  }
  // Before anything can set a call key.
  quietAndroidLogs();
  crashReports.watch();
  await RustLib.init();
  await inputFilters.detect();
  // First: while installing or updating, Velopack may end the process here.
  startUpdates();
  unawaited(registerDesktopEntry());
  // Before anything registers, so endpoints and pushes have somewhere to go.
  unawaited(unifiedPushes.start());
  runApp(const ProviderScope(child: WisetalkApp()));
}

class WisetalkApp extends ConsumerWidget {
  const WisetalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts looking for updates and listening for wisetalk: links, signed
    // in or not.
    ref.watch(updatesProvider);
    ref.watch(linksProvider);
    // Summons while closed follow whoever is signed in (Android).
    ref.watch(unifiedPushProvider);
    final router = ref.watch(routerProvider);
    return ValueListenableBuilder(
      valueListenable: ref.watch(preferencesProvider).language,
      builder: (context, language, _) => MaterialApp.router(
        title: 'Wisetalk',
        debugShowCheckedModeBanner: false,
        theme: themeFor(Brightness.light),
        darkTheme: themeFor(Brightness.dark),
        // Picked in Settings, or the system's (asked again when it changes).
        locale: language == null || !languages.containsKey(language)
            ? null
            : localeOf(language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        localeListResolutionCallback: (wanted, _) => negotiateLocale(wanted),
        routerConfig: router,
      ),
    );
  }
}
