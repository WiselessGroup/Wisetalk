// Device keys remembered per server (core's `trust` through the bridge): of
// the people in my calls (WLK-18) and of my own account's devices a chat key
// goes to (WLK-37). Only warnings, nothing to confirm or compare: a new
// device of someone I know is a toast, a changed key a quiet key mark next
// to them for the rest of the call; a device added to my own account is a
// toast. Devices not seen for a while are forgotten, sooner on servers
// without guests.

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../src/rust/api/trust.dart';
import 'language.dart';
import 'protocol.dart';
import 'secrets.dart';

String knownKeysKey(Uri origin) => 'knownKeys:$origin';

/// The part of core's `KnownKeys` the review needs.
abstract interface class KeyBook {
  String check(String? account, String device, String publicKey);
  bool accept(String? account, String device, String publicKey, int now);
}

String? _verdict(KeyBook book, String? account, String device, String key) {
  try {
    return book.check(account, device, key);
  } catch (e) {
    debugPrint('cannot check a device key: $e');
    return null;
  }
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
    final verdict = _verdict(book, p.account, p.device, p.publicKey);
    if (verdict == null || verdict == 'guest') continue;
    if (verdict == 'new_device') review.newDevices.add(p);
    if (verdict == 'key_changed') review.changed.add(p.session);
    if (book.accept(p.account, p.device, p.publicKey, now)) review.save = true;
  }
  return review;
}

class MineReview {
  /// Devices of my account I had not seen.
  int added = 0;

  /// Devices of my account that came with another key.
  int changed = 0;
  bool save = false;
}

/// My own account's devices among those a chat key goes to or is asked
/// for. The server could slip in a device of its own under my account and
/// be handed the chat key; others' devices are watched in calls. Every
/// verdict comes before anything is accepted, so the first look at several
/// devices is quiet, and a whole list ages and is forgotten together.
MineReview reviewMine(
  KeyBook book,
  Iterable<DeviceKey> devices,
  String account,
  int now,
) {
  final review = MineReview();
  final mine = devices.where((d) => d.account == account).toList();
  final verdicts = [
    for (final d in mine) _verdict(book, account, d.device, d.publicKey),
  ];
  for (var i = 0; i < mine.length; i++) {
    final verdict = verdicts[i];
    if (verdict == null) continue;
    if (verdict == 'new_device') review.added++;
    if (verdict == 'key_changed') review.changed++;
    if (book.accept(account, mine[i].device, mine[i].publicKey, now)) {
      review.save = true;
    }
  }
  return review;
}

class _Bridge implements KeyBook {
  _Bridge(this.keys);

  final KnownKeys keys;

  @override
  String check(String? account, String device, String publicKey) =>
      keys.check(account: account, device: device, publicKey: publicKey);

  @override
  bool accept(String? account, String device, String publicKey, int now) => keys
      .accept(account: account, device: device, publicKey: publicKey, now: now);
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

  final _notices = StreamController<String>.broadcast();

  /// What to say in a toast: someone I know came from a new device, or a
  /// device was added to my account.
  Stream<String> get notices => _notices.stream;

  /// Looks at people who are in my call, or just joined it. Returns whether
  /// [changed] changed.
  Future<bool> review(Iterable<Participant> participants, String? me) async {
    final (keys, now, forgot) = await _record();
    final review = reviewKeys(_Bridge(keys), participants, me, now);
    if (forgot || review.save) await _store(keys);
    for (final p in review.newDevices) {
      _notices.add(appTexts.trustNewDevice(p.displayName));
    }
    final before = changed.length;
    changed.addAll(review.changed);
    return changed.length != before;
  }

  /// Warns about devices added to my account; see [reviewMine].
  Future<void> watchMine(Iterable<DeviceKey> devices, String? account) async {
    if (account == null) return;
    final (keys, now, forgot) = await _record();
    final review = reviewMine(_Bridge(keys), devices, account, now);
    if (forgot || review.save) await _store(keys);
    final texts = appTexts;
    if (review.added > 0) _notices.add(texts.trustMineAdded(review.added));
    if (review.changed > 0) _notices.add(texts.trustMineChanged);
  }

  /// The record, with devices not seen for a while forgotten.
  Future<(KnownKeys, int, bool)> _record() async {
    final keys = await (_keys ??= _load());
    final now = DateTime.now().millisecondsSinceEpoch;
    return (keys, now, keys.forgetUnseen(now: now, guestsOpen: _guestsOpen));
  }

  Future<void> _store(KnownKeys keys) async {
    try {
      await _secrets.write(knownKeysKey(_origin), keys.toJson());
    } catch (e) {
      debugPrint('cannot save known device keys: $e');
    }
  }

  /// Out of the call: the marks belonged to it.
  void clear() => changed.clear();

  void dispose() => unawaited(_notices.close());

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
