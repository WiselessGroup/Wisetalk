import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/desktop_entry.dart';
import 'data/links.dart';
import 'data/updates.dart';
import 'router.dart';
import 'src/rust/api/update.dart';
import 'src/rust/frb_generated.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  // First: while installing or updating, Velopack may end the process here.
  startUpdates();
  unawaited(registerDesktopEntry());
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
    return MaterialApp.router(
      title: 'Wisetalk',
      debugShowCheckedModeBanner: false,
      theme: themeFor(Brightness.light),
      darkTheme: themeFor(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
