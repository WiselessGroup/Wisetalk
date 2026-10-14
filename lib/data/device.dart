// This device's key pair on one server, made in Rust (wisetalk-core). An
// account keeps it in the system's secret store, so the fingerprint others
// see stays the same; a guest gets a fresh one per session, as in the web
// client.

import 'dart:convert';
import 'dart:math';

import '../src/rust/api/device.dart';
import 'secrets.dart';
import 'servers.dart';

class LocalDevice {
  const LocalDevice(this.id, this.keys);

  final String id;
  final Device keys;
}

Future<LocalDevice> localDevice(
  Secrets secrets,
  Uri origin, {
  required bool guest,
}) async {
  if (guest) return LocalDevice(_uuid(), Device.generate());
  final stored = await secrets.read(deviceKey(origin));
  if (stored != null) {
    try {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      return LocalDevice(
        json['id'] as String,
        Device.fromSecret(secret: base64Decode(json['secret'] as String)),
      );
    } catch (_) {
      // Unreadable: make a new one, chat keys are asked for again.
    }
  }
  final device = LocalDevice(_uuid(), Device.generate());
  try {
    await secrets.write(
      deviceKey(origin),
      jsonEncode({
        'id': device.id,
        'secret': base64Encode(device.keys.secretBytes()),
      }),
    );
  } catch (_) {
    // Kept for this run only; the next start makes another.
  }
  return device;
}

/// A random UUID (version 4) naming the device; not a secret.
String _uuid() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
