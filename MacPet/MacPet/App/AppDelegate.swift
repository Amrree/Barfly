import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var menuBarController: MenuBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the dock since it's a menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize the menu bar controller
        menuBarController = MenuBarController()
        menuBarController?.setupMenuBar()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources
        menuBarController = nil
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep the app running even when windows are closed
        return false
    }
}