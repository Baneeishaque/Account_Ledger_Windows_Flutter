import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// Initializes the window's Flutter content and integration points.
  /// 
  /// Replaces the window's contentViewController with a newly created `FlutterViewController`,
  /// preserves the window's frame, registers generated Flutter plugins with the controller,
  /// and registers the Kotlin method channel on the Flutter engine's binary messenger.
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // Register method channel with Kotlin bridge
    KotlinBridge.registerMethodChannel(with: flutterViewController.engine.binaryMessenger)

    super.awakeFromNib()
  }
}