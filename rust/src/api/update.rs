//! Desktop updates through Velopack: the app checks the client's releases
//! on GitHub, downloads an update in the background, and applies it on
//! "Restart to Update" or, failing that, on the next start. Builds Velopack
//! didn't install (`flutter run`, a bare bundle) don't update.

use flutter_rust_bridge::frb;

/// Where releases come from, for every community's servers alike.
const RELEASES: &str = "https://github.com/WiselessGroup/Wisetalk";

/// Lets Velopack handle install and update hooks. Runs first thing in
/// `main`: during an install or update it may finish the process itself.
#[frb(sync)]
pub fn start_updates() {
    #[cfg(any(target_os = "linux", target_os = "windows", target_os = "macos"))]
    velopack::VelopackApp::build().run();
}

#[cfg(any(target_os = "linux", target_os = "windows", target_os = "macos"))]
fn manager() -> Option<velopack::UpdateManager> {
    // A local folder of packages instead, for trying updates out.
    let manager = match std::env::var("WISETALK_UPDATE_FEED") {
        Ok(folder) => {
            velopack::UpdateManager::new(velopack::sources::FileSource::new(folder), None, None)
        }
        Err(_) => velopack::UpdateManager::new(
            velopack::sources::GithubSource::new(RELEASES, None, false),
            None,
            None,
        ),
    };
    manager.ok()
}

/// The installed version; `None` where updates don't apply.
#[frb(sync)]
pub fn installed_version() -> Option<String> {
    #[cfg(any(target_os = "linux", target_os = "windows", target_os = "macos"))]
    return manager().map(|m| m.get_current_version_as_string());
    #[cfg(not(any(target_os = "linux", target_os = "windows", target_os = "macos")))]
    None
}

/// Downloads a newer release if there is one; returns the version waiting
/// for a restart, already downloaded earlier or just now.
pub fn download_update() -> anyhow::Result<Option<String>> {
    #[cfg(any(target_os = "linux", target_os = "windows", target_os = "macos"))]
    {
        let Some(manager) = manager() else {
            return Ok(None);
        };
        if let velopack::UpdateCheck::UpdateAvailable(update) = manager.check_for_updates()? {
            manager.download_updates(&update, None)?;
        }
        Ok(manager
            .get_update_pending_restart()
            .map(|asset| asset.Version))
    }
    #[cfg(not(any(target_os = "linux", target_os = "windows", target_os = "macos")))]
    Ok(None)
}

/// Quits, applies the downloaded update and starts the new version.
pub fn restart_to_update() -> anyhow::Result<()> {
    #[cfg(any(target_os = "linux", target_os = "windows", target_os = "macos"))]
    if let Some(manager) = manager()
        && let Some(update) = manager.get_update_pending_restart()
    {
        manager.apply_updates_and_restart(&update)?;
    }
    Ok(())
}
