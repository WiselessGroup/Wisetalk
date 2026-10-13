//! The key of one channel chat and the messages sealed with it. Messages and
//! envelopes cross the boundary as gateway JSON.

use flutter_rust_bridge::frb;
use wisetalk_core::crypto::{self, ChatKeyEnvelope, PublicKey, SealedText};
use wisetalk_core::protocol::{AccountId, ChatImage, ImageId};

use super::call::channel_id;
use super::device::Device;

#[frb(opaque)]
pub struct ChatKey(crypto::ChatKey);

/// An encrypted chat picture: `image` (gateway JSON) goes into the message,
/// `ciphertext` is uploaded.
pub struct SealedImage {
    pub image: String,
    pub ciphertext: Vec<u8>,
}

fn author_id(author: Option<String>) -> anyhow::Result<Option<AccountId>> {
    Ok(author.map(|a| a.parse().map(AccountId)).transpose()?)
}

impl ChatKey {
    #[frb(sync)]
    pub fn generate() -> anyhow::Result<ChatKey> {
        Ok(ChatKey(crypto::ChatKey::generate()?))
    }

    #[frb(sync, getter)]
    pub fn id(&self) -> String {
        self.0.id().to_string()
    }

    /// Encrypts a message by `author` (account id; `None` for guests).
    #[frb(sync)]
    pub fn encrypt(
        &self,
        channel: String,
        author: Option<String>,
        text: String,
    ) -> anyhow::Result<String> {
        let sealed = self
            .0
            .encrypt(channel_id(&channel)?, author_id(author)?, &text)?;
        Ok(serde_json::to_string(&sealed)?)
    }

    /// Decrypts sealed text (gateway JSON). Fails on the wrong key, channel or author.
    #[frb(sync)]
    pub fn decrypt(
        &self,
        channel: String,
        author: Option<String>,
        sealed: String,
    ) -> anyhow::Result<String> {
        let sealed: SealedText = serde_json::from_str(&sealed)?;
        Ok(self
            .0
            .decrypt(channel_id(&channel)?, author_id(author)?, &sealed)?)
    }

    /// Encrypts a picture by `author` with id `image` (a fresh UUID). Returns
    /// the message's `image` as gateway JSON and the ciphertext to upload.
    #[frb(sync)]
    #[allow(clippy::too_many_arguments)]
    pub fn seal_image(
        &self,
        channel: String,
        author: Option<String>,
        image: String,
        kind: String,
        width: u32,
        height: u32,
        bytes: Vec<u8>,
    ) -> anyhow::Result<SealedImage> {
        let (image, ciphertext) = self.0.seal_image(
            channel_id(&channel)?,
            author_id(author)?,
            ImageId(image.parse()?),
            &kind,
            width,
            height,
            &bytes,
        )?;
        Ok(SealedImage {
            image: serde_json::to_string(&image)?,
            ciphertext,
        })
    }

    /// Decrypts a downloaded picture; `image` is the message's `image` as JSON.
    /// Fails if the server changed anything about it.
    pub fn open_image(
        &self,
        channel: String,
        author: Option<String>,
        image: String,
        ciphertext: Vec<u8>,
    ) -> anyhow::Result<Vec<u8>> {
        let image: ChatImage = serde_json::from_str(&image)?;
        Ok(self.0.open_image(
            channel_id(&channel)?,
            author_id(author)?,
            &image,
            &ciphertext,
        )?)
    }

    #[frb(sync)]
    pub fn seal(
        &self,
        channel: String,
        sender: &Device,
        recipient_public_key: String,
    ) -> anyhow::Result<String> {
        let recipient = PublicKey::from_base64(&recipient_public_key)?;
        let envelope =
            ChatKeyEnvelope::seal(&self.0, channel_id(&channel)?, &sender.0, &recipient)?;
        Ok(serde_json::to_string(&envelope)?)
    }

    #[frb(sync)]
    pub fn open(
        envelope: String,
        recipient: &Device,
        sender_public_key: String,
    ) -> anyhow::Result<ChatKey> {
        let envelope: ChatKeyEnvelope = serde_json::from_str(&envelope)?;
        let sender = PublicKey::from_base64(&sender_public_key)?;
        Ok(ChatKey(envelope.open(&recipient.0, &sender)?))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::call::CallKey;

    const CHANNEL: &str = "0199f000-0000-7000-8000-000000000001";
    const AUTHOR: &str = "0199f000-0000-7000-8000-0000000000aa";

    #[test]
    fn chat_round_trip_through_json() {
        let (alice, bob) = (Device::generate().unwrap(), Device::generate().unwrap());
        let key = ChatKey::generate().unwrap();
        let envelope = key.seal(CHANNEL.into(), &alice, bob.public_key()).unwrap();
        let opened = ChatKey::open(envelope, &bob, alice.public_key()).unwrap();
        assert_eq!(opened.id(), key.id());

        let sealed = key
            .encrypt(CHANNEL.into(), Some(AUTHOR.into()), "gg wp".into())
            .unwrap();
        assert_eq!(
            opened
                .decrypt(CHANNEL.into(), Some(AUTHOR.into()), sealed.clone())
                .unwrap(),
            "gg wp"
        );
        assert!(opened.decrypt(CHANNEL.into(), None, sealed).is_err());
    }

    #[test]
    fn chat_picture_round_trip() {
        let key = ChatKey::generate().unwrap();
        let image = "0199f000-0000-7000-8000-0000000000bb";
        let sealed = key
            .seal_image(
                CHANNEL.into(),
                Some(AUTHOR.into()),
                image.into(),
                "image/webp".into(),
                640,
                480,
                b"pixels".to_vec(),
            )
            .unwrap();
        let opened = key
            .open_image(
                CHANNEL.into(),
                Some(AUTHOR.into()),
                sealed.image.clone(),
                sealed.ciphertext.clone(),
            )
            .unwrap();
        assert_eq!(opened, b"pixels");
        assert!(
            key.open_image(CHANNEL.into(), None, sealed.image, sealed.ciphertext)
                .is_err()
        );
    }

    #[test]
    fn call_key_round_trip_and_device_restore() {
        let (alice, bob) = (Device::generate().unwrap(), Device::generate().unwrap());
        let restored = Device::from_secret(bob.secret_bytes()).unwrap();
        assert_eq!(restored.public_key(), bob.public_key());

        let key = CallKey::generate().unwrap().next().unwrap();
        let envelope = key.seal(CHANNEL.into(), &alice, bob.public_key()).unwrap();
        let opened = CallKey::open(envelope, &restored, alice.public_key()).unwrap();
        assert_eq!((opened.epoch(), opened.bytes()), (1, key.bytes()));
    }
}
