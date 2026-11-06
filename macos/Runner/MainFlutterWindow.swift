import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var dockIcon: DarkDockIcon?

  override func awakeFromNib() {
    // macOS 26 draws AppIcon.icon light or dark itself, in the Dock, Finder
    // and Launchpad alike; a picture set here would replace it with a flat
    // one (WLK-59).
    if #unavailable(macOS 26) {
      dockIcon = DarkDockIcon()
    }

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
