# Wisetalk native client

Native client of [Wisetalk](https://git.wiseless.net/Wisetalk), an open-source
voice and video chat for a single community. Built with
[Flutter](https://flutter.dev): one codebase for Linux, Windows, macOS, Android
and iOS.

**Status:** not started. The browser client
([webclient](https://git.wiseless.net/Wisetalk/webclient)) comes first; this one
follows once the MVP has been tried out.

## Plan

- Voice, video and screen sharing through the
  [LiveKit Flutter SDK](https://github.com/livekit/client-sdk-flutter).
- Protocol types and end-to-end encryption from
  [wisetalk-core](https://git.wiseless.net/Wisetalk/core), bound to Dart with
  [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge), so
  native and browser clients share one implementation.
- Same feature set as the web client, plus what browsers can't do well:
  system audio capture during screen sharing and native notifications.

## License

[AGPL-3.0](LICENSE). If you run a modified version for others, you have to
offer them its source code.
