// Where the app keeps what must stay private: session tokens and device
// keys. Behind this small interface so the storage can be swapped in one
// place.
//
// Everything kept here can be recovered: without a token people sign in
// again, without a device key the app makes a new one. So an unreadable
// entry counts as a missing one, and nothing ever falls back to plain text.

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class Secrets {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// The system's own store: Keychain on Apple systems, Keystore on Android,
/// the Secret Service (GNOME Keyring, KWallet) on Linux, DPAPI on Windows.
class SystemSecrets implements Secrets {
  SystemSecrets() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (error) {
      debugPrint('secret storage could not read $key: $error');
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (error) {
      debugPrint('secret storage could not delete $key: $error');
    }
  }
}

/// For tests.
class MemorySecrets implements Secrets {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
