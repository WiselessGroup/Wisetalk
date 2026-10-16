// Summons while Wisetalk is closed, on Android (WLK-10). No Google: the
// phone gets pushes through UnifiedPush, from a distributor app the person
// installs (ntfy, set to the community's own ntfy server). The Wisetalk
// server sends them the same Web Push it sends browsers: it only needs an
// endpoint and keys, which the distributor hands us for each server.
//
// Each server signed in with an account is its own UnifiedPush instance,
// named by its origin, with its endpoint kept in [Secrets] to take it back
// on sign-out. When a push comes and Wisetalk isn't running, the plugin
// starts it without a window (`main` with [pushBackgroundArgument]); only
// what shows the notification runs then. Everywhere else this is a no-op.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
import 'package:unifiedpush_platform_interface/data/push_message.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'api.dart';
import 'notifications.dart';
import 'preferences.dart';
import 'secrets.dart';
import 'servers.dart';
import 'session.dart';

/// What the plugin starts `main` with when a push woke Wisetalk up.
const pushBackgroundArgument = '--unifiedpush-bg';

/// Where the endpoint a server pushes to is kept.
String pushEndpointKey(Uri origin) => 'push-endpoint:$origin';

/// ntfy on F-Droid, the distributor we suggest.
final ntfyStorePage = Uri.parse('https://f-droid.org/packages/io.heckel.ntfy/');

/// A summons, as the server pushes it: the JSON the web client's service
/// worker reads too (`SummonPush` in wisetalk_core::api).
class SummonPush {
  const SummonPush({
    required this.caller,
    required this.channel,
    required this.channelName,
  });

  /// `null` for anything else, or what can't be read.
  static SummonPush? parse(List<int> content) {
    try {
      final json = jsonDecode(utf8.decode(content));
      if (json case {
        'caller': final String caller,
        'channelId': final String channel,
        'channelName': final String channelName,
      }) {
        return SummonPush(
          caller: caller,
          channel: channel,
          channelName: channelName,
        );
      }
    } on FormatException {
      // Not JSON, or not UTF-8: not ours.
    }
    return null;
  }

  /// Display name of whoever summoned.
  final String caller;

  /// The channel's id, and its name for people.
  final String channel;
  final String channelName;
}

/// The body of `POST /api/push/subscriptions`: what a browser's
/// `PushSubscription.toJSON()` gives, keys in base64url.
Map<String, dynamic> pushSubscriptionJson({
  required String endpoint,
  required String p256dh,
  required String auth,
}) => {
  'endpoint': endpoint,
  'keys': {'p256dh': p256dh, 'auth': auth},
};

/// A distributor's name for people, from its Android package.
String distributorName(String package) => switch (package) {
  'io.heckel.ntfy' => 'ntfy',
  'org.unifiedpush.distributor.nextpush' => 'NextPush',
  'org.unifiedpush.distributor.sunup' => 'Sunup',
  'eu.siacs.conversations' => 'Conversations',
  'im.molly.app' => 'Molly',
  _ => package.split('.').last,
};

/// The distributors installed on this phone and the one Wisetalk uses.
typedef Distributors = ({List<String> installed, String? chosen});

class UnifiedPushes {
  late final Secrets _secrets = SystemSecrets();
  bool _background = false;
  Future<void>? _ready;
  Notifications? _notifications;
  Preferences? _preferences;

  /// The server the open app is connected to, which tells about its own
  /// summons while it runs.
  Uri? live;

  /// Pushes come to the Android app only.
  bool get available => Platform.isAndroid;

  /// The Android plugin (unifiedpush_android), set when the app starts.
  UnifiedPushPlatform get _plugin => UnifiedPushPlatform.instance;

  /// Sets the plugin up: from `main`, before anything else asks. With
  /// [background], a push started Wisetalk to show its notification.
  Future<void> start({bool background = false}) {
    if (!available) return Future.value();
    _background = _background || background;
    return _ready ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _plugin.initializeCallback(
        onNewEndpoint: (endpoint, instance) =>
            unawaited(_newEndpoint(endpoint, instance)),
        onRegistrationFailed: (reason, instance) =>
            debugPrint('push registration failed: ${reason.name}'),
        onUnregistered: (instance) => unawaited(_unregistered(instance)),
        onMessage: (message, instance) =>
            unawaited(_message(message, instance)),
      );
    } catch (e) {
      debugPrint('UnifiedPush unavailable: $e');
    }
  }

  /// The open app's own notifications and preferences, so a push shows
  /// like any other notification and a tap on it reaches the workspace.
  void attach(Notifications notifications, Preferences preferences) {
    _notifications = notifications;
    _preferences = preferences;
  }

  /// Summons from [origin] come to this phone through the distributor:
  /// registers there with the server's key. The endpoint comes back in
  /// [_newEndpoint]. Called at every start, as UnifiedPush wants.
  Future<void> follow(Uri origin, String token) async {
    if (!available) return;
    await start();
    try {
      // The one chosen before, or the phone's default; none installed, or
      // several and none default, and Settings asks.
      if (!await _plugin.tryUseCurrentOrDefaultDistributor()) return;
      final key = await Api(origin, token: token).pushKey();
      // The server sends no pushes.
      if (key == null) return;
      await _plugin.register('$origin', const [], null, key);
    } catch (e) {
      debugPrint('cannot register for pushes: $e');
    }
  }

  /// No more summons from [origin] here: on signing out or removing the
  /// server, while its token still works.
  Future<void> forget(Uri origin) async {
    if (!available) return;
    await start();
    try {
      await _plugin.unregister('$origin');
    } catch (e) {
      debugPrint('cannot unregister from pushes: $e');
    }
    await _unsubscribe(origin);
  }

  /// Summons switched off: every server stops pushing here.
  Future<void> forgetAll() async {
    if (!available) return;
    for (final origin in await _servers()) {
      await forget(origin);
    }
  }

  /// What Settings shows.
  Future<Distributors> distributors() async {
    if (!available) return (installed: const <String>[], chosen: null);
    await start();
    try {
      return (
        installed: await _plugin.getDistributors(const []),
        chosen: await _plugin.getDistributor(),
      );
    } catch (e) {
      debugPrint('cannot list push distributors: $e');
      return (installed: const <String>[], chosen: null);
    }
  }

  /// Uses [distributor] from now on, and registers [origin] there.
  Future<void> choose(String distributor, Uri origin, String token) async {
    if (!available) return;
    await start();
    try {
      await _plugin.saveDistributor(distributor);
    } catch (e) {
      debugPrint('cannot save the push distributor: $e');
      return;
    }
    await follow(origin, token);
  }

  /// Every server this app knows.
  Future<List<Uri>> _servers() async {
    try {
      final raw = await _secrets.read(serversKey);
      if (raw == null) return const [];
      return [
        for (final entry in jsonDecode(raw) as List<dynamic>)
          SavedServer.fromJson(entry as Map<String, dynamic>).origin,
      ];
    } on FormatException {
      return const [];
    }
  }

  /// Hands a new endpoint to its server, and takes back the one before.
  Future<void> _newEndpoint(PushEndpoint endpoint, String instance) async {
    final origin = Uri.tryParse(instance);
    if (origin == null) return;
    final token = await _secrets.read(tokenKey(origin));
    final keys = endpoint.pubKeySet;
    try {
      if (token == null) {
        // Signed out since: nobody to push to.
        await _plugin.unregister(instance);
        return;
      }
      if (keys == null) {
        debugPrint('push endpoint without keys');
        return;
      }
      final api = Api(origin, token: token);
      final before = await _secrets.read(pushEndpointKey(origin));
      await api.subscribePush(
        pushSubscriptionJson(
          endpoint: endpoint.url,
          p256dh: keys.pubKey,
          auth: keys.auth,
        ),
      );
      await _secrets.write(pushEndpointKey(origin), endpoint.url);
      if (before != null && before != endpoint.url) {
        await api.unsubscribePush(before);
      }
    } catch (e) {
      debugPrint('cannot hand the push endpoint to the server: $e');
    }
  }

  /// The distributor let go of [instance]: its server stops pushing.
  Future<void> _unregistered(String instance) async {
    final origin = Uri.tryParse(instance);
    if (origin != null) await _unsubscribe(origin);
  }

  Future<void> _unsubscribe(Uri origin) async {
    final endpoint = await _secrets.read(pushEndpointKey(origin));
    if (endpoint == null) return;
    await _secrets.delete(pushEndpointKey(origin));
    final token = await _secrets.read(tokenKey(origin));
    if (token == null) return;
    try {
      await Api(origin, token: token).unsubscribePush(endpoint);
    } catch (e) {
      debugPrint('cannot take the push endpoint back: $e');
    }
  }

  Future<void> _message(PushMessage message, String instance) async {
    if (!message.decrypted) {
      debugPrint('a push that could not be decrypted');
      return;
    }
    final summon = SummonPush.parse(message.content);
    if (summon == null) return;
    final origin = Uri.tryParse(instance);
    // The open app in front shows its own, from the server's connection.
    if (!_background && origin == live && appInFront) return;
    var preferences = _preferences;
    var notifications = _notifications;
    if (preferences == null || notifications == null) {
      // Started by this push: no app around, a notification of our own.
      if (!_background) return;
      preferences = _preferences = Preferences(_secrets);
      notifications = _notifications = Notifications(
        preferences,
        background: true,
      );
    }
    // Read again each time: Settings may have changed it since.
    if (_background) await preferences.load();
    if (!preferences.notifySummons) return;
    await notifications.summoned(
      caller: summon.caller,
      channel: summon.channel,
      channelName: summon.channelName,
      server: origin,
    );
  }
}

/// The one for the whole app.
final unifiedPushes = UnifiedPushes();

/// Follows the signed-in account's server for summons while Wisetalk is
/// closed, for the life of the app. Costs a request per start and nothing
/// after: the distributor does the listening.
final unifiedPushProvider = Provider<void>((ref) {
  if (!unifiedPushes.available) return;
  final preferences = ref.read(preferencesProvider);
  unifiedPushes.attach(ref.read(notificationsProvider), preferences);
  String? followed;
  void changed(AsyncValue<Session?>? _, AsyncValue<Session?> next) {
    if (next.isLoading || !next.hasValue) return;
    final session = next.value;
    unifiedPushes.live = session?.server.origin;
    if (session == null || session.me.isGuest) return;
    // Once per session, not on every rebuild.
    if (followed == session.token) return;
    followed = session.token;
    unawaited(_followWhenWanted(preferences, session));
  }

  ref.listen(sessionProvider, changed, fireImmediately: true);
});

/// Follows [session]'s server unless summons are switched off here; asks
/// once the saved preferences are read, not the defaults before them.
Future<void> _followWhenWanted(Preferences preferences, Session session) async {
  await preferences.loaded;
  if (!preferences.notifySummons) return;
  await unifiedPushes.follow(session.server.origin, session.token);
}
