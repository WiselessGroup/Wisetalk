# Build image for the client's CI: Flutter, Rust for the bridge, the Linux
# desktop toolchain and the Android SDK. Published as
# git.wiseless.net/wisetalk/flutter-ci:<flutter version> by ci-image.yml.
#
# Ubuntu 22.04 on purpose: an AppImage runs on systems with the same or a
# newer glibc than the one it was built with (2.35 here).
FROM docker.io/library/ubuntu:22.04

ARG FLUTTER_VERSION=3.47.7
ARG RUST_VERSION=1.98.1
ARG CMDLINE_TOOLS=16111833
ARG ANDROID_PLATFORM=36
ARG ANDROID_BUILD_TOOLS=36.0.0
ARG ANDROID_NDK=28.2.13676358
ARG APPIMAGETOOL=1.9.1
ARG APPIMAGETOOL_SHA256=ed4ce84f0d9caff66f50bcca6ff6f35aae54ce8135408b3fa33abfc3cb384eb0

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    ANDROID_HOME=/opt/android \
    FLUTTER_ROOT=/opt/flutter \
    RUSTUP_HOME=/opt/rustup \
    CARGO_HOME=/opt/cargo \
    PUB_CACHE=/opt/pub-cache
ENV PATH=/opt/flutter/bin:/opt/cargo/bin:/opt/android/cmdline-tools/latest/bin:/opt/android/platform-tools:$PATH

RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends \
      ca-certificates curl git unzip xz-utils zip file jq \
      clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev \
      libsecret-1-dev libayatana-appindicator3-dev libpulse-dev \
      openjdk-21-jdk-headless \
 && rm -rf /var/lib/apt/lists/*

# Rust for the bridge, with all of rust/rust-toolchain.toml's targets, or
# rustup fetches the missing ones on every run.
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain "$RUST_VERSION" \
 && rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android \
      aarch64-unknown-linux-gnu aarch64-apple-darwin x86_64-apple-darwin aarch64-apple-ios \
      aarch64-apple-ios-sim x86_64-pc-windows-msvc \
 && rustup component add rustfmt clippy

# Android SDK. Running this image accepts the Android SDK license.
RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
 && curl -sSfo /tmp/tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS}_latest.zip" \
 && unzip -q /tmp/tools.zip -d "$ANDROID_HOME/cmdline-tools" \
 && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
 && rm /tmp/tools.zip \
 && yes | sdkmanager --licenses >/dev/null \
 && sdkmanager --install "platform-tools" "platforms;android-${ANDROID_PLATFORM}" \
      "build-tools;${ANDROID_BUILD_TOOLS}" "ndk;${ANDROID_NDK}" >/dev/null

# Flutter at a fixed version, with what Linux and Android builds need.
RUN git clone -q --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_ROOT" \
 && git config --global --add safe.directory "$FLUTTER_ROOT" \
 && flutter config --no-analytics --no-cli-animations >/dev/null \
 && flutter precache --linux --android >/dev/null \
 && flutter --version

RUN cargo install flutter_rust_bridge_codegen --version 2.13.0 --locked \
 && rm -rf "$CARGO_HOME/registry"

RUN curl -sSfLo /usr/local/bin/appimagetool \
      "https://github.com/AppImage/appimagetool/releases/download/${APPIMAGETOOL}/appimagetool-x86_64.AppImage" \
 && echo "${APPIMAGETOOL_SHA256}  /usr/local/bin/appimagetool" | sha256sum -c - \
 && chmod +x /usr/local/bin/appimagetool
