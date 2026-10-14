import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'src/rust/frb_generated.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const ProviderScope(child: WisetalkApp()));
}

class WisetalkApp extends ConsumerWidget {
  const WisetalkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Wisetalk',
      debugShowCheckedModeBanner: false,
      theme: themeFor(Brightness.light),
      darkTheme: themeFor(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
