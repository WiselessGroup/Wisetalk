# Releasing

The source of truth is `git.wiseless.net/Wisetalk/client`, which pushes to the
GitHub mirror, `WiselessGroup/Wisetalk`. `.github/workflows/build.yml` runs
there and only there: the server that hosts the source is too small to build
anything.

1. Add the version's section to `CHANGELOG.md`, which becomes the release's
   notes, and set `version` in `pubspec.yaml` (`0.7.0+7000`: the build number
   is major × 1000000 + minor × 1000 + patch).
2. Commit, tag `vX.Y.Z`, push both. A tag publishes to everyone once every
   check and package has come through. A version with a hyphen
   (`1.0.0-rc.1`) is a prerelease: installed apps and the Download button stay
   on the latest full release, so use one to try the pipeline out.

Before a release, `scripts/measure.sh [seconds] [pid]` prints the CPU, wakeups
and memory of a running release build. Take the window idle, minimized, in a
call and with video, and compare with the release before: the app is supposed
to cost nothing while nobody is talking.

## Secrets of the GitHub repository

| Name | What |
|---|---|
| `ANDROID_KEYSTORE` | The release keystore, base64 (`base64 -w0 release.jks`). Keep a copy somewhere safe: losing it means nobody can update the app without reinstalling |
| `ANDROID_KEYSTORE_PASSWORD` | Its password |
| `ANDROID_KEY_PASSWORD` | The key's password, only if it differs |
| `WISETALK_SENTRY_DSN` | Where crash reports go; without it the builds can't send any |

## Two updaters on Linux, and what keeps them working

Velopack updates the app on every desktop. On Linux, Gear Lever can update the
same AppImage, and it reads where from out of the image's `.upd_info` section.

It decides whether there is an update by comparing the SHA-1 of the local file
with the header of the release's `.zsync`, and a release holds the image twice:
the published file, and `lib/app/Wisetalk.AppImage` in the `.nupkg` that
Velopack installs. So both copies must carry the string and stay identical, or
the first update through Velopack loses Gear Lever's source and Gear Lever
offers an update forever.

`vpk` has no option for the string. `scripts/set-update-info.sh` writes it into
the runtime `vpk` builds images from, before packing, and
`scripts/build-linux.sh` refuses to go on if the copies differ or the string
is missing. The `.zsync` is made last, from the finished file. Moving to a new
`vpk` version keeps working as long as it ships that runtime with a
`.upd_info` section; the script stops with an error if it doesn't.

`.zsync` names follow the AppImage (`Wisetalk-X.Y.Z-x86_64.AppImage.zsync`):
Gear Lever finds the newest one by the mask in the update string and takes the
AppImage named the same without the suffix.
