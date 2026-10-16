import 'package:flutter_test/flutter_test.dart';
import 'package:wisetalk/data/protocol.dart';
import 'package:wisetalk/data/trust.dart';

Participant _person(String session, String? account) => Participant(
  session: session,
  displayName: session,
  device: '$session-device',
  publicKey: '$session-key',
  serverMuted: false,
  account: account,
);

/// Answers with a fixed verdict per session and records what was accepted.
class _Book implements KeyBook {
  _Book(this.verdicts);

  final Map<String, String> verdicts;
  final accepted = <String>[];

  @override
  String check(Participant p) =>
      p.account == null ? 'guest' : verdicts[p.session]!;

  @override
  bool accept(Participant p, int now) {
    accepted.add(p.session);
    return verdicts[p.session] != 'known';
  }
}

void main() {
  test(
    'new devices and changed keys are noticed, and accepted to show once',
    () {
      final book = _Book({
        'sanya': 'new_device',
        'owl': 'key_changed',
        'pal': 'known',
      });
      final review = reviewKeys(
        book,
        [_person('sanya', 'a1'), _person('owl', 'a2'), _person('pal', 'a3')],
        'me',
        1000,
      );
      expect(review.newDevices.map((p) => p.session), ['sanya']);
      expect(review.changed, ['owl']);
      expect(review.save, isTrue);
      expect(book.accepted, ['sanya', 'owl', 'pal']);
    },
  );

  test('first contacts are remembered silently', () {
    final review = reviewKeys(
      _Book({'pal': 'first_contact'}),
      [_person('pal', 'a3')],
      'me',
      1000,
    );
    expect(review.newDevices, isEmpty);
    expect(review.changed, isEmpty);
    expect(review.save, isTrue);
  });

  test('me and guests are left alone', () {
    final book = _Book({'me': 'key_changed'});
    final review = reviewKeys(
      book,
      [_person('me', 'a0'), _person('guest', null)],
      'me',
      1000,
    );
    expect(review.changed, isEmpty);
    expect(review.save, isFalse);
    expect(book.accepted, isEmpty);
  });

  test('records are kept per server', () {
    expect(
      knownKeysKey(Uri.parse('https://talk.example.com')),
      'knownKeys:https://talk.example.com',
    );
  });
}
