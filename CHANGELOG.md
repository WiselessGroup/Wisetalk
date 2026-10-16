# Changelog

The native app. Each release section becomes the notes of its release on
Forgejo.

## Unreleased

- Wisetalk speaks eight languages: English, Russian, Traditional Chinese,
  Japanese, Brazilian Portuguese, German, French and Spanish. It follows
  the system, and Settings › Language picks another one, which then
  stays and switches the app at once. Notifications, the call
  notification on Android and the page after signing in in the browser
  speak it too.
- What the server says when something doesn't work, and why you left a
  channel, show in your language too (with a server from 1.8).
- Linux: when an AppImage manager such as Gear Lever made Wisetalk's menu
  entry before the app updated itself, Wisetalk now mends that entry
  instead of adding a hidden one of its own. GNOME can pin the window to
  the dock again, and wisetalk: links open through the same entry.
- When someone in your call steps away, a sleepy owl hoots twice, low and
  slow; when they come back, one short bright hoot. Only the others hear
  it, and Join and Leave Sounds turns it off with the rest.
- Linux, Windows and macOS: the owl and the shortcut ticks play on the
  output picked in Settings, with the voices, not on the system's default
  one.
- Android: summons reach your phone even when Wisetalk is closed, without
  Google. Install the ntfy app and set your community's ntfy server as its
  default; Settings › While Wisetalk Is Closed shows whether it works.

## 0.4.0

- Away, next to the microphone in a call: one press turns your microphone
  and everyone's sound off, and the owl stays quiet. Press it again to hear
  everyone, with the microphone back as it was. On servers from 1.7.0
  others see a crossed-out headset next to your name.
- Keyboard shortcuts while Wisetalk's window is in front: Ctrl+Shift+M
  turns the microphone on and off, Ctrl+Shift+A steps away (⌘ on a Mac).
  Change them in Settings › Shortcuts; a short tick says what happened.
- Signal bars next to "End-to-end encrypted" show how good your connection
  is; point at them or tap them for ping, loss, jitter and what your
  microphone sends. Settings › Show Ping and Loss keeps the numbers there.
  Someone else's bars show next to their name when their connection is
  poor or lost.
- On a phone, Settings, channel and space settings, creating, Summon and
  adding a server open full screen, with Cancel and Save at the top, and
  ask before throwing changes away. Sharing a screen rises from the bottom.
- Stereo channels: with voice processing off, Linux and Windows send your
  microphone in stereo, and everyone's stereo now plays as stereo.
- Windows: a shared window brings its app's sound along, a shared screen
  everything you hear except the call. Share Sound turns it off.
- Linux: notifications show whenever Wisetalk is in the background or
  minimized, and clicking one brings its window forward.

## 0.3.2

- Linux: installed with Gear Lever or AppImageLauncher, Wisetalk shows up
  as one app with one icon, running or not, and the manager's entry opens
  links from a server's page. After updating, use Gear Lever's Reload
  Metadata once.

## 0.3.1

- Crash reports, off until you turn them on in Settings › Privacy. They
  say what broke and where in the code, never your messages, names, keys
  or servers.
- Linux: installed with Gear Lever or AppImageLauncher, Wisetalk no longer
  adds a second icon to the app menu; links from a server's page still
  open it.

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
