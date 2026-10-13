import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/main.dart';
import 'package:wisetalk/src/rust/frb_generated.dart';

void main() {
  setUpAll(() async => RustLib.init());

  testWidgets('shows the protocol version and a device fingerprint', (
    tester,
  ) async {
    await tester.pumpWidget(const WisetalkApp());
    expect(find.text('Wisetalk'), findsOneWidget);
    expect(find.textContaining('Protocol 4'), findsOneWidget);
  });
}
