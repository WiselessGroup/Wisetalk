// How SettingsSheet behaves: which look it picks for the window, when its
// prominent button works, and when closing asks first. Looks are checked
// by hand; these check logic and that nothing goes out of reach.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/l10n/app_localizations.dart';
import 'package:wisetalk/theme.dart';
import 'package:wisetalk/ui/settings_sheet.dart';

const _phone = Size(412, 915);
const _desktop = Size(1280, 800);

/// A name to edit: Save works once it's changed and not empty.
class _NameForm extends StatefulWidget {
  const _NameForm({this.onSave});

  final Future<void> Function()? onSave;

  @override
  State<_NameForm> createState() => _NameFormState();
}

class _NameFormState extends State<_NameForm> {
  late final _name = TextEditingController(text: 'Lobby')
    ..addListener(() => setState(() {}));
  final _limit = TextEditingController();
  var _quality = 64;

  bool get _dirty => _name.text != 'Lobby' || _quality != 64;

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.onSave?.call();
    if (mounted) Navigator.pop(context, _name.text);
  }

  @override
  Widget build(BuildContext context) => SettingsSheet(
    title: 'Channel Settings',
    action: 'Save',
    dirty: _dirty,
    onAction: _dirty && _name.text.trim().isNotEmpty ? _save : null,
    children: [
      SettingsGroup(
        footer: 'What everyone sees in the list.',
        children: [
          TextFieldRow(label: 'Name', controller: _name, maxLength: 20),
          PickerRow<int>(
            label: 'Audio Quality',
            value: _quality,
            options: const [(64, '64 kbps'), (128, '128 kbps')],
            onChanged: (q) => setState(() => _quality = q),
          ),
        ],
      ),
      for (var i = 0; i < 6; i++)
        SettingsGroup(
          header: 'Group $i',
          children: [
            SwitchRow(label: 'Switch $i', value: false, onChanged: (_) {}),
          ],
        ),
      SettingsGroup(
        children: [TextFieldRow(label: 'Limit', controller: _limit)],
      ),
      SettingsGroup(
        children: [
          ButtonRow(label: 'Delete Channel…', destructive: true, onTap: () {}),
        ],
      ),
    ],
  );
}

/// The app with one button that opens [sheet]; what it returned lands in
/// [results].
Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  WidgetBuilder? sheet,
  List<Object?>? results,
  double textScale = 1,
  bool short = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: themeFor(Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () async {
                final result = await showSettingsSheet<Object?>(
                  context,
                  short: short,
                  builder: sheet ?? (_) => const _NameForm(),
                );
                results?.add(result);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

final _name = find.byType(TextField).first;
final _limit = find.byType(TextField).last;

TextButton _button(WidgetTester tester, String label) =>
    tester.widget<TextButton>(find.widgetWithText(TextButton, label));

void main() {
  testWidgets('a wide window gets a dialog with the buttons bottom right', (
    tester,
  ) async {
    await _pump(tester, size: _desktop);
    expect(find.byType(Dialog), findsOneWidget);
    final title = tester.getRect(find.text('Channel Settings'));
    final save = tester.getRect(find.widgetWithText(FilledButton, 'Save'));
    final cancel = tester.getRect(find.widgetWithText(TextButton, 'Cancel'));
    expect(save.top, greaterThan(title.bottom));
    expect(cancel.right, lessThanOrEqualTo(save.left));
    expect(save.center.dx, greaterThan(_desktop.width / 2));
  });

  testWidgets('a phone gets a page: Cancel, the title, then Save on top', (
    tester,
  ) async {
    await _pump(tester, size: _phone);
    expect(find.byType(Dialog), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Save'), findsNothing);
    final cancel = tester.getRect(find.widgetWithText(TextButton, 'Cancel'));
    final title = tester.getRect(find.text('Channel Settings'));
    final save = tester.getRect(find.widgetWithText(TextButton, 'Save'));
    expect(cancel.right, lessThan(title.left));
    expect(save.left, greaterThan(title.right));
    expect(save.top, lessThan(80));
    // The page covers the whole screen.
    expect(tester.getSize(find.byType(Scaffold).last), _phone);
  });

  testWidgets('a short sheet rises from the bottom on a phone', (tester) async {
    await _pump(tester, size: _phone, short: true);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);
  });

  for (final size in [_phone, _desktop]) {
    testWidgets('Save waits for a change and runs once (${size.width})', (
      tester,
    ) async {
      final results = <Object?>[];
      var saves = 0;
      await _pump(
        tester,
        size: size,
        results: results,
        sheet: (_) => _NameForm(
          onSave: () async {
            saves++;
            await Future<void>.delayed(const Duration(milliseconds: 100));
          },
        ),
      );
      final save = find.widgetWithText(
        size == _phone ? TextButton : FilledButton,
        'Save',
      );
      bool enabled() => tester.widget<ButtonStyleButton>(save).enabled;
      expect(enabled(), isFalse);

      await tester.enterText(_name, '');
      await tester.pump();
      expect(enabled(), isFalse, reason: 'an empty name will not do');

      await tester.enterText(_name, 'Hall');
      await tester.pump();
      expect(enabled(), isTrue);

      await tester.tap(save);
      await tester.pump();
      expect(enabled(), isFalse, reason: 'greyed out while it saves');
      await tester.tap(save, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(saves, 1);
      expect(results, ['Hall']);
    });
  }

  testWidgets('Enter in a field saves, as a form does', (tester) async {
    final results = <Object?>[];
    await _pump(tester, size: _phone, results: results);
    await tester.enterText(_name, 'Hall');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(results, ['Hall']);
  });

  testWidgets('closing untouched just closes', (tester) async {
    final results = <Object?>[];
    await _pump(tester, size: _phone, results: results);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Channel Settings'), findsNothing);
    expect(find.text('Discard Changes?'), findsNothing);
    expect(results, [null]);
  });

  for (final size in [_phone, _desktop]) {
    testWidgets('closing after a change asks first (${size.width})', (
      tester,
    ) async {
      final results = <Object?>[];
      await _pump(tester, size: size, results: results);
      await tester.enterText(_name, 'Hall');
      await tester.pump();

      // The system's Back.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Discard Changes?'), findsOneWidget);
      await tester.tap(find.text('Keep Editing'));
      await tester.pumpAndSettle();
      expect(find.text('Channel Settings'), findsOneWidget);
      expect(find.text('Hall'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(find.text('Channel Settings'), findsNothing);
      expect(results, [null]);
    });
  }

  testWidgets('a swipe down closes the page, or asks after a change', (
    tester,
  ) async {
    await _pump(tester, size: _phone);
    final bar = find.text('Channel Settings');
    await tester.enterText(_name, 'Hall');
    await tester.pump();
    await tester.fling(bar, const Offset(0, 300), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Discard Changes?'), findsOneWidget);
    await tester.tap(find.text('Keep Editing'));
    await tester.pumpAndSettle();
    // Back where it was.
    expect(tester.getTopLeft(bar).dy, lessThan(80));

    await tester.enterText(_name, 'Lobby');
    await tester.pump();
    // Pulling the list down past its top works too.
    await tester.fling(find.text('Name'), const Offset(0, 300), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Discard Changes?'), findsNothing);
    expect(bar, findsNothing);
  });

  testWidgets('a short pull settles back', (tester) async {
    await _pump(tester, size: _phone);
    final bar = find.text('Channel Settings');
    final top = tester.getTopLeft(bar).dy;
    await tester.drag(bar, const Offset(0, 40));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(bar).dy, top);
  });

  testWidgets('with the keyboard up, Save stays and the field shows', (
    tester,
  ) async {
    await _pump(tester, size: _phone, textScale: 2);
    await tester.showKeyboard(_name);
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.pumpAndSettle();
    final save = tester.getRect(find.widgetWithText(TextButton, 'Save'));
    final field = tester.getRect(_name);
    expect(save.top, greaterThanOrEqualTo(0));
    expect(save.bottom, lessThan(field.top));
    expect(field.bottom, lessThanOrEqualTo(_phone.height - 400));
    expect(tester.takeException(), isNull);

    // A field near the bottom, typed in, scrolls up above the keyboard.
    tester.view.resetViewInsets();
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    await tester.tap(_limit);
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    await tester.pumpAndSettle();
    final limit = tester.getRect(_limit);
    expect(limit.top, greaterThan(save.bottom));
    expect(limit.bottom, lessThanOrEqualTo(_phone.height - 400));
  });

  testWidgets('large system text fits on a phone', (tester) async {
    await _pump(tester, size: _phone, textScale: 2);
    expect(tester.takeException(), isNull);
    expect(_button(tester, 'Save'), isNotNull);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('the name counter shows only near the limit', (tester) async {
    await _pump(tester, size: _phone);
    expect(find.textContaining('/20'), findsNothing);
    await tester.enterText(_name, 'A' * 10);
    await tester.pump();
    expect(find.textContaining('/20'), findsNothing);
    await tester.enterText(_name, 'A' * 11);
    await tester.pump();
    expect(find.text('11/20'), findsOneWidget);
    await tester.enterText(_name, 'A' * 30);
    await tester.pump();
    expect(find.text('20/20'), findsOneWidget);
  });

  testWidgets('a picker row opens a menu and takes the choice', (tester) async {
    await _pump(tester, size: _phone);
    expect(find.text('64 kbps'), findsOneWidget);
    await tester.tap(find.text('Audio Quality'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(CheckedPopupMenuItem<int>, '128 kbps'),
    );
    await tester.pumpAndSettle();
    expect(find.text('128 kbps'), findsOneWidget);
    expect(find.text('64 kbps'), findsNothing);
    expect(_button(tester, 'Save').enabled, isTrue);
  });

  testWidgets('without an action there is Done only', (tester) async {
    await _pump(
      tester,
      size: _phone,
      sheet: (_) => const SettingsSheet(
        title: 'Settings',
        children: [
          SettingsGroup(children: [SettingsRow(label: 'Nothing')]),
        ],
      ),
    );
    expect(find.text('Cancel'), findsNothing);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsNothing);
  });
}
