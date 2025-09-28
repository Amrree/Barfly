import Cocoa
import AppKit

class MenuBarController: NSObject {
    
    private var statusItem: NSStatusItem?
    private var petController: PetController?
    private var timerController: TimerController?
    private var activityController: ActivityController?
    
    override init() {
        super.init()
        setupControllers()
    }
    
    private func setupControllers() {
        petController = PetController()
        timerController = TimerController()
        activityController = ActivityController()
    }
    
    func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else {
            print("Failed to create status item")
            return
        }
        
        // Set up the pet view as the status item's view
        if let petView = petController?.createPetView() {
            statusItem.view = petView
        }
        
        // Create the menu
        let menu = createMenu()
        statusItem.menu = menu
        
        // Start the pet animation
        petController?.startAnimation()
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Pet header
        let petHeader = NSMenuItem(title: "🐱 Mac Pet", action: nil, keyEquivalent: "")
        petHeader.isEnabled = false
        menu.addItem(petHeader)
        
        menu.addItem(NSMenuItem.separator())
        
        // Timer controls
        let startFocusItem = NSMenuItem(title: "▶ Start Focus Session", action: #selector(startFocusSession), keyEquivalent: "")
        startFocusItem.target = self
        menu.addItem(startFocusItem)
        
        let startBreakItem = NSMenuItem(title: "▶ Start Break", action: #selector(startBreak), keyEquivalent: "")
        startBreakItem.target = self
        menu.addItem(startBreakItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Activity tracking
        let activityItem = NSMenuItem(title: "📊 View Activity", action: #selector(showActivity), keyEquivalent: "")
        activityItem.target = self
        menu.addItem(activityItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings
        let settingsItem = NSMenuItem(title: "⚙️ Settings...", action: #selector(showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // About
        let aboutItem = NSMenuItem(title: "❓ About", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "🚪 Quit Mac Pet", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    // MARK: - Menu Actions
    
    @objc private func startFocusSession() {
        timerController?.startFocusSession()
        petController?.setPetState(.working)
    }
    
    @objc private func startBreak() {
        timerController?.startBreak()
        petController?.setPetState(.sleeping)
    }
    
    @objc private func showActivity() {
        activityController?.showActivityWindow()
    }
    
    @objc private func showSettings() {
        // TODO: Implement settings window
        print("Settings clicked")
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Mac Pet"
        alert.informativeText = "A delightful productivity companion for your menu bar.\n\nVersion 1.0"
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(self)
    }
}