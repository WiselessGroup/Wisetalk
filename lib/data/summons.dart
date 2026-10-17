// Summons as system notifications while nobody looks at Wisetalk: from
// the connection itself, not from the workspace, so they also come when
// Stay Connected started Wisetalk without a window (ADR-0035).

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connection.dart';
import 'gateway.dart';
import 'language.dart';
import 'notifications.dart';
import 'preferences.dart';

/// The channel's name in a `summoned` event: from the server, which names
/// it since 1.9, else from the channel list, else a placeholder.
String summonedChannelName(
  Map<String, dynamic> data,
  Gateway gateway,
  String placeholder,
) =>
    data['channel_name'] as String? ??
    gateway.channel(data['channel'] as String)?.channel.name ??
    placeholder;

final summonNotificationsProvider = Provider<void>((ref) {
  StreamSubscription<GatewayEvent>? events;
  ref.onDispose(() => events?.cancel());
  ref.listen(connectionProvider, (_, next) {
    if (next.isLoading) return;
    unawaited(events?.cancel());
    events = null;
    final connection = next.hasValue ? next.value : null;
    if (connection == null) return;
    final gateway = connection.gateway;
    events = gateway.events.listen((event) {
      if (event.type != 'summoned' || appInFront) return;
      final preferences = ref.read(preferencesProvider);
      if (!preferences.notifySummons) return;
      final data = event.data as Map<String, dynamic>;
      final texts = textsFor(preferences.language.value);
      unawaited(
        ref
            .read(notificationsProvider)
            .summoned(
              caller: data['from'] as String,
              channel: data['channel'] as String,
              channelName: summonedChannelName(
                data,
                gateway,
                texts.channelSomeChannel,
              ),
              server: gateway.session.server.origin,
            ),
      );
    });
  }, fireImmediately: true);
});
