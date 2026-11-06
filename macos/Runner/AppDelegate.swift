import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

/// Before macOS 26 an app has a single icon, the light tile, which glows in
/// the dark theme. While Wisetalk runs, this puts the dark tile from the asset
/// catalog (scripts/app-icons.py) in the Dock when the system turns dark, and
/// gives the Dock its own icon back when it turns light. It costs nothing in
/// between: a key-value observer that fires only when the appearance changes.
final class DarkDockIcon {
  private var observation: NSKeyValueObservation?
  private var dark: Bool?

  init() {
    observation = NSApp.observe(\.effectiveAppearance, options: [.initial]) { [weak self] app, _ in
      let dark = app.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
      DispatchQueue.main.async { self?.show(dark: dark) }
    }
  }

  private func show(dark: Bool) {
    guard dark != self.dark else { return }
    self.dark = dark
    // nil restores the bundle's icon.
    NSApp.applicationIconImage = dark ? NSImage(named: "AppIconDark") : nil
  }
}
