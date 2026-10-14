// A member turns the camera on in a call and off again, on a real server.
// Guests can't share video, so this needs an account's session on the local
// server, made by hand in its database:
//
//   insert into accounts (id, issuer, subject, username, display_name)
//     values ('00000000-0000-4000-8000-0000000000a1', 'local-test',
//             'video-owl', 'video-owl', 'Video Owl');
//   insert into sessions (id, token_hash, account_id, expires_at)
//     values (gen_random_uuid(), sha256('<token>'::bytea),
//             '00000000-0000-4000-8000-0000000000a1', now() + interval '1 year');
//
// Then run it with WISETALK_TEST_TOKEN=<token>. It uses the first camera.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
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

Future<void> waitForNone(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isNotEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(finder, findsNothing);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await RustLib.init();
  });

  final token = Platform.environment['WISETALK_TEST_TOKEN'];

  testWidgets('a member turns the camera on and off', skip: token == null, (
    tester,
  ) async {
    final channel = Platform.environment['WISETALK_TEST_CHANNEL'] ?? 'Welcome';
    final origin = Uri.parse('http://localhost:8080');
    final secrets = MemorySecrets()
      ..values[serversKey] = jsonEncode([
        SavedServer(origin: origin, name: 'Local').toJson(),
      ])
      ..values[currentServerKey] = origin.toString()
      ..values[tokenKey(origin)] = token!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secretsProvider.overrideWithValue(secrets)],
        child: const WisetalkApp(),
      ),
    );

    await waitFor(tester, find.text(channel));
    await tester.tap(find.text(channel).first);
    await waitFor(tester, find.text('End-to-end encrypted'));
    await waitFor(tester, find.byIcon(Icons.videocam_off));

    await tester.tap(find.byIcon(Icons.videocam_off));
    await waitFor(tester, find.byType(lk.VideoTrackRenderer));
    expect(find.text('You'), findsOneWidget);

    // Off again: back to avatars.
    await tester.tap(find.byIcon(Icons.videocam));
    await waitForNone(tester, find.byType(lk.VideoTrackRenderer));

    await tester.tap(find.byIcon(Icons.call_end));
    await waitFor(tester, find.text('Pick a Voice Channel'));
  });
}
