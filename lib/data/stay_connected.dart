// Stay Connected (ADR-0035): on Android the app keeps its own gateway
// connection while it is closed, so summons arrive without Google or a
// push app. StayConnectedService.kt keeps the process alive with a quiet
// ongoing notification and says when the network changes; here the
// connection goes quiet while Wisetalk is in the background (the gateway's
// background mode) and comes back in full when it is opened.
//
// On for accounts unless switched off in Settings, never for guests:
// nobody can summon a guest.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'api.dart';
import 'connection.dart';
import 'language.dart';
import 'notifications.dart';
import 'preferences.dart';
import 'secrets.dart';
import 'servers.dart';
import 'session.dart';

/// Manufacturers dontkillmyapp.com has steps for, by their `Build.MANUFACTURER`.
const _killers = {
  'asus',
  'blackview',
  'google',
  'htc',
  'huawei',
  'lenovo',
  'meizu',
  'motorola',
  'nokia',
  'oneplus',
  'oppo',
  'realme',
  'samsung',
  'sony',
  'tecno',
  'unihertz',
  'vivo',
  'wiko',
  'xiaomi',
};

/// Where the steps to keep Wisetalk running are for phones of [manufacturer].
Uri stepsFor(String? manufacturer) {
  final name = manufacturer?.toLowerCase().trim();
  return Uri.https(
    'dontkillmyapp.com',
    name != null && _killers.contains(name) ? '/$name' : '/',
  );
}

/// Whether Wisetalk is out of sight on the phone: in the background, or
/// started there by the system. Not `inactive`: pulling down the
/// notification shade shouldn't send the connection away and back.
bool awayFrom(AppLifecycleState? state, {bool launchedInBackground = false}) =>
    switch (state) {
      null => launchedInBackground,
      AppLifecycleState.hidden ||
      AppLifecycleState.paused ||
      AppLifecycleState.detached => true,
      AppLifecycleState.resumed || AppLifecycleState.inactive => false,
    };

/// Whether the connection should be quiet: Stay Connected keeps it,
/// Wisetalk is out of sight, and no call needs everything.
bool quietNow({
  required bool staying,
  required bool away,
  required bool inCall,
}) => staying && away && !inCall;

class StayConnected {
  StayConnected(this._preferences) {
    _channel.setMethodCallHandler(_called);
    _lifecycle = AppLifecycleListener(onStateChange: (_) => _update());
    _preferences.addListener(_update);
    unawaited(
      _preferences.loaded.then((_) {
        _preferencesRead = true;
        _update();
      }),
    );
  }

  static const _channel = MethodChannel('net.wiseless.wisetalk/background');

  final Preferences _preferences;
  late final AppLifecycleListener _lifecycle;
  Connection? _connection;

  /// The network is back and there is no connection: the session couldn't
  /// be read without one, read it again.
  VoidCallback? onNetworkBack;

  /// Nothing is decided before the saved preferences and the session are
  /// known: deciding on defaults would stop a service the system just
  /// started to bring the connection back.
  bool _preferencesRead = false;
  bool _connectionKnown = false;

  /// What the service was last started with, to start it again only when
  /// that changes; `null` while it doesn't run.
  (String, String, String)? _running;

  /// The connection of the signed-in session, `null` signed out; set by
  /// [stayConnectedProvider] once the session is known.
  set connection(Connection? connection) {
    _connection?.voice.removeListener(_update);
    _connection = connection;
    _connectionKnown = true;
    connection?.voice.addListener(_update);
    _update();
  }

  /// Stay Connected applies: an account, with summons shown here.
  bool get wanted {
    final connection = _connection;
    return connection != null &&
        !connection.gateway.session.me.isGuest &&
        _preferences.stayConnected &&
        _preferences.notifySummons;
  }

  void _update() {
    if (!_preferencesRead || !_connectionKnown) return;
    final staying = wanted;
    unawaited(_run(staying));
    final connection = _connection;
    connection?.gateway.setBackground(
      quietNow(
        staying: staying,
        away: awayFrom(
          WidgetsBinding.instance.lifecycleState,
          launchedInBackground: launchedInBackground,
        ),
        inCall: connection.voice.channel != null,
      ),
    );
  }

  Future<void> _run(bool staying) async {
    if (!staying) {
      if (_running == null) return;
      _running = null;
      await _invoke('stop');
      return;
    }
    final texts = textsFor(_preferences.language.value);
    final server = _connection!.gateway.session.server.name;
    final wanted = (
      texts.stayConnectedTitle,
      texts.stayConnectedBody(server),
      texts.stayConnectedChannel,
    );
    if (_running == wanted) return;
    _running = wanted;
    final started = await _invoke<bool>('start', {
      'title': wanted.$1,
      'text': wanted.$2,
      'channelName': wanted.$3,
    });
    // Not allowed right now (started from the background without the
    // battery exemption, say): try again at the next change.
    if (started != true && _running == wanted) _running = null;
  }

  Future<dynamic> _called(MethodCall call) async {
    final connection = _connection;
    switch (call.method) {
      case 'network':
        final available = call.arguments == true;
        if (connection == null && available) onNetworkBack?.call();
        connection?.gateway.networkChanged(available);
      case 'closed':
        // Swiped away in a call: the call ends with the window, as before
        // Stay Connected; the connection stays.
        if (connection?.voice.channel != null) connection!.voice.leave();
    }
  }

  /// Whether Android lets Wisetalk keep its connection while the phone
  /// sleeps.
  Future<bool> batteryExempt() async =>
      await _invoke<bool>('batteryExempt') ?? true;

  /// Android's own question about battery optimization.
  Future<void> askBattery() => _invoke('askBattery');

  /// Where the steps for this phone are.
  Future<Uri> steps() async => stepsFor(await _invoke<String>('manufacturer'));

  /// Once, with Stay Connected on and the phone putting Wisetalk to sleep:
  /// why, then Android's question. From the workspace, which has a window.
  Future<void> offerBatteryExemption(BuildContext context) async {
    await _preferences.loaded;
    if (!wanted || _preferences.batteryAsked) return;
    if (await batteryExempt() || !context.mounted) return;
    _preferences.batteryAsked = true;
    _preferences.changed();
    final texts = AppLocalizations.of(context);
    final go = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(texts.batteryTitle),
        content: Text(texts.batteryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(texts.batteryLater),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(texts.batteryContinue),
          ),
        ],
      ),
    );
    if (go == true) await askBattery();
  }

  Future<T?> _invoke<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      debugPrint('stay connected: $e');
    } on MissingPluginException {
      // An engine without the channel: not Android's.
    }
    return null;
  }

  void dispose() {
    _lifecycle.dispose();
    _preferences.removeListener(_update);
    _connection?.voice.removeListener(_update);
    _channel.setMethodCallHandler(null);
  }
}

/// Stay Connected for the life of the app, on Android; `null` elsewhere.
/// Keeps the signed-in session's connection up from the start, also when
/// the system started Wisetalk without a window.
final stayConnectedProvider = Provider<StayConnected?>((ref) {
  if (!Platform.isAndroid) return null;
  final stay = StayConnected(ref.read(preferencesProvider));
  ref.onDispose(stay.dispose);
  // Only a known session decides: a failure (no network when the system
  // started Wisetalk, say) must not stop the service, it retries instead.
  ref.listen(connectionProvider, (_, next) {
    if (next.isLoading || next.hasError) return;
    stay.connection = next.value;
  }, fireImmediately: true);
  stay.onNetworkBack = () {
    if (ref.read(connectionProvider).hasError) ref.invalidate(sessionProvider);
  };
  return stay;
});

/// UnifiedPush endpoints the 0.5 app left on its servers (ADR-0035,
/// WLK-48): asks each server to stop pushing to them, once, at start.
/// What can't be taken back now (no network) is tried at the next start.
Future<void> forgetOldPushEndpoints(Secrets secrets) async {
  final List<SavedServer> servers;
  try {
    final raw = await secrets.read(serversKey);
    if (raw == null) return;
    servers = [
      for (final entry in jsonDecode(raw) as List<dynamic>)
        SavedServer.fromJson(entry as Map<String, dynamic>),
    ];
  } catch (_) {
    return;
  }
  for (final server in servers) {
    final key = 'push-endpoint:${server.origin}';
    try {
      final endpoint = await secrets.read(key);
      if (endpoint == null) continue;
      final token = await secrets.read(tokenKey(server.origin));
      if (token != null) {
        await Api(server.origin, token: token).unsubscribePush(endpoint);
      }
      await secrets.delete(key);
    } on ApiException catch (e) {
      // Gone already, or the session is: nothing left to take back.
      if (e.status >= 400) await secrets.delete(key);
    } catch (e) {
      debugPrint('cannot take an old push endpoint back: $e');
    }
  }
}
