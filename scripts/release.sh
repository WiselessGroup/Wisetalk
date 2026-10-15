#!/bin/sh
# Builds a release on this machine and publishes it as the tag's release on
# Forgejo: the Linux AppImage with Velopack's update packages and feed (the
# release before supplies a delta), and the signed universal APK. Builds run
# in the image from ci/Dockerfile, Ubuntu 22.04, so the AppImage also runs
# on systems older than this one.
#
# Usage: scripts/release.sh vX.Y.Z, in a terminal: it asks for the
# keystore's password, which no file keeps (only a temporary one inside the
# build directory, deleted with it).
# Needs the tag checked out and pushed, a Forgejo token that can write
# releases in ~/.config/wisetalk/forgejo-token, and the release keystore at
# $WISETALK_KEYSTORE or at the path in ~/.config/wisetalk/keystore-path.
#
# Each step shows one line with a running clock and how long it took last
# time (scripts/lib/steps.sh); what it prints goes to dist/logs/.
set -eu
cd "$(dirname "$0")/.."

fail() { echo "release: $*" >&2; exit 1; }

tag=${1:-}
case $tag in v[0-9]*) ;; *) fail "usage: scripts/release.sh vX.Y.Z" ;; esac
version=${tag#v}
base=${version%%-*}
token_file=$HOME/.config/wisetalk/forgejo-token
# Where crash reports go (lib/data/crash_reports.dart); without it the
# builds can't send any.
sentry_dsn=$(cat "$HOME/.config/wisetalk/sentry-dsn" 2>/dev/null || true)
repo=https://git.wiseless.net/Wisetalk/client

[ "$(git rev-parse HEAD)" = "$(git rev-parse -q --verify "$tag^{commit}")" ] \
    || fail "check out $tag first"
git diff --quiet && git diff --cached --quiet || fail "commit or stash your changes first"
git ls-remote --exit-code --tags origin "$tag" >/dev/null || fail "push $tag first"
[ -s "$token_file" ] || fail "put a Forgejo token in $token_file"
# Never an APK signed with a throwaway key: phones would refuse its updates.
keystore=${WISETALK_KEYSTORE:-$(cat "$HOME/.config/wisetalk/keystore-path" 2>/dev/null || true)}
[ -f "$keystore" ] || fail "no keystore: set WISETALK_KEYSTORE or ~/.config/wisetalk/keystore-path"
[ -t 0 ] || fail "run this in a terminal: it asks for the keystore's password"
printf 'Password of %s: ' "$(basename "$keystore")" >&2
stty -echo
read -r store_pass
stty echo
printf '\nKey password (Enter if the same): ' >&2
stty -echo
read -r key_pass
stty echo
echo >&2

times=$HOME/.cache/wisetalk/release-times
steps=6

# --- The build ------------------------------------------------------------

image=wisetalk-client-build:$(sed -n 's/^ARG FLUTTER_VERSION=//p' ci/Dockerfile)
container=wisetalk-release-$$
work=$(mktemp -d)
cleanup() {
    stty echo 2>/dev/null || true
    # What the build wrote belongs to root; hand it back so it can be removed.
    docker exec "$container" chown -R "$(id -u):$(id -g)" /src >/dev/null 2>&1 || true
    docker rm -f "$container" >/dev/null 2>&1 || true
    rm -rf "$work"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

[ -n "$sentry_dsn" ] || echo "No ~/.config/wisetalk/sentry-dsn: this release can't send crash reports."
rm -rf dist
# shellcheck source=scripts/lib/steps.sh
. scripts/lib/steps.sh
total=$(estimate)
if [ "$total" -gt 0 ]; then
    echo "Wisetalk $version, about $(clock "$total") going by the last release"
else
    echo "Wisetalk $version"
fi

if docker image inspect "$image" >/dev/null 2>&1; then
    skip_step "Build image" ready
else
    step image "Build image (first time only)" docker build -t "$image" ci
fi

# The tag's files only, with the signing key beside them.
chmod 700 "$work"
git archive "$tag" | tar -x -C "$work"
cp "$keystore" "$work/android/release.jks"
(umask 077; printf '%s\n%s\n' "$store_pass" "${key_pass:-$store_pass}" > "$work/android/passwords")

# One container for every step, so caches and the build stay between them.
# The build's own directories outlive it too: .dart_tool holds the compiled
# Rust, so the next release rebuilds only what changed.
docker run -d --name "$container" \
    -v "$work:/src" -v "$PWD/dist:/out" -w /src \
    -v wisetalk-pub-cache:/opt/pub-cache \
    -v wisetalk-cargo-registry:/opt/cargo/registry \
    -v wisetalk-gradle:/root/.gradle \
    -v wisetalk-dart-tool:/src/.dart_tool \
    -v wisetalk-build:/src/build \
    -e VERSION="$version" -e BASE="$base" -e REPO="$repo" -e SENTRY_DSN="$sentry_dsn" \
    "$image" sleep infinity >/dev/null
inside() { docker exec "$container" sh -euc "$1"; }

step prepare "Signing key and packages" inside '
    # The signing key: its alias read from the keystore itself.
    cd android
    store_pass=$(sed -n 1p passwords)
    key_pass=$(sed -n 2p passwords)
    alias=$(keytool -list -keystore release.jks -storepass:file passwords 2>/dev/null \
        | sed -n "s/^\([^,]*\), .*PrivateKeyEntry.*/\1/p" | head -n 1)
    [ -n "$alias" ] || { echo "wrong password, or no key in the keystore" >&2; exit 1; }
    (umask 077; printf "storeFile=release.jks\nstorePassword=%s\nkeyAlias=%s\nkeyPassword=%s\n" \
        "$store_pass" "$alias" "$key_pass" > key.properties)
    rm passwords
    cd ..
    flutter pub get --enforce-lockfile
'

step linux "Building for Linux" inside '
    flutter build linux --release --build-name="$BASE" \
        --dart-define=WISETALK_SENTRY_DSN="$SENTRY_DSN"
'

step appimage "Packing the AppImage and updates" inside '
    # Our own AppDir, which vpk takes as it is and adds its updater to: its
    # desktop entry names the window the app opens and the wisetalk: links
    # it handles, so AppImage managers (Gear Lever) make one working entry.
    app=build/Wisetalk.AppDir
    rm -rf "$app"
    mkdir -p "$app/usr/bin" "$app/usr/share/metainfo" \
        "$app/usr/share/icons/hicolor/512x512/apps"
    cp -a build/linux/x64/release/bundle/. "$app/usr/bin/"
    cp packaging/linux/AppRun "$app/AppRun"
    sed "s/@VERSION@/$VERSION/" packaging/linux/net.wiseless.wisetalk.desktop \
        > "$app/net.wiseless.wisetalk.desktop"
    sed "s/@VERSION@/$VERSION/; s/@DATE@/$(date -u +%F)/" \
        packaging/linux/net.wiseless.wisetalk.metainfo.xml \
        > "$app/usr/share/metainfo/net.wiseless.wisetalk.metainfo.xml"
    for icon in net.wiseless.wisetalk.png .DirIcon \
        usr/share/icons/hicolor/512x512/apps/net.wiseless.wisetalk.png; do
        cp packaging/linux/wisetalk.png "$app/$icon"
    done

    # The release before, so updates from it are a small delta.
    vpk download gitea --repoUrl "$REPO" --channel linux -o /out \
        || echo "no release to make a delta from"
    vpk pack --packId Wisetalk --packVersion "$VERSION" --channel linux \
        --packDir "$app" --mainExe wisetalk --packTitle Wisetalk -o /out
    mv /out/Wisetalk.AppImage "/out/Wisetalk-$VERSION-x86_64.AppImage"
'

step android "Building for Android" inside '
    major=${BASE%%.*}; rest=${BASE#*.}; minor=${rest%%.*}; patch=${rest#*.}
    # One APK for every phone: arm64, arm and x86_64 in one file.
    flutter build apk --release --build-name="$BASE" \
        --build-number=$((major * 1000000 + minor * 1000 + patch)) \
        --dart-define=WISETALK_VERSION="$VERSION" \
        --dart-define=WISETALK_SENTRY_DSN="$SENTRY_DSN"
    cp build/app/outputs/flutter-apk/app-release.apk "/out/Wisetalk-$VERSION.apk"
'

inside "chown -R $(id -u):$(id -g) /out"
files="dist/Wisetalk-$version-x86_64.AppImage $(echo dist/Wisetalk-"$version"-linux-*.nupkg) dist/releases.linux.json dist/Wisetalk-$version.apk"
# shellcheck disable=SC2086 # the file list splits on spaces on purpose
step upload "Uploading to Forgejo" env TOKEN="$(cat "$token_file")" \
    scripts/release-upload.sh "$tag" $files

# shellcheck disable=SC2086
summary "$repo/releases/tag/$tag" $files
