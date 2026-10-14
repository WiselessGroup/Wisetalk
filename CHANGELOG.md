# Changelog

The native app. Each release section becomes the notes of its release on
Forgejo.

## 0.1.0

The first Wisetalk app, for Linux and Android.

- Sign in to any Wisetalk server with your account or as a guest. The app
  remembers your servers, so switching between communities is one click.
- Voice, video and screen sharing, end-to-end encrypted, in the same calls
  as the browser.
- Channel chats with pictures, also end-to-end encrypted. Paste a picture
  with Ctrl+V.
- Summons and new messages show up as notifications while the app is in
  the background.
- On Android, calls keep going in the background with an ongoing
  notification, and you can share the entire screen or one app. Phones get
  a one-column layout: the channel list folds into a row during a call.
- On Linux the app updates itself: it downloads the new version in the
  background, then "Restart to Update" switches to it. On Android it tells
  you when a new version is out.

Known limits: on Wayland, screen sharing shows a whole screen without
sound, and asks which screen only once per launch. System notifications
don't show up on every desktop yet.
