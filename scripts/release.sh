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
set -eu
cd "$(dirname "$0")/.."

fail() { echo "release: $*" >&2; exit 1; }

tag=${1:-}
case $tag in v[0-9]*) ;; *) fail "usage: scripts/release.sh vX.Y.Z" ;; esac
version=${tag#v}
token_file=$HOME/.config/wisetalk/forgejo-token

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

image=wisetalk-client-build:$(sed -n 's/^ARG FLUTTER_VERSION=//p' ci/Dockerfile)
docker image inspect "$image" >/dev/null 2>&1 || docker build -t "$image" ci

# The tag's files only, with the signing key beside them.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
chmod 700 "$work"
git archive "$tag" | tar -x -C "$work"
cp "$keystore" "$work/android/release.jks"
(umask 077; printf '%s\n%s\n' "$store_pass" "${key_pass:-$store_pass}" > "$work/android/passwords")
rm -rf dist
mkdir -p dist

docker run --rm \
    -v "$work:/src" -v "$PWD/dist:/out" -w /src \
    -v wisetalk-pub-cache:/opt/pub-cache \
    -v wisetalk-cargo-registry:/opt/cargo/registry \
    -v wisetalk-gradle:/root/.gradle \
    -e VERSION="$version" -e REPO=https://git.wiseless.net/Wisetalk/client \
    -e HOST_USER="$(id -u):$(id -g)" \
    "$image" sh -euc '
        base=${VERSION%%-*}
        # The signing key: its alias read from the keystore itself.
        cd android
        store_pass=$(sed -n 1p passwords)
        key_pass=$(sed -n 2p passwords)
        alias=$(keytool -list -keystore release.jks -storepass:file passwords 2>/dev/null \
            | sed -n "s/^\([^,]*\), .*PrivateKeyEntry.*/\1/p" | head -n 1)
        [ -n "$alias" ] || { echo "release: wrong password, or no key in the keystore" >&2; exit 1; }
        (umask 077; printf "storeFile=release.jks\nstorePassword=%s\nkeyAlias=%s\nkeyPassword=%s\n" \
            "$store_pass" "$alias" "$key_pass" > key.properties)
        cd ..
        flutter pub get --enforce-lockfile

        flutter build linux --release --build-name="$base"
        # The release before, so updates from it are a small delta.
        vpk download gitea --repoUrl "$REPO" --channel linux -o /out \
            || echo "no release to make a delta from"
        vpk pack --packId Wisetalk --packVersion "$VERSION" --channel linux \
            --packDir build/linux/x64/release/bundle --mainExe wisetalk \
            --packTitle Wisetalk --icon packaging/linux/wisetalk.png \
            --categories "Network;InstantMessaging;AudioVideo" -o /out
        mv /out/Wisetalk.AppImage "/out/Wisetalk-$VERSION-x86_64.AppImage"

        major=${base%%.*}; rest=${base#*.}; minor=${rest%%.*}; patch=${rest#*.}
        # One APK for every phone: arm64, arm and x86_64 in one file.
        flutter build apk --release --build-name="$base" \
            --build-number=$((major * 1000000 + minor * 1000 + patch)) \
            --dart-define=WISETALK_VERSION="$VERSION"
        cp build/app/outputs/flutter-apk/app-release.apk "/out/Wisetalk-$VERSION.apk"
        chown -R "$HOST_USER" /out
    '

TOKEN=$(cat "$token_file") scripts/release-upload.sh "$tag" \
    "dist/Wisetalk-$version-x86_64.AppImage" dist/Wisetalk-"$version"-linux-*.nupkg \
    dist/releases.linux.json "dist/Wisetalk-$version.apk"
