//! Signing in from the app.

use flutter_rust_bridge::frb;
use wisetalk_core::crypto::Pkce;

/// A PKCE verifier and its challenge (RFC 7636, S256), see
/// `wisetalk_core::api::TokenRequest`.
pub struct PkcePair {
    pub verifier: String,
    pub challenge: String,
}

#[frb(sync)]
pub fn pkce() -> anyhow::Result<PkcePair> {
    let Pkce {
        verifier,
        challenge,
    } = Pkce::generate()?;
    Ok(PkcePair {
        verifier,
        challenge,
    })
}
