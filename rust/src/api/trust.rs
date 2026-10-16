//! Device keys of the people in my calls (WLK-18), see `wisetalk_core::trust`.
//! The record is JSON kept per server by the app; only warnings come of it.

use flutter_rust_bridge::frb;
use wisetalk_core::crypto::PublicKey;
use wisetalk_core::protocol::{AccountId, DeviceId};
use wisetalk_core::trust;

#[frb(opaque)]
pub struct KnownKeys(trust::KnownKeys);

fn ids(account: Option<String>, device: &str) -> anyhow::Result<(Option<AccountId>, DeviceId)> {
    let account = account.map(|a| a.parse().map(AccountId)).transpose()?;
    Ok((account, DeviceId(device.parse()?)))
}

impl KnownKeys {
    #[frb(sync)]
    pub fn empty() -> KnownKeys {
        KnownKeys(trust::KnownKeys::new())
    }

    /// Fails on a damaged record or one from a newer build.
    #[frb(sync)]
    pub fn from_json(json: String) -> anyhow::Result<KnownKeys> {
        Ok(KnownKeys(serde_json::from_str(&json)?))
    }

    #[frb(sync)]
    pub fn to_json(&self) -> anyhow::Result<String> {
        Ok(serde_json::to_string(&self.0)?)
    }

    /// `guest`, `first_contact`, `known`, `new_device` or `key_changed` for a
    /// participant's device key (base64). Changes nothing.
    #[frb(sync)]
    pub fn check(
        &self,
        account: Option<String>,
        device: String,
        public_key: String,
    ) -> anyhow::Result<String> {
        let (account, device) = ids(account, &device)?;
        let key = PublicKey::from_base64(&public_key)?;
        Ok(self.0.check(account, device, &key).as_str().to_owned())
    }

    /// Remembers the key as this device's from now on (Unix milliseconds).
    /// Returns whether to save the record.
    #[frb(sync)]
    pub fn accept(
        &mut self,
        account: Option<String>,
        device: String,
        public_key: String,
        now: i64,
    ) -> anyhow::Result<bool> {
        let (account, device) = ids(account, &device)?;
        let key = PublicKey::from_base64(&public_key)?;
        Ok(self.0.accept(account, device, &key, now))
    }

    /// Forgets devices not seen for a while, longer on servers that let
    /// guests in. Returns whether to save the record.
    #[frb(sync)]
    pub fn forget_unseen(&mut self, now: i64, guests_open: bool) -> bool {
        self.0.forget_unseen(now, trust::forget_after(guests_open))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use wisetalk_core::crypto::DeviceKeyPair;

    #[test]
    fn a_changed_key_is_noticed_and_survives_json() {
        let account = Some("00000000-0000-0000-0000-0000000000a2".to_owned());
        let device = "00000000-0000-0000-0000-0000000000d1".to_owned();
        let first = DeviceKeyPair::generate().unwrap().public_key().to_base64();
        let second = DeviceKeyPair::generate().unwrap().public_key().to_base64();
        let mut known = KnownKeys::empty();
        assert_eq!(
            known
                .check(account.clone(), device.clone(), first.clone())
                .unwrap(),
            "first_contact"
        );
        assert!(
            known
                .accept(account.clone(), device.clone(), first.clone(), 1)
                .unwrap()
        );
        let mut known = KnownKeys::from_json(known.to_json().unwrap()).unwrap();
        assert_eq!(
            known
                .check(account.clone(), device.clone(), second.clone())
                .unwrap(),
            "key_changed"
        );
        assert!(
            known
                .accept(account.clone(), device.clone(), second.clone(), 2)
                .unwrap()
        );
        assert_eq!(known.check(account, device, second).unwrap(), "known");
        assert!(known.forget_unseen(trust::FORGET_ACCOUNTS_ONLY_MS + 2, false));
    }
}
