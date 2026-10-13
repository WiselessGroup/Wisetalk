//! This device's X25519 key pair. Keep `secret_bytes` in secure storage and
//! restore it with `Device::from_secret`; guests get a fresh one per session.

use flutter_rust_bridge::frb;
use wisetalk_core::crypto::DeviceKeyPair;

#[frb(opaque)]
pub struct Device(pub(crate) DeviceKeyPair);

impl Device {
    #[frb(sync)]
    pub fn generate() -> anyhow::Result<Device> {
        Ok(Device(DeviceKeyPair::generate()?))
    }

    #[frb(sync)]
    pub fn from_secret(secret: Vec<u8>) -> anyhow::Result<Device> {
        Ok(Device(DeviceKeyPair::from_secret_bytes(&secret)?))
    }

    #[frb(sync)]
    pub fn secret_bytes(&self) -> Vec<u8> {
        self.0.secret_bytes().to_vec()
    }

    /// Base64, as sent in `hello`.
    #[frb(sync, getter)]
    pub fn public_key(&self) -> String {
        self.0.public_key().to_base64()
    }

    #[frb(sync, getter)]
    pub fn fingerprint(&self) -> String {
        self.0.public_key().fingerprint().to_string()
    }
}
