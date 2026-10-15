// Shortcuts in a call (ADR-0027): Ctrl+Shift+M and Ctrl+Shift+A out of the
// box, and a new binding recorded in Settings. Needs the local server, its
// LiveKit and a microphone, like voice_test.dart, and a channel open to
// guests named in WISETALK_TEST_CHANNEL (Welcome by default).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  int seconds = 20,
}) async {
  for (var i = 0; i < seconds * 5 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(finder, findsWidgets);
}

Future<void> press(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  List<LogicalKeyboardKey> holding = const [],
}) async {
  for (final modifier in holding) {
    await tester.sendKeyDownEvent(modifier);
  }
  await tester.sendKeyEvent(key);
  for (final modifier in holding.reversed) {
    await tester.sendKeyUpEvent(modifier);
  }
  await tester.pump();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await RustLib.init();
  });

  testWidgets('shortcuts mute, step away and take new keys', (tester) async {
    final channel = Platform.environment['WISETALK_TEST_CHANNEL'] ?? 'Welcome';
    const ctrlShift = [
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.shiftLeft,
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secretsProvider.overrideWithValue(MemorySecrets())],
        child: const WisetalkApp(),
      ),
    );
    await waitFor(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'localhost:8080');
    await tester.tap(find.text('Connect'));
    await waitFor(tester, find.text('Join as a guest'));
    await tester.enterText(find.byType(TextField), 'Key Owl');
    await tester.tap(find.text('Continue as Guest'));
    await waitFor(tester, find.text(channel));
    await tester.tap(find.text(channel).first);
    await waitFor(tester, find.text('End-to-end encrypted'));
    await waitFor(tester, find.byIcon(Icons.mic));

    await press(tester, LogicalKeyboardKey.keyM, holding: ctrlShift);
    await waitFor(tester, find.byIcon(Icons.mic_off));
    await press(tester, LogicalKeyboardKey.keyM, holding: ctrlShift);
    await waitFor(tester, find.byIcon(Icons.mic));
    expect(find.byIcon(Icons.mic_off), findsNothing);

    // Away shows in the list next to our name, and back again.
    await press(tester, LogicalKeyboardKey.keyA, holding: ctrlShift);
    await waitFor(tester, find.byIcon(Icons.mic_off));
    // The button's icon, then ours in the list and on the stage.
    expect(find.byIcon(Icons.headset_off), findsAtLeast(3));
    await press(tester, LogicalKeyboardKey.keyA, holding: ctrlShift);
    await waitFor(tester, find.byIcon(Icons.mic));
    expect(find.byIcon(Icons.headset_off), findsOneWidget);

    // Microphone Off on F13: Alt+F4 is refused, F13 taken.
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Microphone Off'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Microphone Off'));
    await tester.pump();
    expect(find.text('Press keys…'), findsOneWidget);
    await press(
      tester,
      LogicalKeyboardKey.f4,
      holding: [LogicalKeyboardKey.altLeft],
    );
    expect(find.textContaining('belongs to the system'), findsOneWidget);
    await press(tester, LogicalKeyboardKey.f13);
    expect(find.text('F13'), findsOneWidget);
    expect(find.text('Press keys…'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await press(tester, LogicalKeyboardKey.f13);
    await waitFor(tester, find.byIcon(Icons.mic_off));
    // One way only: pressed again, it stays off.
    await press(tester, LogicalKeyboardKey.f13);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byIcon(Icons.mic), findsNothing);

    await tester.tap(find.byIcon(Icons.call_end));
    await waitFor(tester, find.text('Pick a Voice Channel'));
  });
}
