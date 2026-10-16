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

/// Answers with a fixed verdict per device and records what was accepted.
class _Book implements KeyBook {
  _Book(this.verdicts);

  final Map<String, String> verdicts;
  final accepted = <String>[];

  String _name(String device) => device.replaceAll('-device', '');

  @override
  String check(String? account, String device, String publicKey) =>
      account == null ? 'guest' : verdicts[_name(device)]!;

  @override
  bool accept(String? account, String device, String publicKey, int now) {
    accepted.add(_name(device));
    return verdicts[_name(device)] != 'known';
  }
}

/// Answers like core: an unknown account is a first contact, another device
/// of a known one a new device.
class _Core implements KeyBook {
  final known = <String>{};

  @override
  String check(String? account, String device, String publicKey) =>
      known.isEmpty
      ? 'first_contact'
      : known.contains(device)
      ? 'known'
      : 'new_device';

  @override
  bool accept(String? account, String device, String publicKey, int now) =>
      known.add(device);
}

DeviceKey _device(String name, String? account) =>
    DeviceKey(device: '$name-device', publicKey: '$name-key', account: account);

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

  test('devices added to my account are counted, the list accepted', () {
    final book = _Book({
      'laptop': 'known',
      'planted': 'new_device',
      'swapped': 'key_changed',
    });
    final review = reviewMine(
      book,
      [
        _device('laptop', 'me'),
        _device('planted', 'me'),
        _device('swapped', 'me'),
      ],
      'me',
      1000,
    );
    expect((review.added, review.changed, review.save), (1, 1, true));
    expect(book.accepted, ['laptop', 'planted', 'swapped']);
  });

  test('a first list of several devices is a first contact for all', () {
    final core = _Core();
    final first = reviewMine(
      core,
      [_device('phone', 'me'), _device('laptop', 'me')],
      'me',
      1000,
    );
    expect((first.added, first.save), (0, true));
    final later = reviewMine(
      core,
      [_device('laptop', 'me'), _device('planted', 'me')],
      'me',
      2000,
    );
    expect(later.added, 1);
  });

  test('others, guests and old servers are left to the calls', () {
    final book = _Book({'pal': 'new_device'});
    final review = reviewMine(
      book,
      [_device('pal', 'a3'), _device('guest', null)],
      'me',
      1000,
    );
    expect((review.added, review.save), (0, false));
    expect(book.accepted, isEmpty);
  });
}
