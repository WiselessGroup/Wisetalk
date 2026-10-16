#!/bin/sh
# What has to pass before a push: the Rust bridge, up-to-date bindings,
# formatting, the analyzer and the tests. Runs here; the server builds
# nothing of the client.
set -eu
cd "$(dirname "$0")/.."

(
    cd rust
    cargo fmt --check
    cargo clippy --all-targets --locked -- -D warnings
    cargo test --locked
    # flutter test loads the library from here.
    cargo build --release --locked
)
flutter pub get --enforce-lockfile
flutter_rust_bridge_codegen generate
git diff --exit-code -- lib/src/rust rust/src/frb_generated.rs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
