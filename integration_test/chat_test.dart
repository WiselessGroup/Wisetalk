// A guest opens a channel's chat on a real server, writes, and sends a
// picture: the chat key is made (or fetched), the text and the picture go
// out encrypted and come back readable. Needs the local server (see
// voice_test.dart).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wisetalk/data/connection.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/api/picture.dart';
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

  testWidgets('a guest writes in a chat and sends a picture', (tester) async {
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
    await tester.enterText(find.byType(TextField), 'Chat Owl');
    await tester.tap(find.text('Continue as Guest'));
    await waitFor(tester, find.text(channel));

    // The chat button on the channel's row.
    final row = find.ancestor(
      of: find.text(channel).first,
      matching: find.byType(Row),
    );
    await tester.tap(
      find.descendant(
        of: row.first,
        matching: find.byIcon(Icons.chat_bubble_outline),
      ),
    );
    await waitFor(tester, find.text('Chat'));

    final words = 'hoot ${DateTime.now().millisecondsSinceEpoch}';
    await tester.enterText(find.byType(TextField).last, words);
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await waitFor(
      tester,
      find.byWidgetPredicate(
        (w) => w is SelectableText && w.textSpan?.toPlainText() == words,
      ),
    );

    // A picture, sent the way the attach button does after the file dialog.
    final connection = await ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(connectionProvider.future);
    final picture = await preparePicture(
      bytes: File('assets/logo.png').readAsBytesSync(),
    );
    final view = connection!.gateway.channels.firstWhere(
      (v) => v.channel.name == channel,
    );
    connection.chats.send(view.channel.id, '', picture: picture);
    await waitFor(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is Image && w.image is MemoryImage ||
            w is Image &&
                w.image is ResizeImage &&
                (w.image as ResizeImage).imageProvider is MemoryImage,
      ),
    );
  });
}
