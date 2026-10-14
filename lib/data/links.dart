// wisetalk: links from a server's web page: `wisetalk://add?server=<origin>`
// ("Add to Client") and `wisetalk://open?server=<origin>` ("Open in
// Client"). Both make that server the current one, adding it if new; when
// it can't be reached, the server list opens with its address filled in.

import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../src/rust/api/text.dart';
import 'address.dart';
import 'api.dart';
import '../router.dart';
import 'servers.dart';

/// An address a link brought that the server list should show, with why it
/// couldn't be used as is.
typedef PendingAddress = ({String address, String? error});

final pendingAddressProvider =
    NotifierProvider<PendingAddressNotifier, PendingAddress?>(
      PendingAddressNotifier.new,
    );

class PendingAddressNotifier extends Notifier<PendingAddress?> {
  @override
  PendingAddress? build() => null;

  void set(PendingAddress? value) => state = value;
}

/// Follows one link; what [linksProvider] does with each that comes in.
final openLinkProvider = Provider<Future<void> Function(Uri)>(
  (ref) =>
      (link) => _open(ref, link),
);

/// Listens for links for the life of the app.
final linksProvider = Provider<void>((ref) {
  final subscription = AppLinks().uriLinkStream.listen(
    (uri) => unawaited(ref.read(openLinkProvider)(uri)),
    onError: (Object e) => debugPrint('bad wisetalk: link: $e'),
  );
  ref.onDispose(subscription.cancel);
});

Future<void> _open(Ref ref, Uri link) async {
  if (link.scheme != 'wisetalk' || !{'add', 'open'}.contains(link.host)) {
    return;
  }
  final address = link.queryParameters['server'] ?? '';
  final origin = parseServerAddress(address);
  if (origin == null) return;
  final servers = ref.read(serversProvider.notifier);
  try {
    final info = await Api(origin).server();
    if (info.protocol != protocolVersion()) {
      throw const ApiException(
        0,
        "This server and this app don't speak the same version.",
      );
    }
    await servers.add(
      SavedServer(
        origin: origin,
        name: info.branding.community ?? displayAddress(origin),
      ),
    );
    // On to signing in there, or straight in with a session kept from before.
    ref.read(routerProvider).go('/');
  } on ApiException catch (e) {
    ref.read(pendingAddressProvider.notifier).set((
      address: displayAddress(origin),
      error: e.message,
    ));
    await servers.leave();
    ref.read(routerProvider).go('/servers');
  }
}
