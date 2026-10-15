// Signing in to the current server, the same way as on its web page: with
// an account through the browser, or as a guest by name. The words come
// from the server's branding.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/address.dart';
import '../data/api.dart';
import '../data/browser_sign_in.dart';
import '../data/servers.dart';
import '../data/session.dart';
import '../l10n/app_localizations.dart';
import '../src/rust/api/text.dart';
import '../theme.dart';
import 'common.dart';

/// What the current server says about itself, asked when this screen opens.
final _infoProvider = FutureProvider.autoDispose<ServerInfo?>((ref) async {
  final server = (await ref.watch(serversProvider.future)).currentServer;
  return server == null ? null : Api(server.origin).server();
});

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _name = TextEditingController();
  BrowserSignIn? _browser;
  bool _guestBusy = false;
  String? _error;

  @override
  void dispose() {
    _browser?.cancel();
    _name.dispose();
    super.dispose();
  }

  SavedServer? get _server => ref.read(serversProvider).value?.currentServer;

  Future<void> _withAccount() async {
    final server = _server;
    if (server == null) return;
    setState(() => _error = null);
    try {
      final flow = await BrowserSignIn.start(Api(server.origin));
      setState(() => _browser = flow);
      final signedIn = await flow.result;
      await ref.read(sessionProvider.notifier).start(server, signedIn);
      if (mounted) context.go('/');
    } on SignInCancelled {
      // Changed their mind.
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _browser = null);
    }
  }

  Future<void> _asGuest() async {
    final server = _server;
    final name = normalizeDisplayName(raw: _name.text);
    if (server == null) return;
    if (name == null) {
      setState(() => _error = AppLocalizations.of(context).signInNameLength);
      return;
    }
    setState(() {
      _guestBusy = true;
      _error = null;
    });
    try {
      final api = Api(server.origin);
      // A little proof of work keeps bots from signing in thousands of guests.
      final challenge = await api.guestChallenge();
      final nonce = await solveChallenge(
        challenge: challenge.challenge,
        difficulty: challenge.difficulty,
      );
      final signedIn = await api.signInAsGuest(name, challenge, nonce);
      await ref.read(sessionProvider.notifier).start(server, signedIn);
      if (mounted) context.go('/');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _guestBusy = false);
    }
  }

  Future<void> _changeServer() async {
    _browser?.cancel();
    await ref.read(serversProvider.notifier).leave();
    if (mounted) context.go('/servers');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final server = ref.watch(serversProvider).value?.currentServer;
    final info = ref.watch(_infoProvider);
    final branding = info.value?.branding ?? const Branding();
    final texts = AppLocalizations.of(context);

    final back = TextButton.icon(
      onPressed: _changeServer,
      icon: const Icon(Icons.chevron_left),
      label: Text(
        server == null ? texts.signInServers : displayAddress(server.origin),
      ),
    );

    if (info.hasError) {
      return CenteredCard(
        leading: back,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Masthead(),
            const SizedBox(height: 20),
            ErrorBox(
              info.error is ApiException
                  ? (info.error! as ApiException).message
                  : texts.signInUnreachable,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(_infoProvider),
              child: Text(texts.tryAgain),
            ),
          ],
        ),
      );
    }

    final waiting = _browser != null;
    final accounts = info.value?.accounts ?? false;
    final guests = info.value?.guestsOpen ?? false;

    return CenteredCard(
      leading: back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Masthead(
            subtitle: info.isLoading ? ' ' : branding.taglineText(texts),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            ErrorBox(_error!),
            const SizedBox(height: 16),
          ],
          if (info.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            if (accounts) ...[
              FilledButton.icon(
                onPressed: waiting || _guestBusy ? null : _withAccount,
                icon: const Icon(Icons.login, size: 20),
                label: Text(
                  waiting ? texts.signInInBrowser : branding.signInText(texts),
                ),
              ),
              const SizedBox(height: 8),
              if (waiting)
                TextButton(
                  onPressed: () => _browser?.cancel(),
                  child: Text(texts.cancel),
                )
              else
                Text(
                  texts.signInAccountHelp,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: palette.muted),
                ),
            ],
            if (guests) ...[
              if (accounts) const _Or(),
              Text(
                texts.signInGuest,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.muted,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                enabled: !_guestBusy && !waiting,
                maxLength: 32,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _asGuest(),
                decoration: InputDecoration(
                  hintText: texts.signInGuestName,
                  counterText: '',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                texts.signInGuestHelp,
                style: TextStyle(fontSize: 13, color: palette.muted),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _guestBusy || waiting ? null : _asGuest,
                icon: const Icon(Icons.person_outline, size: 20),
                label: Text(
                  _guestBusy ? texts.signInJoining : texts.signInAsGuest,
                ),
              ),
            ] else if (!accounts)
              ErrorBox(texts.signInNobody)
            else
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  texts.signInGuestsClosed,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: palette.muted),
                ),
              ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: palette.tertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  [
                    texts.signInEncrypted,
                    ?branding.hostedByText(texts),
                  ].join(' '),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: palette.tertiary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Or extends StatelessWidget {
  const _Or();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: palette.separator)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              AppLocalizations.of(context).signInOr,
              style: TextStyle(color: palette.tertiary, fontSize: 13),
            ),
          ),
          Expanded(child: Divider(color: palette.separator)),
        ],
      ),
    );
  }
}
