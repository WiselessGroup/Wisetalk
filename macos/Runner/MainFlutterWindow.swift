import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var dockIcon: DarkDockIcon?
  private var windowChannel: FlutterMethodChannel?

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

    // net.wiseless.wisetalk/window: "fullScreen" on or off for a video
    // (lib/data/app_window.dart, WLK-63).
    let channel = FlutterMethodChannel(
      name: "net.wiseless.wisetalk/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "fullScreen", let window = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      let on = call.arguments as? Bool ?? false
      if window.styleMask.contains(.fullScreen) != on {
        window.toggleFullScreen(nil)
      }
      result(nil)
    }
    windowChannel = channel

    super.awakeFromNib()
  }
}
