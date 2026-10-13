//! The symmetric key of a call. Hand `bytes` to LiveKit's key provider at key
//! index `epoch % 16`, with HKDF key derivation like the web client does
//! (`createKeyMaterialFromBuffer`), or browsers and apps can't hear each other.

use flutter_rust_bridge::frb;
use wisetalk_core::crypto::{self, KeyEnvelope, PublicKey};
use wisetalk_core::protocol::ChannelId;

use super::device::Device;

#[frb(opaque)]
pub struct CallKey(crypto::CallKey);

pub(crate) fn channel_id(text: &str) -> anyhow::Result<ChannelId> {
    Ok(ChannelId(text.parse()?))
}

impl CallKey {
    #[frb(sync)]
    pub fn generate() -> anyhow::Result<CallKey> {
        Ok(CallKey(crypto::CallKey::generate()?))
    }

    /// The replacement after someone left.
    #[frb(sync)]
    pub fn next(&self) -> anyhow::Result<CallKey> {
        Ok(CallKey(self.0.next()?))
    }

    #[frb(sync, getter)]
    pub fn epoch(&self) -> u32 {
        self.0.epoch()
    }

    #[frb(sync, getter)]
    pub fn bytes(&self) -> Vec<u8> {
        self.0.as_bytes().to_vec()
    }

    /// Seals this key for a device; returns the envelope as gateway JSON.
    #[frb(sync)]
    pub fn seal(
        &self,
        channel: String,
        sender: &Device,
        recipient_public_key: String,
    ) -> anyhow::Result<String> {
        let recipient = PublicKey::from_base64(&recipient_public_key)?;
        let envelope = KeyEnvelope::seal(&self.0, channel_id(&channel)?, &sender.0, &recipient)?;
        Ok(serde_json::to_string(&envelope)?)
    }

    /// Opens an envelope (gateway JSON) sealed by `sender_public_key`.
    #[frb(sync)]
    pub fn open(
        envelope: String,
        recipient: &Device,
        sender_public_key: String,
    ) -> anyhow::Result<CallKey> {
        let envelope: KeyEnvelope = serde_json::from_str(&envelope)?;
        let sender = PublicKey::from_base64(&sender_public_key)?;
        Ok(CallKey(envelope.open(&recipient.0, &sender)?))
    }
}
