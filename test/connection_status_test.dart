// The numbers cost a timer and getStats() calls; these check they run only
// while the popover is open or the numbers are on and the window shows
// (ADR-0019). testWidgets also fails if a timer outlives the test.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:wisetalk/data/link.dart';
import 'package:wisetalk/data/link_stats.dart';
import 'package:wisetalk/data/preferences.dart';
import 'package:wisetalk/l10n/app_localizations.dart';
import 'package:wisetalk/data/secrets.dart';
import 'package:wisetalk/theme.dart';
import 'package:wisetalk/ui/connection_status.dart';

void main() {
  late int rounds;
  late LinkMonitor link;
  late Qualities qualities;
  late Preferences preferences;

  setUp(() {
    rounds = 0;
    var now = Duration.zero;
    link = LinkMonitor((at) async {
      rounds++;
      return LinkSample(at: at, rtt: 0.042, micBytes: 1000);
    }, clock: () => now += const Duration(seconds: 1));
    qualities = Qualities();
    preferences = Preferences(MemorySecrets());
  });

  tearDown(() {
    link.dispose();
    qualities.dispose();
    preferences.dispose();
  });

  Future<void> show(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: themeFor(Brightness.dark),
      home: Scaffold(
        body: Center(
          child: ConnectionStatus(
            quality: qualities.of('me'),
            link: link,
            preferences: preferences,
          ),
        ),
      ),
    ),
  );

  testWidgets('measures nothing while the popover is closed', (tester) async {
    await show(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(link.running, isFalse);
    expect(rounds, 0);
  });

  testWidgets('measures once a second while the popover is open', (
    tester,
  ) async {
    await show(tester);
    await tester.tap(find.byType(ConnectionStatus));
    await tester.pump();
    expect(link.running, isTrue);
    expect(find.text('42 ms'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(rounds, 4);

    // Tapping again closes it, and the timer goes with it.
    await tester.tap(find.byType(ConnectionStatus));
    await tester.pump();
    expect(link.running, isFalse);
    expect(find.text('42 ms'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    expect(rounds, 4);
  });

  testWidgets('opens while the mouse hovers, stays open after a click', (
    tester,
  ) async {
    await show(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.byType(ConnectionStatus)));
    await tester.pump();
    expect(link.running, isTrue);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(link.running, isFalse);

    await mouse.moveTo(tester.getCenter(find.byType(ConnectionStatus)));
    await tester.pump();
    await tester.tap(
      find.byType(ConnectionStatus),
      kind: PointerDeviceKind.mouse,
    );
    await mouse.moveTo(const Offset(5, 300));
    await tester.pump();
    expect(link.running, isTrue, reason: 'pinned by the click');
    await tester.tap(
      find.byType(ConnectionStatus),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(link.running, isFalse);
  });

  testWidgets('closes the popover on a tap elsewhere', (tester) async {
    await show(tester);
    await tester.tap(find.byType(ConnectionStatus));
    await tester.pump();
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(link.running, isFalse);
  });

  testWidgets('shows ping and loss while the window shows', (tester) async {
    preferences.showPingAndLoss = true;
    await show(tester);
    await tester.pump();
    expect(link.running, isTrue);
    expect(find.text('42 ms · — loss'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(link.running, isTrue, reason: 'unfocused is still visible');

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    expect(link.running, isFalse);
    final before = rounds;
    await tester.pump(const Duration(seconds: 3));
    expect(rounds, before);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(link.running, isTrue);

    preferences
      ..showPingAndLoss = false
      ..changed();
    await tester.pump();
    expect(link.running, isFalse);
    expect(find.textContaining('ms ·'), findsNothing);
  });

  testWidgets('stops measuring when the call ends', (tester) async {
    preferences.showPingAndLoss = true;
    await show(tester);
    await tester.tap(find.byType(ConnectionStatus));
    await tester.pump();
    expect(link.running, isTrue);
    await tester.pumpWidget(const SizedBox());
    expect(link.running, isFalse);
  });

  testWidgets('follows the quality without measuring', (tester) async {
    await show(tester);
    expect(find.byTooltip('Connection: Checking'), findsOneWidget);
    qualities.set('me', lk.ConnectionQuality.poor);
    await tester.pump();
    expect(find.byTooltip('Connection: Poor'), findsOneWidget);
    expect(link.running, isFalse);
  });

  testWidgets('others get bars only when poor or lost', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: themeFor(Brightness.dark),
        home: QualityMark(quality: qualities.of('them')),
      ),
    );
    for (final (quality, shown) in [
      (lk.ConnectionQuality.excellent, false),
      (lk.ConnectionQuality.good, false),
      (lk.ConnectionQuality.poor, true),
      (lk.ConnectionQuality.lost, true),
      (lk.ConnectionQuality.unknown, false),
    ]) {
      qualities.set('them', quality);
      await tester.pump();
      expect(
        find.byType(SignalBars),
        shown ? findsOneWidget : findsNothing,
        reason: '$quality',
      );
    }
  });
}
