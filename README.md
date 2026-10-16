<p align="center">
  <img src="docs/owl.webp" width="640" alt="The Wisetalk owl in a headset and a gaming chair, playing at a desk with a mug and a bucket of snacks">
</p>

# Wisetalk app

Wisetalk is open-source voice and video chat for one community, made by the
Wiseless crew to replace TeamSpeak 6. One server is one community: no guilds,
no workspaces. Voice channels sit in spaces, every channel has a short-lived
chat, and people share cameras and screens. Everything goes through the
server's own media relay, never peer to peer, and calls and chats are
end-to-end encrypted.

This is the native app, one [Flutter](https://flutter.dev) codebase for
Linux, Windows, macOS and Android, with iOS later. It talks to any Wisetalk
[server](https://git.wiseless.net/Wisetalk/server), sits in the same calls
as the [web client](https://git.wiseless.net/Wisetalk/webclient), and gets
every bit of its crypto from [core](https://git.wiseless.net/Wisetalk/core)
through flutter_rust_bridge. Nothing in Dart encrypts anything.

The app is where audio and video get as good as the platform allows: stereo
microphones, a shared app's own sound, keyboard shortcuts, a tray later. It
has enough administration for everyday managing; whitelists, permissions per
role and channel icons stay in the web client, which gets every admin
feature first. This repository was called `mobile` until 2026-10-12.

Version 0.4.0. It has its own version line, separate from the server's, and
updates itself from the releases of this repository.

## What it does

- Signs in to any Wisetalk server through the system browser, or as a guest,
  and keeps several servers one click apart. `wisetalk://` links from a
  server's page add it or open it.
- Calls with camera and screen sharing, end-to-end encrypted. On Windows a
  shared window brings its app's sound along. On Linux and Windows a
  microphone goes out in stereo when voice processing is off.
- Channel chats with pictures, notifications for summons and messages (over
  D-Bus on Linux, with a foreground service keeping calls alive on Android).
- Away, connection bars with ping and loss, Ctrl+Shift+M and Ctrl+Shift+A
  (⌘ on a Mac) while the window is in front.
- Settings for devices, voice processing, sounds, summons and notifications.
  Phones get a one-column layout and full-screen sheets.
- Moderation and everyday admin: mutes, kicks, bans, owners, channel and
  space settings, creating and reordering.
- Opt-in crash reports that never carry messages, names, keys or servers.

The full list, release by release, is in [CHANGELOG.md](CHANGELOG.md); each
section there becomes the notes of its release.

## Layout

| Path | What |
|---|---|
| `lib/` | The Flutter app. `lib/theme.dart` holds the design tokens it shares with the web client: Catppuccin colors, Apple's Human Interface Guidelines for the rest |
| `lib/src/rust/` | Dart side of the bridge, generated. Don't edit it, run `flutter_rust_bridge_codegen generate` |
| `rust/` | `wisetalk_bridge`, the Rust side: device keys, call and chat encryption, proof of work, name checks, all from core |
| `hook/build.dart` | Native Assets build hook that compiles `rust/` with cargo during `flutter build` and bundles the library |
| `android/`, `linux/`, `macos/`, `windows/` | Platform runners |
| `scripts/` | Checks, measuring and the release scripts |
| `ci/Dockerfile` | The image Linux and Android releases are built in |

## Setting up a machine

- Flutter 3.47 (stable) from the official archive.
- `rustup`: flutter_rust_bridge's build hooks need it for the Android and
  Apple targets. `rust/rust-toolchain.toml` pins the version and targets.
- `cargo install flutter_rust_bridge_codegen --version 2.13.0 --locked`.
- Linux on Fedora: `clang cmake ninja-build pkgconf-pkg-config gtk3-devel
  libstdc++-devel mesa-libGLU libsecret-devel
  libayatana-appindicator-gtk3-devel pulseaudio-libs-devel`.
- macOS: Xcode. Windows: Visual Studio 2022 with "Desktop development with
  C++".
- Android: Android Studio, SDK API 36, NDK, cmdline-tools.

`flutter doctor -v` tells you what is still missing.

## Running and testing

```sh
flutter run -d linux                    # or macos, windows; build hooks compile the bridge too
flutter test                            # widget tests load rust/target/release
cd rust && cargo test                   # the bridge on its own
flutter_rust_bridge_codegen generate    # after changing rust/src/api
scripts/check.sh                        # everything that has to pass before a push
```

The bridge library is looked up in `rust/target/release` relative to the
working directory before the bundled copy. A stale build there wins over the
fresh one in the app; `cargo build --release` in `rust/` fixes that. On a Mac
the widget test that loads the bridge and the D-Bus notification tests fail,
so `flutter test` and `scripts/check.sh` are meant for Linux; the rest of
the tests pass anywhere.

Integration tests run against a local server (see the server's README), on
Linux one file at a time, because the desktop runner can't start the app
twice in one run:

```sh
flutter test integration_test/sign_in_test.dart -d linux
flutter test integration_test/voice_test.dart -d linux
flutter test integration_test/chat_test.dart -d linux
flutter test integration_test/shortcuts_test.dart -d linux
# An account's session (see the file) and a camera:
WISETALK_TEST_TOKEN=... flutter test integration_test/video_test.dart -d linux
# An owner's session. WISETALK_SHOTS=<folder> saves a picture of each step;
# sheets_test.dart runs at a phone's size (412 x 915) for the forms.
WISETALK_TEST_TOKEN=... flutter test integration_test/manage_test.dart -d linux
WISETALK_TEST_TOKEN=... WISETALK_SHOTS=/tmp/shots \
  flutter test integration_test/sheets_test.dart -d linux
```

## Releases

Releases are built on developers' machines; the server that hosts them is
too small to build anything. Before a release, `scripts/measure.sh [seconds]
[pid]` prints the CPU, wakeups and memory of a running release build. Take
the window idle, minimized, in a call and with video, and compare with the
release before: the app is supposed to cost nothing while nobody is talking.

`scripts/release.sh vX.Y.Z` builds a tagged release in a Docker image made
from `ci/Dockerfile` (Ubuntu 22.04, so the AppImage runs on older systems
than the one building it) and publishes it as a release of this repository:
`Wisetalk-X.Y.Z-x86_64.AppImage` with Velopack's update packages and feed,
and a universal `Wisetalk-X.Y.Z.apk`. The notes come from the tag's section
in `CHANGELOG.md`; a version with a hyphen (`1.0.0-beta.1`) is a prerelease.
Installed apps update from these releases, and Wisetalk servers offer the
latest one on their web client's download button.

The script needs a Forgejo token with "repository: Read and Write" in
`~/.config/wisetalk/forgejo-token`, and the Android release keystore at
`$WISETALK_KEYSTORE` or at the path in `~/.config/wisetalk/keystore-path`.
It asks for the keystore's password in the terminal and keeps it only in a
temporary file inside the build directory. Without the keystore it refuses
to build rather than sign with a throwaway key that phones would refuse to
update from later. Keep a copy of the keystore somewhere safe: losing it
means nobody can update the app without reinstalling.

### macOS and Windows

Flutter builds desktop apps only on their own system, so the Mac and Windows
files come from people with those machines, after `scripts/release.sh` has
made the release. Each script builds from the tag, checks its tools and says
how to get the missing ones, then adds its files to the same release
(uploading a file again replaces it).

| Where | Command | Makes | Needs |
|---|---|---|---|
| Mac with Apple silicon | `scripts/release-macos.sh vX.Y.Z` | `Wisetalk-X.Y.Z-arm64.dmg` | Xcode, Flutter, rustup, the .NET SDK with `vpk`, `jq`, the token in `~/.config/wisetalk/forgejo-token` |
| Windows, PowerShell | `.\scripts\release-windows.ps1 vX.Y.Z` | `Wisetalk-X.Y.Z-x64-Setup.exe` | Visual Studio 2022, Flutter, rustup, the .NET SDK with `vpk`, the token in `%APPDATA%\wisetalk\forgejo-token` or `$env:WISETALK_FORGEJO_TOKEN` |

Both come with Velopack's update package and feed. Neither is signed by a
paid certificate yet. The first time, macOS opens the app only from System
Settings › Privacy & Security › Open Anyway, and Windows SmartScreen asks
for "More info", then "Run anyway".

## License

[AGPL-3.0](LICENSE). If you run a modified version for others, you have to
offer them its source code.
