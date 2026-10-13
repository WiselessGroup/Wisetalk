import 'package:flutter/material.dart';

import 'src/rust/api/device.dart';
import 'src/rust/api/text.dart';
import 'src/rust/frb_generated.dart';
import 'theme.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const WisetalkApp());
}

class WisetalkApp extends StatelessWidget {
  const WisetalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisetalk',
      debugShowCheckedModeBanner: false,
      theme: themeFor(Brightness.light),
      darkTheme: themeFor(Brightness.dark),
      home: const FoundationScreen(),
    );
  }
}

/// A placeholder until sign-in exists: shows that the Rust bridge to
/// wisetalk-core works by making a device key and its fingerprint.
class FoundationScreen extends StatefulWidget {
  const FoundationScreen({super.key});

  @override
  State<FoundationScreen> createState() => _FoundationScreenState();
}

class _FoundationScreenState extends State<FoundationScreen> {
  final Device _device = Device.generate();

  @override
  void dispose() {
    _device.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Wisetalk',
              style: text.headlineMedium?.copyWith(
                color: palette.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Protocol ${protocolVersion()}',
              style: text.bodyMedium?.copyWith(color: palette.muted),
            ),
            const SizedBox(height: 24),
            Text(
              'This device',
              style: text.labelMedium?.copyWith(color: palette.tertiary),
            ),
            const SizedBox(height: 4),
            SelectableText(
              _device.fingerprint,
              style: text.titleMedium?.copyWith(
                color: palette.accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
