#!/usr/bin/env bash
# Builds, in dist/: Wisetalk-<version>-arm64.dmg, and Velopack's update package
# and feed. The release before supplies a delta.
#
#   scripts/build-macos.sh <version>
#
# Runs on a Mac with Apple silicon. Needs Xcode, Flutter, rustup and vpk.
# The app is signed ad hoc, not by an Apple developer: the first time, people
# open it from System Settings › Privacy & Security › Open Anyway.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$1
base=${version%%-*}
IFS=. read -r major minor patch <<< "$base"
repo=https://github.com/WiselessGroup/Wisetalk
app=build/macos/Build/Products/Release/Wisetalk.app

rm -rf dist
mkdir -p dist
flutter pub get --enforce-lockfile
flutter build macos --release --build-name="$base" \
  --build-number=$((major * 1000000 + minor * 1000 + patch)) \
  --dart-define=WISETALK_VERSION="$version" \
  --dart-define=WISETALK_SENTRY_DSN="${WISETALK_SENTRY_DSN:-}"

vpk download github --repoUrl "$repo" --channel osx -o dist ${GH_TOKEN:+--token "$GH_TOKEN"} \
  || echo "no release to make a delta from"
vpk pack --packId Wisetalk --packVersion "$version" --channel osx \
  --packDir "$app" --mainExe Wisetalk --packTitle Wisetalk --noInst -o dist

# The disk image: the app as Velopack packed it, and a link to drop it on.
# Apple silicon runs only signed code, so make sure it still is.
stage=dist/dmg
mkdir -p "$stage"
# Velopack's portable bundle, whatever it names it.
ditto -x -k dist/*Portable*.zip "$stage"
if ! codesign --verify --deep --strict "$stage/Wisetalk.app"; then
  codesign --force --deep --sign - "$stage/Wisetalk.app"
fi
ln -s /Applications "$stage/Applications"
hdiutil create -volname Wisetalk -srcfolder "$stage" -ov -format UDZO \
  "dist/Wisetalk-$version-arm64.dmg"
rm -rf "$stage"
