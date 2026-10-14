#!/bin/sh
# Attaches files to the Forgejo release of a tag, creating the release
# first if there is none yet. Notes come from the tag's section in
# CHANGELOG.md; versions with a hyphen (1.0.0-beta.1) are prereleases.
# Usage: TOKEN=... scripts/release-upload.sh vX.Y.Z <file>...
set -eu

api=https://git.wiseless.net/api/v1/repos/Wisetalk/client
tag=$1
shift
version=${tag#v}

# Fails on an HTTP error, saying what Forgejo answered ("token does not
# have at least one of required scope(s)", say).
call() {
    curl -sS --fail-with-body -H "Authorization: token $TOKEN" "$@" || {
        status=$?
        echo >&2
        return $status
    }
}

release_id() {
    call "$api/releases/tags/$tag" 2>/dev/null | jq -r .id
}

id=$(release_id || true)
if [ -z "$id" ] || [ "$id" = null ]; then
    notes=$(awk -v v="$version" '
        $0 ~ "^## " v "( |$)" { on = 1; next }
        on && /^## / { exit }
        on { print }' CHANGELOG.md 2>/dev/null || true)
    case $version in *-*) pre=true ;; *) pre=false ;; esac
    body=$(jq -n --arg tag "$tag" --arg name "Wisetalk $version" --arg notes "$notes" \
        --argjson pre "$pre" '{tag_name: $tag, name: $name, body: $notes, prerelease: $pre}')
    answer=$(call -H "Content-Type: application/json" -d "$body" "$api/releases") || {
        echo "cannot create the release: $answer" >&2
        exit 1
    }
    id=$(echo "$answer" | jq -r .id)
fi

for file in "$@"; do
    name=$(basename "$file")
    answer=$(call -F "attachment=@$file" "$api/releases/$id/assets?name=$name") || {
        echo "cannot attach $name: $answer" >&2
        exit 1
    }
    echo "attached $name to $tag"
done
