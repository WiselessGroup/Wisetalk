#!/bin/sh
# Builds Wisetalk for Macs with Apple silicon and adds it to the tag's
# release on Forgejo, next to what scripts/release.sh sent: a disk image to
# install from, and Velopack's update package and feed (the release before
# supplies a delta).
#
# Usage, on a Mac with Apple silicon: scripts/release-macos.sh vX.Y.Z
# Needs the tag checked out and pushed, and a Forgejo token that can write
# releases in ~/.config/wisetalk/forgejo-token. The tools it needs, and how
# to get them, it says itself.
#
# The app is signed ad hoc, not by an Apple developer: the first time,
# people open it from System Settings › Privacy & Security › Open Anyway.
set -eu
cd "$(dirname "$0")/.."

fail() { echo "release: $*" >&2; exit 1; }

tag=${1:-}
case $tag in v[0-9]*) ;; *) fail "usage: scripts/release-macos.sh vX.Y.Z" ;; esac
version=${tag#v}
base=${version%%-*}
token_file=$HOME/.config/wisetalk/forgejo-token
# Where crash reports go (lib/data/crash_reports.dart); without it the
# build can't send any.
sentry_dsn=$(cat "$HOME/.config/wisetalk/sentry-dsn" 2>/dev/null || true)
repo=https://git.wiseless.net/Wisetalk/client
flutter_version=$(sed -n 's/^ARG FLUTTER_VERSION=//p' ci/Dockerfile)
vpk_version=$(sed -n 's/^ARG VPK_VERSION=//p' ci/Dockerfile)

# --- What it needs ---------------------------------------------------------

if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
    fail "run this on a Mac with Apple silicon"
fi
missing=
need() {
    command -v "$1" >/dev/null 2>&1 || missing="$missing
  $1: $2"
}
need xcodebuild "Xcode from the App Store, opened once to finish installing"
need flutter "Flutter $flutter_version, https://docs.flutter.dev/install/archive"
need rustup "https://rustup.rs"
need dotnet "brew install --cask dotnet-sdk"
need vpk "dotnet tool install -g vpk --version $vpk_version (then add ~/.dotnet/tools to PATH)"
need jq "brew install jq"
[ -z "$missing" ] || fail "missing tools:$missing"
xcodebuild -version >/dev/null 2>&1 || fail "Xcode isn't set up: sudo xcode-select -s /Applications/Xcode.app"
flutter --version 2>/dev/null | grep -q "Flutter $flutter_version " \
    || fail "Flutter $flutter_version needed (flutter --version says otherwise)"

# The tag's app, built by release scripts that may be newer than it.
git rev-parse -q --verify "$tag^{commit}" >/dev/null || fail "no tag $tag here: git fetch --tags"
git diff --quiet "$tag" HEAD -- . ':!scripts' || fail "check out $tag first (git checkout $tag)"
if ! git diff --quiet || ! git diff --cached --quiet; then
    fail "commit or stash your changes first"
fi
git ls-remote --exit-code --tags origin "$tag" >/dev/null || fail "push $tag first"
[ -s "$token_file" ] || fail "put a Forgejo token in $token_file"

# vpk is built for .NET 8; a newer runtime runs it too.
export DOTNET_ROLL_FORWARD=Major

# --- The build ------------------------------------------------------------

times=$HOME/.cache/wisetalk/release-times-macos
steps=4
[ -n "$sentry_dsn" ] || echo "No ~/.config/wisetalk/sentry-dsn: this release can't send crash reports."
rm -rf dist
# shellcheck source=scripts/lib/steps.sh
. scripts/lib/steps.sh
total=$(estimate)
if [ "$total" -gt 0 ]; then
    echo "Wisetalk $version for macOS, about $(clock "$total") going by the last release"
else
    echo "Wisetalk $version for macOS"
fi

app=build/macos/Build/Products/Release/Wisetalk.app
major=${base%%.*}
rest=${base#*.}
minor=${rest%%.*}
patch=${rest#*.}
build_number=$((major * 1000000 + minor * 1000 + patch))

step prepare "Packages" flutter pub get --enforce-lockfile

step build "Building for macOS" flutter build macos --release \
    --build-name="$base" --build-number="$build_number" \
    --dart-define=WISETALK_VERSION="$version" \
    --dart-define=WISETALK_SENTRY_DSN="$sentry_dsn"

pack() {
    # The release before, so updates from it are a small delta.
    vpk download gitea --repoUrl "$repo" --channel osx -o dist \
        || echo "no release to make a delta from"
    vpk pack --packId Wisetalk --packVersion "$version" --channel osx \
        --packDir "$app" --mainExe Wisetalk --packTitle Wisetalk --noInst -o dist

    # The disk image: the app as Velopack packed it, and a link to drop it
    # on. Apple silicon runs only signed code, so make sure it still is.
    stage=dist/dmg
    rm -rf "$stage"
    mkdir -p "$stage"
    # Velopack's portable bundle, whatever it names it.
    portable=$(ls dist/*Portable*.zip)
    ditto -x -k "$portable" "$stage"
    if ! codesign --verify --deep --strict "$stage/Wisetalk.app"; then
        codesign --force --deep --sign - "$stage/Wisetalk.app"
    fi
    ln -s /Applications "$stage/Applications"
    hdiutil create -volname Wisetalk -srcfolder "$stage" -ov -format UDZO \
        "dist/Wisetalk-$version-arm64.dmg"
    rm -rf "$stage"
}
step pack "Packing the disk image and updates" pack

files="dist/Wisetalk-$version-arm64.dmg $(echo dist/Wisetalk-"$version"-osx-*.nupkg) dist/releases.osx.json"
# shellcheck disable=SC2086 # the file list splits on spaces on purpose
step upload "Uploading to Forgejo" env TOKEN="$(cat "$token_file")" \
    scripts/release-upload.sh "$tag" $files

# shellcheck disable=SC2086
summary "$repo/releases/tag/$tag" $files
