# Changelog

The native app. Each release section becomes the notes of its release on
Forgejo.

## 0.3.0

The app catches up with the web client.

- Settings, behind the gear: your picture, which microphone, camera and
  speakers to use, voice processing, join and leave sounds, whether others
  may summon you, and which notifications this device shows.
- An owl hoots when someone comes into or leaves your call.
- Right-click a person, a channel or a space (or long-press on a phone):
  how loud someone is for you, Mute for Me, invite links, chat, and for
  moderators and admins muting, kicking, bans, owners, channel and space
  settings.
- Summon friends and copy invite links from the call's title row.
- Admins create channels and spaces with the + button, and reorder them by
  dragging the handle or with Move Up and Move Down.
- Spaces fold, and channels inside a space sit a step in.
- Check for Updates in the ⋯ menu.

Whitelists, permissions per role and channel icons are still set in the
web client.

## 0.2.0

Wisetalk for Windows and for Macs with Apple silicon.

- Windows gets an installer that keeps the app up to date, like the Linux
  one. Links from a server's web page (Add to Client, Open in Client) open
  the app, and a second start brings the open window forward.
- macOS gets a disk image: drag Wisetalk to Applications. It asks for the
  microphone and camera when a call needs them.
- New owl icons on Windows and macOS.

Known limits: neither is signed by a paid certificate yet. The first time,
Windows SmartScreen asks for "More info", then "Run anyway", and macOS
opens the app only from System Settings › Privacy & Security › Open
Anyway.

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
