# Wisetalk client

Native client of [Wisetalk](https://git.wiseless.net/Wisetalk), an open-source
voice and video chat for a single community. Built with
[Flutter](https://flutter.dev): one codebase for Linux, Windows, macOS, Android
and iOS. This repository was called `mobile` until 2026-10-12.

**Status:** early. On Linux the app signs in to any Wisetalk server (with
an account through the browser, or as a guest), lists its channels and
joins end-to-end encrypted calls with cameras and screen sharing. On
Wayland the system picks what to share, whole screens only, without
sound. Channel chats, end-to-end encrypted like calls, carry text and
pictures. Settings come next. The browser client
([webclient](https://git.wiseless.net/Wisetalk/webclient)) is the one in use.

## Layout

| Path | What |
|---|---|
| `lib/` | The Flutter app. `lib/theme.dart` is the design system shared with the web client: Catppuccin colors, Apple's Human Interface Guidelines for the rest. |
| `lib/src/rust/` | Dart side of the bridge, generated: don't edit, run `flutter_rust_bridge_codegen generate`. |
| `hook/build.dart` | Native Assets build hook: compiles `rust/` with cargo during `flutter build` and bundles the library. |
| `android/`, `linux/`, `macos/`, `windows/` | Platform runners. iOS comes later. |
| `rust/` | `wisetalk_bridge`: Dart bindings for wisetalk-core through [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge) 2.13. Device keys, call and chat encryption, guest proof of work, name checks. Envelopes and sealed messages cross the boundary as gateway JSON, as in the web client's WebAssembly build. |

## Plan

- Voice, video and screen sharing through
  [livekit_client](https://pub.dev/packages/livekit_client), end-to-end
  encrypted and interoperable with the web client. The call key goes to
  LiveKit with HKDF key derivation (the web client uses
  `createKeyMaterialFromBuffer`), and the key index is set explicitly after
  every rotation.
- All cryptography and protocol types come from wisetalk-core through the
  bridge; no cryptography is written in Dart.
- Sign-in through the system browser: the server runs the OpenID Connect flow
  and hands the app a one-time code that it exchanges for a session token.
- Beyond the web client: system audio during screen sharing, a tray app that
  stays connected, native notifications.

## Setting up a machine

- Flutter 3.47 (stable) from the official archive.
- `cargo install flutter_rust_bridge_codegen --version 2.13.0 --locked`.
- Linux builds on Fedora: `clang cmake ninja-build pkgconf-pkg-config
  gtk3-devel libstdc++-devel mesa-libGLU libsecret-devel
  libayatana-appindicator-gtk3-devel pulseaudio-libs-devel`.
- `rustup` (Fedora: `dnf install rustup`): flutter_rust_bridge's build hooks
  need it for the Android and Apple targets. `rust/rust-toolchain.toml` pins
  the version and targets.
- Android: Android Studio, SDK API 36, NDK, cmdline-tools. Check with
  `flutter doctor -v`.

Then:

```sh
flutter run -d linux        # build hooks compile the Rust bridge too
flutter test                # widget tests load rust/target/release
# Against a local server (server/README) on Linux, one file at a time:
# the desktop runner can't start the app twice in one run.
flutter test integration_test/sign_in_test.dart -d linux
flutter test integration_test/voice_test.dart -d linux
flutter test integration_test/chat_test.dart -d linux
# Needs an account's session (see the file) and a camera:
WISETALK_TEST_TOKEN=... flutter test integration_test/video_test.dart -d linux
cd rust && cargo test       # the bridge on its own
flutter_rust_bridge_codegen generate   # after changing rust/src/api
```

The bridge library is looked up in `rust/target/release` relative to the
working directory before the bundled copy. A stale build there wins over the
fresh one in the app; `cargo build --release` in `rust/` fixes that.

## Releases

Everything is built on a developer's machine; the server only hosts the
results. Before pushing, `scripts/check.sh` runs what has to pass (the
Rust bridge, bindings, formatting, analyzer, tests).

`scripts/release.sh vX.Y.Z` builds a tagged release and publishes it as a
release of this repository: `Wisetalk-X.Y.Z-x86_64.AppImage` with
Velopack's update packages and feed, and a universal `Wisetalk-X.Y.Z.apk`.
Installed apps update from these releases. The notes come from the tag's
section in `CHANGELOG.md`; a version with a hyphen (`1.0.0-beta.1`) is a
prerelease. Wisetalk servers offer the latest release on their web client's
Download button.

The builds run in a Docker image made from `ci/Dockerfile` (Ubuntu 22.04,
so the AppImage runs on older systems than the one building it), built
locally the first time. The script needs a Forgejo token that can write
releases in `~/.config/wisetalk/forgejo-token`, and the Android release key:
`android/key.properties` (`storeFile`, `storePassword`, `keyAlias`,
`keyPassword`) with the keystore it names beside it, both ignored by git.
Without them it refuses to build rather than sign with a throwaway key,
which phones would refuse to update later. Keep a copy of the keystore
somewhere safe: losing it means nobody can update the app without
reinstalling.

## License

[AGPL-3.0](LICENSE). If you run a modified version for others, you have to
offer them its source code.
