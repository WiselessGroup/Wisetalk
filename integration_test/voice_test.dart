// A guest joins a voice channel on a real server: the gateway lists the
// channels, the call key is made (first one in), LiveKit connects with
// end-to-end encryption and the microphone is published, then steps away
// and back. Needs the local
// server and its LiveKit (`docker compose up -d` in server/) and a channel
// open to guests named in WISETALK_TEST_CHANNEL (Welcome by default).

import 'dart:io';

import 'package:flutter/material.dart';
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await RustLib.init();
  });

  testWidgets('a guest joins a call, leaves it, and changes servers mid-call', (
    tester,
  ) async {
    final channel = Platform.environment['WISETALK_TEST_CHANNEL'] ?? 'Welcome';
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
    await tester.enterText(find.byType(TextField), 'Voice Owl');
    await tester.tap(find.text('Continue as Guest'));

    await waitFor(tester, find.text(channel));
    await tester.tap(find.text(channel).first);
    await waitFor(tester, find.text('End-to-end encrypted'));
    // In the channel list and on the call stage.
    await waitFor(tester, find.text('Voice Owl'));
    expect(find.byIcon(Icons.call_end), findsOneWidget);

    // Away turns the microphone off and back on as it was, without a word
    // from servers that predate it.
    final away = find.byWidgetPredicate(
      (w) =>
          w is Semantics &&
          w.properties.label == 'Away: microphone and sound off',
    );
    await waitFor(tester, find.byIcon(Icons.mic));
    await tester.tap(away);
    await waitFor(tester, find.byIcon(Icons.mic_off));
    expect(find.byIcon(Icons.mic), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SnackBar), findsNothing);
    await tester.tap(away);
    await waitFor(tester, find.byIcon(Icons.mic));
    expect(find.byType(SnackBar), findsNothing);

    await tester.tap(find.byIcon(Icons.call_end));
    await waitFor(tester, find.text('Pick a Voice Channel'));

    // Changing servers mid-call closes the connection under the screen.
    await tester.tap(find.text(channel).first);
    await waitFor(tester, find.text('End-to-end encrypted'));
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change Server'));
    await waitFor(tester, find.text('Your Servers'));
    // Back in: a new connection, the same session.
    await tester.tap(find.textContaining('localhost:8080').first);
    await waitFor(tester, find.text(channel));
    await tester.tap(find.text(channel).first);
    await waitFor(tester, find.text('End-to-end encrypted'));
    await tester.tap(find.byIcon(Icons.call_end));
    await waitFor(tester, find.text('Pick a Voice Channel'));
  });
}
