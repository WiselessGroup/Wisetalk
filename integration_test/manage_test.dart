// Settings, the channel list's menus and folding spaces, as a server owner
// on the local server. Needs an owner's session made by hand in its
// database (see video_test.dart for how), passed as WISETALK_TEST_TOKEN.
// With WISETALK_SHOTS=<folder> it also saves a picture of each step.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';
import 'package:wisetalk/ui/settings_sheet.dart';

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(finder, findsWidgets);
}

/// Saves what the window shows, when WISETALK_SHOTS names a folder.
Future<void> shot(WidgetTester tester, String name) async {
  final folder = Platform.environment['WISETALK_SHOTS'];
  if (folder == null) return;
  await tester.pump(const Duration(milliseconds: 400));
  await tester.runAsync(() async {
    final view = RendererBinding.instance.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    final image = await layer.toImage(view.paintBounds);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$folder/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => RustLib.init());

  final token = Platform.environment['WISETALK_TEST_TOKEN'];

  testWidgets(
    'an owner finds settings, menus and folding spaces',
    skip: token == null,
    (tester) async {
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
      await waitFor(tester, find.byTooltip('Settings'));
      await shot(tester, '1-list');

      await tester.tap(find.byTooltip('Settings'));
      await waitFor(tester, find.text('Audio and Video'));
      expect(find.text('Voice Processing'), findsOneWidget);
      await waitFor(tester, find.text('Others May Summon Me'));
      await shot(tester, '2-settings');
      await tester.tap(find.text('Done'));
      await tester.pump(const Duration(milliseconds: 400));

      // A channel's menu, on a right click.
      final channel = find.byIcon(Icons.volume_up_outlined).first;
      await tester.tap(channel, buttons: kSecondaryButton);
      await waitFor(tester, find.text('Channel Settings…'));
      await shot(tester, '3-channel-menu');
      await tester.tap(find.text('Channel Settings…'));
      await waitFor(tester, find.text('People and Sound'));
      await shot(tester, '4-channel-settings');
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 400));

      // In the call: our own row's menu, and the call's buttons.
      await tester.tap(channel);
      await waitFor(tester, find.byTooltip('Copy Invite Link'));
      await waitFor(tester, find.textContaining('Boss'));
      await tester.tap(find.text('Boss').first);
      await waitFor(tester, find.text('Audio and Video Settings…'));
      await shot(tester, '5-own-menu');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byTooltip('Summon'));
      await waitFor(tester, find.textContaining('Summon to'));
      await shot(tester, '6-summon');
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byTooltip('New Channel or Space'));
      await waitFor(tester, find.text('New Channel'));
      await shot(tester, '7-create');
      await tester.enterText(find.byType(TextField), 'Test Room');
      // Create works once there's a name, a frame later.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Create'));
      await waitFor(tester, find.text('Test Room'));
      // The dialog fades out first.
      await tester.pump(const Duration(seconds: 1));

      // Up one place, Accounts Only on, then gone again.
      await tester.tap(find.text('Test Room'), buttons: kSecondaryButton);
      await waitFor(tester, find.textContaining('Move '));
      await tester.pump(const Duration(milliseconds: 500));
      final topBefore = tester.getTopLeft(find.text('Test Room').first).dy;
      await tester.tap(find.textContaining('Move ').first);
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester.getTopLeft(find.text('Test Room').first).dy,
        isNot(topBefore),
      );
      await tester.tap(find.text('Test Room'), buttons: kSecondaryButton);
      await waitFor(tester, find.text('Channel Settings…'));
      await tester.tap(find.text('Channel Settings…'));
      await waitFor(tester, find.text('Accounts Only'));
      await tester.ensureVisible(find.text('Accounts Only'));
      await tester.tap(find.text('Accounts Only'));
      // Save works once something changed, a frame later.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Save'));
      await tester.pump(const Duration(seconds: 1));
      await shot(tester, '9-moved');

      // Dragged by its handle onto a space's name: into that space, a step in.
      final leftBefore = tester.getTopLeft(find.text('Test Room').first).dx;
      final grip = find.byTooltip('Drag Test Room');
      final drag = await tester.startGesture(tester.getCenter(grip));
      await tester.pump(const Duration(milliseconds: 100));
      final target = tester.getCenter(find.text('DOTA 2').first);
      for (var i = 1; i <= 10; i++) {
        await drag.moveTo(Offset.lerp(tester.getCenter(grip), target, i / 10)!);
        await tester.pump(const Duration(milliseconds: 50));
      }
      await shot(tester, '10-dragging');
      await drag.up();
      await tester.pump(const Duration(seconds: 2));
      await shot(tester, '11-dropped');
      expect(
        tester.getTopLeft(find.text('Test Room').first).dx,
        greaterThan(leftBefore),
      );
      await tester.tap(find.text('Test Room'), buttons: kSecondaryButton);
      await waitFor(tester, find.text('Channel Settings…'));
      await tester.tap(find.text('Channel Settings…'));
      await waitFor(tester, find.text('Accounts Only'));
      final accountsOnly = tester.widget<SwitchRow>(
        find.widgetWithText(SwitchRow, 'Accounts Only'),
      );
      expect(accountsOnly.value, isTrue);
      // The sheet's list builds its rows as they scroll into view.
      await tester.scrollUntilVisible(
        find.text('Delete Channel…'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(SettingsSheet),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Delete Channel…'));
      await waitFor(tester, find.widgetWithText(FilledButton, 'Delete'));
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      for (var i = 0; i < 50; i++) {
        if (find.text('Test Room').evaluate().isEmpty) break;
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text('Test Room'), findsNothing);

      // Folding the first space hides its channels but the call.
      final chevron = find.byIcon(Icons.chevron_right);
      if (chevron.evaluate().isNotEmpty) {
        await tester.tap(chevron.first);
        await tester.pump(const Duration(milliseconds: 400));
        await shot(tester, '8-folded');
        await tester.tap(chevron.first);
        await tester.pump(const Duration(milliseconds: 400));
      }
      await tester.tap(find.byTooltip('Leave'));
      await tester.pump(const Duration(seconds: 1));
    },
  );
}
