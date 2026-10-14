import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/updates.dart';

void main() {
  test('compares versions part by part', () {
    expect(isNewer('0.2.0', '0.1.9'), isTrue);
    expect(isNewer('0.10.0', '0.9.0'), isTrue);
    expect(isNewer('1.0.0', '1.0.0'), isFalse);
    expect(isNewer('0.1.0', '0.1.1'), isFalse);
    expect(isNewer('0.1.1', '0.1.1-beta'), isFalse);
  });
}
