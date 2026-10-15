// The forms on a phone-sized screen (412 x 915, as a Galaxy S25 Ultra
// reports itself), as a server owner on the local server: each one opens
// as a page, with the keyboard up and with large text too. Needs an
// owner's session, as manage_test.dart does, passed as WISETALK_TEST_TOKEN.
// With WISETALK_SHOTS=<folder> it saves a picture of each, at the phone's
// own pixel density: that's what it's for, since how they look is judged
// by eye.

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/data/servers.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';
import 'package:wisetalk/ui/settings_sheet.dart';

const _density = 2.625;
const _size = Size(412, 915);

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
  expect(finder, findsWidgets);
}

/// Lets a sheet finish sliding in or out.
Future<void> settle(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 600));

/// Saves what the phone-sized view shows, when WISETALK_SHOTS names a
/// folder.
Future<void> shot(WidgetTester tester, String name) async {
  final folder = Platform.environment['WISETALK_SHOTS'];
  if (folder == null) return;
  await settle(tester);
  await tester.runAsync(() async {
    final view = RendererBinding.instance.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    final image = await layer.toImage(view.paintBounds);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$folder/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

/// The list of the sheet on top.
Finder get _sheetList => find
    .descendant(of: find.byType(SettingsSheet), matching: find.byType(ListView))
    .last;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => RustLib.init());

  final token = Platform.environment['WISETALK_TEST_TOKEN'];

  testWidgets('the forms open as pages on a phone', skip: token == null, (
    tester,
  ) async {
    tester.view.devicePixelRatio = _density;
    tester.view.physicalSize = _size * _density;
    // The status bar above and the gesture bar below.
    tester.view.padding = const FakeViewPadding(
      top: 40 * _density,
      bottom: 24 * _density,
    );
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearAllTestValues);

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

    // Settings: Done only, top right.
    await tester.tap(find.byTooltip('Settings'));
    await waitFor(tester, find.text('Audio and Video'));
    expect(find.byType(Dialog), findsNothing);
    await shot(tester, 'phone-01-settings');
    await tester.tap(find.text('Done'));
    await settle(tester);

    // Channel settings: the top, the end, a menu, the keyboard, big text.
    final channel = find.byIcon(Icons.volume_up_outlined).first;
    await tester.tap(channel, buttons: kSecondaryButton);
    await waitFor(tester, find.text('Channel Settings…'));
    await tester.tap(find.text('Channel Settings…'));
    await waitFor(tester, find.text('People and Sound'));
    await shot(tester, 'phone-02-channel-settings');
    await tester.drag(_sheetList, const Offset(0, -3000));
    await shot(tester, 'phone-03-channel-settings-end');
    expect(find.text('Delete Channel…'), findsOneWidget);
    await tester.tap(find.text('Audio Quality'));
    await shot(tester, 'phone-04-picker-menu');
    // The current choice again: the menu closes, nothing changes.
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<int>, '64 kbps (speech)'),
    );
    await settle(tester);
    expect(find.text('People and Sound'), findsOneWidget);

    // Back to the top without a swipe down, which would close the page.
    await tester.ensureVisible(find.text('Name'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextFieldRow, 'Name'));
    tester.view.viewInsets = const FakeViewPadding(bottom: 330 * _density);
    await shot(tester, 'phone-05-channel-settings-keyboard');
    final save = tester.getRect(find.widgetWithText(TextButton, 'Save'));
    final name = tester.getRect(find.widgetWithText(TextFieldRow, 'Name'));
    expect(save.top, greaterThanOrEqualTo(40));
    expect(name.bottom, lessThan(_size.height - 330));

    // The Max People field, further down, comes up above the keyboard.
    await tester.tap(find.widgetWithText(TextFieldRow, 'Max People'));
    await shot(tester, 'phone-06-channel-settings-keyboard-lower');
    expect(
      tester.getRect(find.widgetWithText(TextFieldRow, 'Max People')).bottom,
      lessThan(_size.height - 330),
    );
    tester.view.resetViewInsets();
    FocusManager.instance.primaryFocus?.unfocus();

    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    await shot(tester, 'phone-07-channel-settings-large-text');
    expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
    await tester.drag(_sheetList, const Offset(0, -3000));
    await shot(tester, 'phone-08-channel-settings-large-text-end');
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('People and Sound'), findsNothing);

    // Space settings.
    await tester.tap(find.text('CS 2').first, buttons: kSecondaryButton);
    await waitFor(tester, find.text('Space Settings…'));
    await tester.tap(find.text('Space Settings…'));
    await waitFor(tester, find.text('Access'));
    await shot(tester, 'phone-09-space-settings');
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    // A new channel, typed into: closing asks first.
    await tester.tap(find.byTooltip('New Channel or Space'));
    await waitFor(tester, find.text('New Channel'));
    await tester.enterText(find.byType(TextField).last, 'Test Room');
    await settle(tester);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Create'))
          .enabled,
      isTrue,
    );
    await shot(tester, 'phone-10-create');
    await tester.tap(find.text('Cancel'));
    await waitFor(tester, find.text('Discard Changes?'));
    await shot(tester, 'phone-11-discard');
    await tester.tap(find.text('Discard'));
    await settle(tester);

    // In a call: Summon, and sharing the screen.
    await tester.tap(channel);
    await waitFor(tester, find.byTooltip('Summon'));
    // The button waits for the call to connect.
    for (
      var i = 0;
      i < 40 && find.textContaining('Summon to').evaluate().isEmpty;
      i++
    ) {
      await tester.tap(find.byTooltip('Summon'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
    }
    await waitFor(tester, find.textContaining('Summon to'));
    await tester.enterText(find.byType(TextField).last, 'o');
    await waitFor(tester, find.byType(CheckRow));
    await shot(tester, 'phone-12-summon');
    await tester.tap(find.text('Cancel'));
    await settle(tester);

    await waitFor(tester, find.byTooltip('Share Screen'));
    await tester.tap(find.byTooltip('Share Screen'));
    await waitFor(tester, find.text('Share Your Screen'));
    expect(find.byType(BottomSheet), findsOneWidget);
    await shot(tester, 'phone-13-share-screen');
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    await tester.tap(find.byTooltip('Leave'));
    await tester.pump(const Duration(seconds: 1));

    // Another server, from the list of servers.
    await tester.tap(find.byTooltip('More'));
    await waitFor(tester, find.text('Change Server'));
    await tester.tap(find.text('Change Server'));
    await waitFor(tester, find.text('Add a Server…'));
    await tester.tap(find.text('Add a Server…'));
    await waitFor(tester, find.text('Connect'));
    await shot(tester, 'phone-14-add-server');
    await tester.tap(find.text('Cancel'));
    await settle(tester);
  });
}
