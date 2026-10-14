// A server's page hands the app its address with a wisetalk: link. Needs
// the local server (see voice_test.dart).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wisetalk/data/links.dart';
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

  testWidgets('a link adds a server, or shows why it cannot', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secretsProvider.overrideWithValue(MemorySecrets())],
        child: const WisetalkApp(),
      ),
    );
    await waitFor(tester, find.byType(TextField));
    // Nothing filled in ahead of time any more.
    expect(find.text('talk.wiseless.net'), findsNothing);

    final open = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(openLinkProvider);
    await open(
      Uri.parse('wisetalk://add?server=http%3A%2F%2Flocalhost%3A8080'),
    );
    await waitFor(tester, find.text('Join as a guest'));

    // A server that isn't there: back to the list, with its address (not
    // https, so it keeps its scheme).
    await open(Uri.parse('wisetalk://open?server=localhost:1'));
    await waitFor(tester, find.text('Your Servers'));
    expect(
      find.descendant(
        of: find.byType(TextField),
        matching: find.text('http://localhost:1'),
      ),
      findsOneWidget,
    );
  });
}
