import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/crash_reports.dart';

void main() {
  test('reports keep what broke but no addresses', () {
    expect(
      scrub(
        "SocketException: Failed host lookup: 'talk.wiseless.net' "
        '(OS Error: No address, errno = -2), address = 10.0.0.5, port = 443',
      ),
      "SocketException: Failed host lookup: '<host>' "
      '(OS Error: No address, errno = -2), address = <ip>, port = 443',
    );
    expect(
      scrub('ClientException: Connection refused, uri=https://a.b/api/me'),
      'ClientException: Connection refused, uri=<url>',
    );
    expect(scrub('mail me at someone@example.org'), 'mail me at <email>');
    expect(
      scrub('Null check operator used on a null value'),
      'Null check operator used on a null value',
    );
    expect(scrub('at fe80::1%eth0 and [2a01:4f8::2]:443'), contains('<ip>'));
  });
}
