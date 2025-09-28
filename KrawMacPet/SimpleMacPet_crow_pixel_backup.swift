import Cocoa

class SimpleMacPet: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    private var focusTimer: Timer?
    private var walkingTimer: Timer?
    private var focusDuration: TimeInterval = 25 * 60 // 25 minutes in seconds
    private var isWalking = false
    private var walkPosition: CGFloat = 80.0 // Start 2 icons to the right (2 * 40px = 80px)
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
        
        // Set the pixel penguin as the button's image
        statusItem.button?.image = createCatImage()
        statusItem.button?.target = self
        statusItem.button?.action = #selector(showMenu)
        
        // Create the menu
        let menu = createMenu()
        statusItem.menu = menu
        
        print("🐦 Mac Pet is now running in the menu bar!")
        print("Look for the pixel crow in your menu bar!")
    }
    
    private func createCatImage() -> NSImage {
        let size = NSSize(width: 240, height: 32) // 6 icon spaces = 6 * 40px = 240px
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Clear background
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Draw a pixel crow with black head, bigger grey belly
        let crowPixels = [
            // Row 0 - Top of head
            [0,0,1,1,1,1,0,0],
            // Row 1 - Head
            [0,1,1,1,1,1,1,0],
            // Row 2 - Eyes
            [1,1,0,1,1,0,1,1],
            // Row 3 - Beak
            [1,1,1,0,0,1,1,1],
            // Row 4 - Body
            [1,1,1,1,1,1,1,1],
            // Row 5 - Body with bigger grey belly
            [0,1,3,3,3,1,1,0],
            // Row 6 - Body
            [0,0,1,1,1,1,0,0],
            // Row 7 - Feet
            [0,0,1,1,1,1,0,0]
        ]
        
        let cellSize: CGFloat = 4.0
        let startX = (size.width - CGFloat(crowPixels[0].count) * cellSize) / 2
        let startY = (size.height - CGFloat(crowPixels.count) * cellSize) / 2
        
        for (row, pixelRow) in crowPixels.enumerated() {
            for (col, pixel) in pixelRow.enumerated() {
                if pixel == 1 {
                    // Black parts (head, beak, feet)
                    NSColor.black.setFill()
                } else if pixel == 3 {
                    // Grey belly
                    NSColor.gray.setFill()
                } else {
                    continue
                }
                
                let rect = NSRect(
                    x: startX + CGFloat(col) * cellSize,
                    y: startY + CGFloat(crowPixels.count - 1 - row) * cellSize,
                    width: cellSize,
                    height: cellSize
                )
                rect.fill()
            }
        }
        
        // Draw eyes in black
        NSColor.black.setFill()
        let eyeSize: CGFloat = 2.0
        let leftEye = NSRect(x: startX + 2 * cellSize, y: startY + 5 * cellSize, width: eyeSize, height: eyeSize)
        let rightEye = NSRect(x: startX + 5 * cellSize, y: startY + 5 * cellSize, width: eyeSize, height: eyeSize)
        leftEye.fill()
        rightEye.fill()
        
        image.unlockFocus()
        return image
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
        
        let alert = NSAlert()
        alert.messageText = "Focus Session Started"
        alert.informativeText = "Kraw will walk while you work, he will tire."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func focusSessionCompleted() {
        print("Focus session completed!")
        
        // Stop the cat walking
        stopCatWalkingAnimation()
        
        let alert = NSAlert()
        alert.messageText = "Focus Session Complete!"
        alert.informativeText = "Great job! Time for a break."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc private func startBreak() {
        print("Starting break...")
        let alert = NSAlert()
        alert.messageText = "Break Started"
        alert.informativeText = "Time for a 5-minute break!"
        alert.addButton(withTitle: "OK")
        alert.runModal()
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
    
    private func startCatWalkingAnimation() {
        isWalking = true
        var frameIndex = 0
        
        walkingTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self, self.isWalking else { return }
            
            // Update walk position - move further and faster
            self.walkPosition += self.walkDirection * 8.0
            
            // Walk within the 6 icon spaces allocated (starts 2 icons to the right)
            if self.walkPosition <= -120.0 { // 5 icons left from start = 5 * 40px = 200px, but start is at 80px, so 80-200 = -120px
                self.walkDirection = 1.0 // Turn around
            } else if self.walkPosition >= 80.0 { // Back to start position (2 icons right)
                self.walkDirection = -1.0 // Walk left again
            }
            
            // Create walking crow frames with different leg positions
            let walkingFrames = [
                // Frame 1: Standing
                [
                    [0,0,1,1,1,1,0,0],
                    [0,1,1,1,1,1,1,0],
                    [1,1,0,1,1,0,1,1],
                    [1,1,1,0,0,1,1,1],
                    [1,1,1,1,1,1,1,1],
                    [0,1,3,3,3,1,1,0],
                    [0,0,1,1,1,1,0,0],
                    [0,0,1,1,1,1,0,0]
                ],
                // Frame 2: Walking - legs apart
                [
                    [0,0,1,1,1,1,0,0],
                    [0,1,1,1,1,1,1,0],
                    [1,1,0,1,1,0,1,1],
                    [1,1,1,0,0,1,1,1],
                    [1,1,1,1,1,1,1,1],
                    [0,1,3,3,3,1,1,0],
                    [0,0,1,1,1,1,0,0],
                    [0,1,0,1,1,0,1,0]
                ],
                // Frame 3: Walking - legs together
                [
                    [0,0,1,1,1,1,0,0],
                    [0,1,1,1,1,1,1,0],
                    [1,1,0,1,1,0,1,1],
                    [1,1,1,0,0,1,1,1],
                    [1,1,1,1,1,1,1,1],
                    [0,1,3,3,3,1,1,0],
                    [0,0,1,1,1,1,0,0],
                    [0,0,1,1,1,1,0,0]
                ]
            ]
            
            let crowPixels = walkingFrames[frameIndex % walkingFrames.count]
            self.statusItem?.button?.image = self.createCatImage(from: crowPixels, offset: self.walkPosition)
            frameIndex += 1
        }
    }
    
    private func stopCatWalkingAnimation() {
        isWalking = false
        walkingTimer?.invalidate()
        walkingTimer = nil
        
        // Return to standing position
        walkPosition = 80.0 // Back to start position (2 icons right)
        let standingFrame = [
            [0,0,1,1,1,1,0,0],
            [0,1,1,1,1,1,1,0],
            [1,1,0,1,1,0,1,1],
            [1,1,1,0,0,1,1,1],
            [1,1,1,1,1,1,1,1],
            [0,1,3,3,3,1,1,0],
            [0,0,1,1,1,1,0,0],
            [0,0,1,1,1,1,0,0]
        ]
        statusItem?.button?.image = createCatImage(from: standingFrame, offset: 80.0)
    }
    
    private func createCatImage(from pixels: [[Int]], offset: CGFloat = 0) -> NSImage {
        let size = NSSize(width: 240, height: 32) // 6 icon spaces = 6 * 40px = 240px
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Clear background
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        let cellSize: CGFloat = 4.0
        let startX = (size.width - CGFloat(pixels[0].count) * cellSize) / 2 + offset
        let startY = (size.height - CGFloat(pixels.count) * cellSize) / 2
        
        for (row, pixelRow) in pixels.enumerated() {
            for (col, pixel) in pixelRow.enumerated() {
                if pixel == 1 {
                    // Black parts (head, beak, feet)
                    NSColor.black.setFill()
                } else if pixel == 3 {
                    // Grey belly
                    NSColor.gray.setFill()
                } else {
                    continue
                }
                
                let rect = NSRect(
                    x: startX + CGFloat(col) * cellSize,
                    y: startY + CGFloat(pixels.count - 1 - row) * cellSize,
                    width: cellSize,
                    height: cellSize
                )
                rect.fill()
            }
        }
        
        // Draw eyes in black
        NSColor.black.setFill()
        let eyeSize: CGFloat = 2.0
        let leftEye = NSRect(x: startX + 2 * cellSize, y: startY + 5 * cellSize, width: eyeSize, height: eyeSize)
        let rightEye = NSRect(x: startX + 5 * cellSize, y: startY + 5 * cellSize, width: eyeSize, height: eyeSize)
        leftEye.fill()
        rightEye.fill()
        
        image.unlockFocus()
        return image
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
