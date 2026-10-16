// Device keys of the people in my calls, remembered per server (WLK-18,
// core's `trust` through the bridge). Only warnings, nothing to confirm or
// compare: a new device of someone I know is a toast, a changed key a quiet
// key mark next to them for the rest of the call. Devices not seen for a
// while are forgotten, sooner on servers without guests.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../src/rust/api/trust.dart';
import 'protocol.dart';
import 'secrets.dart';

String knownKeysKey(Uri origin) => 'knownKeys:$origin';

/// The part of core's `KnownKeys` the review needs.
abstract interface class KeyBook {
  String check(Participant p);
  bool accept(Participant p, int now);
}

class Review {
  /// Someone I know came from a device I had not seen.
  final newDevices = <Participant>[];

  /// Sessions whose device came with another key than before.
  final changed = <String>[];

  /// The record changed and should be saved.
  bool save = false;
}

/// Checks everyone but me and accepts what they came with, so each notice
/// shows once. Guests are never remembered.
Review reviewKeys(
  KeyBook book,
  Iterable<Participant> participants,
  String? me,
  int now,
) {
  final review = Review();
  for (final p in participants) {
    if (p.session == me) continue;
    final String verdict;
    try {
      verdict = book.check(p);
    } catch (e) {
      debugPrint('cannot check a device key: $e');
      continue;
    }
    if (verdict == 'guest') continue;
    if (verdict == 'new_device') review.newDevices.add(p);
    if (verdict == 'key_changed') review.changed.add(p.session);
    if (book.accept(p, now)) review.save = true;
  }
  return review;
}

class _Bridge implements KeyBook {
  _Bridge(this.keys);

  final KnownKeys keys;

  @override
  String check(Participant p) =>
      keys.check(account: p.account, device: p.device, publicKey: p.publicKey);

  @override
  bool accept(Participant p, int now) => keys.accept(
    account: p.account,
    device: p.device,
    publicKey: p.publicKey,
    now: now,
  );
}

class KeyWatch {
  KeyWatch(this._secrets, this._origin, Future<bool> guestsOpen) {
    unawaited(
      guestsOpen.then((open) => _guestsOpen = open).catchError((_) => true),
    );
  }

  final Secrets _secrets;
  final Uri _origin;

  /// Until the server says otherwise, remember longer.
  bool _guestsOpen = true;
  Future<KnownKeys>? _keys;

  /// Sessions in my call whose device key changed since I last met them.
  final changed = <String>{};

  final _newDevices = StreamController<Participant>.broadcast();

  /// Someone I know came from a new device: say so in a toast.
  Stream<Participant> get newDevices => _newDevices.stream;

  /// Looks at people who are in my call, or just joined it. Returns whether
  /// [changed] changed.
  Future<bool> review(Iterable<Participant> participants, String? me) async {
    final keys = await (_keys ??= _load());
    final now = DateTime.now().millisecondsSinceEpoch;
    final forgot = keys.forgetUnseen(now: now, guestsOpen: _guestsOpen);
    final review = reviewKeys(_Bridge(keys), participants, me, now);
    if (forgot || review.save) {
      try {
        await _secrets.write(knownKeysKey(_origin), keys.toJson());
      } catch (e) {
        debugPrint('cannot save known device keys: $e');
      }
    }
    review.newDevices.forEach(_newDevices.add);
    final before = changed.length;
    changed.addAll(review.changed);
    return changed.length != before;
  }

  /// Out of the call: the marks belonged to it.
  void clear() => changed.clear();

  void dispose() => unawaited(_newDevices.close());

  Future<KnownKeys> _load() async {
    final stored = await _secrets.read(knownKeysKey(_origin));
    if (stored == null) return KnownKeys.empty();
    try {
      return KnownKeys.fromJson(json: stored);
    } catch (e) {
      // Damaged, or written by a newer build: start over rather than stop
      // warning.
      debugPrint('cannot read known device keys: $e');
      return KnownKeys.empty();
    }
  }
}
