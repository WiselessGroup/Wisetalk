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
# time; what it prints goes to dist/logs/ and only shows when it fails.
set -eu
cd "$(dirname "$0")/.."

fail() { echo "release: $*" >&2; exit 1; }

tag=${1:-}
case $tag in v[0-9]*) ;; *) fail "usage: scripts/release.sh vX.Y.Z" ;; esac
version=${tag#v}
base=${version%%-*}
token_file=$HOME/.config/wisetalk/forgejo-token
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

# --- How the steps look ---------------------------------------------------

times=$HOME/.cache/wisetalk/release-times
mkdir -p "$(dirname "$times")"
touch "$times"
steps=6
n=0
started=$(date +%s)
tty=false
[ -t 1 ] && tty=true

clock() { printf '%d:%02d' $(($1 / 60)) $(($1 % 60)); }
spinner() {
    case $(($1 % 10)) in
        0) printf '⠋' ;; 1) printf '⠙' ;; 2) printf '⠹' ;; 3) printf '⠸' ;; 4) printf '⠼' ;;
        5) printf '⠴' ;; 6) printf '⠦' ;; 7) printf '⠧' ;; 8) printf '⠇' ;; *) printf '⠏' ;;
    esac
}
last_time() { sed -n "s/^$1 //p" "$times" | tail -n 1; }

# step <name> <title> <command...>: runs the command with its output in
# dist/logs/<name>.log, a spinner and a clock meanwhile, and remembers how
# long it took for next time's estimate.
step() {
    name=$1 title=$2
    shift 2
    n=$((n + 1))
    log=dist/logs/$name.log
    was=$(last_time "$name")
    begin=$(date +%s)
    "$@" >"$log" 2>&1 &
    pid=$!
    i=0
    while kill -0 "$pid" 2>/dev/null; do
        if $tty; then
            took=$(($(date +%s) - begin))
            hint=
            [ -n "$was" ] && hint=" of ~$(clock "$was")"
            printf '\r\033[K%s [%d/%d] %s  %s%s' "$(spinner "$i")" "$n" "$steps" "$title" "$(clock "$took")" "$hint"
            i=$((i + 1))
        fi
        sleep 0.2
    done
    status=0
    wait "$pid" || status=$?
    took=$(($(date +%s) - begin))
    if [ "$status" -ne 0 ]; then
        $tty && printf '\r\033[K'
        printf '✗ [%d/%d] %s  failed after %s\n\n' "$n" "$steps" "$title" "$(clock "$took")"
        tail -n 30 "$log"
        printf '\nThe whole log: %s\n' "$log"
        exit 1
    fi
    { grep -v "^$name " "$times" || true; echo "$name $took"; } >"$times.new"
    mv "$times.new" "$times"
    $tty && printf '\r\033[K'
    printf '✓ [%d/%d] %s  %s\n' "$n" "$steps" "$title" "$(clock "$took")"
}

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

rm -rf dist
mkdir -p dist/logs
total=$(awk '{ sum += $2 } END { print sum + 0 }' "$times")
if [ "$total" -gt 0 ]; then
    echo "Wisetalk $version, about $(clock "$total") going by the last release"
else
    echo "Wisetalk $version"
fi

if docker image inspect "$image" >/dev/null 2>&1; then
    n=1
    printf '✓ [1/%d] Build image  ready\n' "$steps"
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
    -e VERSION="$version" -e BASE="$base" -e REPO="$repo" \
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

step linux "Building for Linux" inside 'flutter build linux --release --build-name="$BASE"'

step appimage "Packing the AppImage and updates" inside '
    # The release before, so updates from it are a small delta.
    vpk download gitea --repoUrl "$REPO" --channel linux -o /out \
        || echo "no release to make a delta from"
    vpk pack --packId Wisetalk --packVersion "$VERSION" --channel linux \
        --packDir build/linux/x64/release/bundle --mainExe wisetalk \
        --packTitle Wisetalk --icon packaging/linux/wisetalk.png \
        --categories "Network;InstantMessaging;AudioVideo" -o /out
    mv /out/Wisetalk.AppImage "/out/Wisetalk-$VERSION-x86_64.AppImage"
'

step android "Building for Android" inside '
    major=${BASE%%.*}; rest=${BASE#*.}; minor=${rest%%.*}; patch=${rest#*.}
    # One APK for every phone: arm64, arm and x86_64 in one file.
    flutter build apk --release --build-name="$BASE" \
        --build-number=$((major * 1000000 + minor * 1000 + patch)) \
        --dart-define=WISETALK_VERSION="$VERSION"
    cp build/app/outputs/flutter-apk/app-release.apk "/out/Wisetalk-$VERSION.apk"
'

inside "chown -R $(id -u):$(id -g) /out"
files="dist/Wisetalk-$version-x86_64.AppImage $(echo dist/Wisetalk-"$version"-linux-*.nupkg) dist/releases.linux.json dist/Wisetalk-$version.apk"
# shellcheck disable=SC2086 # the file list splits on spaces on purpose
step upload "Uploading to Forgejo" env TOKEN="$(cat "$token_file")" \
    scripts/release-upload.sh "$tag" $files

echo
echo "Released in $(clock $(($(date +%s) - started))):"
for file in $files; do
    printf '  %-44s %s\n' "$(basename "$file")" "$(du -h "$file" | cut -f1)"
done
echo "$repo/releases/tag/$tag"
