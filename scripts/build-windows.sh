#!/usr/bin/env bash
# Builds, in dist/: Wisetalk-<version>-x64-Setup.exe, and Velopack's update
# package and feed. The release before supplies a delta.
#
#   scripts/build-windows.sh <version>
#
# Runs in Git Bash on Windows. Needs Visual Studio with "Desktop development
# with C++", Flutter, rustup and vpk. The installer isn't signed: Windows
# SmartScreen warns about it the first time ("More info", then "Run anyway").
set -euo pipefail
cd "$(dirname "$0")/.."

version=$1
base=${version%%-*}
IFS=. read -r major minor patch <<< "$base"
repo=https://github.com/WiselessGroup/Wisetalk

rm -rf dist
mkdir -p dist
flutter pub get --enforce-lockfile
flutter build windows --release --build-name="$base" \
  --build-number=$((major * 1000000 + minor * 1000 + patch)) \
  --dart-define=WISETALK_VERSION="$version" \
  --dart-define=WISETALK_SENTRY_DSN="${WISETALK_SENTRY_DSN:-}"

vpk download github --repoUrl "$repo" --channel win -o dist ${GH_TOKEN:+--token "$GH_TOKEN"} \
  || echo "no release to make a delta from"
vpk pack --packId Wisetalk --packVersion "$version" --channel win \
  --packDir build/windows/x64/runner/Release --mainExe wisetalk.exe --packTitle Wisetalk \
  --icon windows/runner/resources/app_icon.ico -o dist

# Velopack's installer, whatever it names it, under a name with the version.
mv dist/*Setup*.exe "dist/Wisetalk-$version-x64-Setup.exe"
