// The whole way in against a real server: add it, join as a guest, sign
// out, find it in the list. Needs a server on localhost:8080 with guests
// open (see server/README); run with `flutter test integration_test -d linux`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => RustLib.init());

  testWidgets('the system keyring keeps and forgets a secret', (tester) async {
    final secrets = SystemSecrets();
    const key = 'wisetalk-integration-test';
    await secrets.write(key, 'hoot');
    expect(await secrets.read(key), 'hoot');
    await secrets.delete(key);
    expect(await secrets.read(key), isNull);
  });

  testWidgets('a guest joins a server and leaves again', (tester) async {
    final secrets = MemorySecrets();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secretsProvider.overrideWithValue(secrets)],
        child: const WisetalkApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'localhost:8080');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Join as a guest'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '  App   Owl ');
    await tester.tap(find.text('Continue as Guest'));
    // The proof of work runs in Rust on another thread.
    for (var i = 0; i < 50 && find.text('App Owl').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();
    expect(find.text('App Owl'), findsWidgets);
    expect(
      secrets.values.keys.where((k) => k.startsWith('token:')),
      hasLength(1),
    );

    // Signing out lives in the menu under your name in the sidebar.
    await tester.tap(find.byIcon(Icons.more_horiz));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Join as a guest'), findsOneWidget);
    expect(secrets.values.keys.where((k) => k.startsWith('token:')), isEmpty);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('Your Servers'), findsOneWidget);
    expect(find.textContaining('App Owl'), findsOneWidget);
  });
}
