import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  /// Indicates whether the application should quit when its last window is closed.
  /// - Returns: `true` if the application should terminate after the last window is closed, `false` otherwise.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}