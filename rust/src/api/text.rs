//! Helpers that keep clients and server in agreement on small things.

use base64::Engine as _;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use flutter_rust_bridge::frb;
use wisetalk_core::{api, crypto::PublicKey, pow, protocol};

/// Gateway protocol version this build speaks, sent in `hello`.
#[frb(sync)]
pub fn protocol_version() -> u16 {
    protocol::PROTOCOL_VERSION
}

#[frb(sync)]
pub fn normalize_display_name(raw: String) -> Option<String> {
    api::normalize_display_name(&raw)
}

#[frb(sync)]
pub fn normalize_channel_name(raw: String) -> Option<String> {
    api::normalize_channel_name(&raw)
}

/// Trims a chat message and checks it; `None` if it can't be sent.
#[frb(sync)]
pub fn normalize_chat_body(raw: String) -> Option<String> {
    api::normalize_chat_body(&raw)
}

/// Fingerprint of a base64 device key, as shown next to a participant.
#[frb(sync)]
pub fn fingerprint(public_key: String) -> anyhow::Result<String> {
    Ok(PublicKey::from_base64(&public_key)?
        .fingerprint()
        .to_string())
}

/// Solves a guest sign-in challenge (base64url). Runs on a worker thread;
/// a fraction of a second at the server's default difficulty.
pub fn solve_challenge(challenge: String, difficulty: u32) -> anyhow::Result<u32> {
    let bytes = URL_SAFE_NO_PAD.decode(challenge)?;
    pow::solve(&bytes, difficulty).ok_or_else(|| anyhow::anyhow!("no solution"))
}
