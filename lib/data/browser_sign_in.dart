// Signing in with an account through the system browser, as RFC 8252 asks
// of apps: no web view that could read the password. For the moment of
// signing in the app listens on a loopback port; the server sends the
// browser back there with a one-time code, which the app trades for a
// session together with its PKCE verifier.

import 'dart:async';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../src/rust/api/auth.dart';
import 'api.dart';

/// How long to wait for the browser before giving up.
const _patience = Duration(minutes: 5);

/// A sign-in in progress; [cancel] stops waiting for the browser.
class BrowserSignIn {
  BrowserSignIn._(this._server);

  final HttpServer _server;
  final _done = Completer<SignedIn>();

  Future<SignedIn> get result => _done.future;

  void cancel() {
    if (!_done.isCompleted) _done.completeError(const SignInCancelled());
    unawaited(_server.close(force: true));
  }

  static Future<BrowserSignIn> start(Api api) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final flow = BrowserSignIn._(server);
    final pair = pkce();
    // Any unguessable string will do; the verifier generator makes one.
    final state = pkce().verifier;
    final redirect = Uri.parse('http://127.0.0.1:${server.port}/callback');

    server.listen((request) async {
      if (request.uri.path != '/callback' ||
          request.uri.queryParameters['state'] != state) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      final code = request.uri.queryParameters['code'];
      final error = request.uri.queryParameters['error'];
      await _answer(request.response, signedIn: code != null);
      unawaited(server.close());
      if (flow._done.isCompleted) return;
      if (code == null) {
        flow._done.completeError(ApiException(0, _reason(error)));
        return;
      }
      try {
        flow._done.complete(
          await api.exchange(
            code: code,
            verifier: pair.verifier,
            redirect: redirect,
          ),
        );
      } catch (e) {
        if (!flow._done.isCompleted) flow._done.completeError(e);
      }
    });

    Timer(_patience, () {
      if (!flow._done.isCompleted) {
        flow._done.completeError(
          const ApiException(0, 'Signing in took too long. Try again.'),
        );
        unawaited(server.close(force: true));
      }
    });

    final url = api.loginUrl(
      redirect: redirect,
      challenge: pair.challenge,
      state: state,
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      flow.cancel();
      throw const ApiException(0, "Can't open the browser to sign in.");
    }
    return flow;
  }
}

class SignInCancelled implements Exception {
  const SignInCancelled();
}

/// The same reasons the web client shows for `?login_error=`.
String _reason(String? error) => switch (error) {
  'refused' => 'Signing in was cancelled.',
  'banned' => 'This account is banned from the server.',
  'expired' => 'Signing in took too long. Try again.',
  'unavailable' => "This server can't sign in accounts right now.",
  _ => 'Signing in failed. Try again.',
};

/// What the browser tab shows once the app has its code.
Future<void> _answer(HttpResponse response, {required bool signedIn}) async {
  final message = signedIn
      ? "You're signed in. You can close this tab and go back to Wisetalk."
      : 'Signing in did not work. Go back to Wisetalk to try again.';
  response.headers.contentType = ContentType.html;
  response.write('''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width">
<title>Wisetalk</title>
<style>
  :root { color-scheme: light dark; }
  body { margin: 0; min-height: 100vh; display: grid; place-items: center;
         font: 17px -apple-system, system-ui, sans-serif; background: #1e1e2e; color: #cdd6f4; }
  @media (prefers-color-scheme: light) { body { background: #eff1f5; color: #4c4f69; } }
  p { max-width: 22rem; text-align: center; line-height: 1.45; padding: 1rem; }
</style></head>
<body><p>$message</p></body></html>''');
  await response.close();
}
