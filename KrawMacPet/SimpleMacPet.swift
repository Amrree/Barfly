import Cocoa

class SimpleMacPet: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    private var focusTimer: Timer?
    private var walkingTimer: Timer?
    private var focusDuration: TimeInterval = 25 * 60 // 25 minutes in seconds
    private var isWalking = false
    private var walkPosition: CGFloat = 40.0 // Start 1 icon to the right (1 * 40px = 40px)
    private var walkDirection: CGFloat = -1.0 // Start walking left
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the dock since it's a menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else {
            print("Failed to create status item")
            return
        }
        
        // Set the crow image as the button's image
        if let crowImage = createCatImage() {
            statusItem.button?.image = crowImage
        } else {
            print("Failed to load crow image, using fallback")
        }
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showMenu)
        
        // Create the menu
        let menu = createMenu()
        statusItem.menu = menu
        
        print("🐦 Mac Pet is now running in the menu bar!")
        print("Look for the pixel crow in your menu bar!")
    }
    
    private func createCatImage() -> NSImage? {
        // Load the resting crow image
        guard let image = NSImage(contentsOfFile: "/Users/amre/Barfly/KrawMacPet/crow_resting.png") else {
            print("Failed to load crow_resting.png")
            return nil
        }
        
        // Resize to fit menu bar (32px height, maintain aspect ratio)
        let targetSize = NSSize(width: 240, height: 32) // 6 icon spaces
        let resizedImage = NSImage(size: targetSize)
        
        resizedImage.lockFocus()
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: targetSize).fill()
        
        // Calculate scaling to fit height while maintaining aspect ratio
        let aspectRatio = image.size.width / image.size.height
        let scaledWidth = targetSize.height * aspectRatio
        let scaledHeight = targetSize.height
        
        // Center the image
        let x = (targetSize.width - scaledWidth) / 2
        let y = (targetSize.height - scaledHeight) / 2
        
        let drawRect = NSRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
        image.draw(in: drawRect)
        
        resizedImage.unlockFocus()
        return resizedImage
    }
    
    @objc private func showMenu() {
        statusItem?.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: statusItem?.button)
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Pet header
        let petHeader = NSMenuItem(title: "🐦 Mac Pet", action: nil, keyEquivalent: "")
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
    
    @objc private func startFocusSession() {
        print("Starting focus session...")
        
        // Start the cat walking animation by updating the menu bar icon
        startCatWalkingAnimation()
        
        // Start the focus timer
        focusTimer = Timer.scheduledTimer(withTimeInterval: focusDuration, repeats: false) { [weak self] _ in
            self?.focusSessionCompleted()
        }
        
        // Start the walking animation immediately
        startCatWalkingAnimation()
    }
    
    private func focusSessionCompleted() {
        print("Focus session completed!")
        
        // Stop the cat walking
        stopCatWalkingAnimation()
        
        // Focus session completed - no popup needed
    }
    
    @objc private func startBreak() {
        print("Starting break...")
        let alert = NSAlert()
        alert.messageText = "☕ Kraw's Break Time!"
        alert.informativeText = "Your crow companion is taking a well-earned rest. Enjoy your 5-minute break - Kraw will be ready to patrol again when you return!"
        alert.addButton(withTitle: "Enjoy Break!")
        alert.runModal()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "🐦 About Kraw"
        alert.informativeText = "Meet Kraw, your loyal crow companion! He patrols your menu bar during focus sessions, keeping you company while you work. When you focus, Kraw walks. When you rest, Kraw rests.\n\nVersion 1.0 - The Crow Edition"
        alert.addButton(withTitle: "Fly On!")
        alert.runModal()
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    private func startCatWalkingAnimation() {
        isWalking = true
        var frameIndex = 0
        
        walkingTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            guard let self = self, self.isWalking else { return }
            
            // Update walk position - faster movement
            self.walkPosition += self.walkDirection * 6.0
            
            // Walk within the 6 icon spaces allocated (starts 2 icons to the right)
            if self.walkPosition <= -120.0 { // 5 icons left from start = 5 * 40px = 200px, but start is at 80px, so 80-200 = -120px
                self.walkDirection = 1.0 // Turn around
            } else if self.walkPosition >= 40.0 { // Back to 1 icon right (not 2)
                self.walkDirection = -1.0 // Walk left again
            }
            
            // Load walking animation from GIF
            if let walkingImage = self.createWalkingImage(frameIndex: frameIndex, offset: self.walkPosition) {
                self.statusItem?.button?.image = walkingImage
            }
            frameIndex += 1
        }
    }
    
    private func stopCatWalkingAnimation() {
        isWalking = false
        walkingTimer?.invalidate()
        walkingTimer = nil
        
        // Return to standing position
        walkPosition = 40.0 // Back to start position (1 icon right)
        if let restingImage = createCatImage() {
            statusItem?.button?.image = restingImage
        }
    }
    
    private func createWalkingImage(frameIndex: Int, offset: CGFloat) -> NSImage? {
        // Choose the correct GIF based on walking direction (swapped)
        let gifFile = walkDirection < 0 ? "/Users/amre/Barfly/KrawMacPet/right crow .gif" : "/Users/amre/Barfly/KrawMacPet/Left crow.gif"
        
        // Load the walking GIF
        guard let gifData = NSData(contentsOfFile: gifFile) else {
            print("Failed to load walking GIF: \(gifFile)")
            return nil
        }
        
        // Create image source from GIF data
        guard let imageSource = CGImageSourceCreateWithData(gifData, nil) else {
            print("Failed to create image source from GIF")
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        guard frameCount > 0 else {
            print("GIF has no frames")
            return nil
        }
        
        // Get the frame for the current animation
        let currentFrame = frameIndex % frameCount
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, currentFrame, nil) else {
            print("Failed to create image from frame \(currentFrame)")
            return nil
        }
        
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        
        // Resize to fit menu bar (32px height, maintain aspect ratio)
        let targetSize = NSSize(width: 240, height: 32) // 6 icon spaces
        let resizedImage = NSImage(size: targetSize)
        
        resizedImage.lockFocus()
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: targetSize).fill()
        
        // Calculate scaling to fit height while maintaining aspect ratio
        let aspectRatio = nsImage.size.width / nsImage.size.height
        let scaledWidth = targetSize.height * aspectRatio
        let scaledHeight = targetSize.height
        
        // Center the image with offset
        let x = (targetSize.width - scaledWidth) / 2 + offset
        let y = (targetSize.height - scaledHeight) / 2
        
        let drawRect = NSRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
        nsImage.draw(in: drawRect)
        
        resizedImage.unlockFocus()
        return resizedImage
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up resources
        statusItem = nil
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep the app running even when windows are closed
        return false
    }
}
