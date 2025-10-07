import Cocoa

class SimpleMacPet: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem?
    private var focusTimer: Timer?
    private var walkingTimer: Timer?
    private var focusDuration: TimeInterval = 25 * 60 // 25 minutes in seconds
    private var isWalking = false
    private var walkPosition: CGFloat = 40.0 // Start 1 icon to the right (1 * 40px = 40px)
    private var walkDirection: CGFloat = -1.0 // Start walking left
    
    // Energy modes
    private enum EnergyMode {
        case eco      // 2.0s timer, 80% reduction
        case normal   // 0.4s timer, current
        case performance // 0.2s timer, faster
    }
    
    private var currentEnergyMode: EnergyMode = .normal // Start with normal mode
    
    // Walking tracking
    private var totalDistanceWalked: CGFloat = 0.0
    private var sessionStartTime: Date?
    private var energyTaperTimer: Timer?
    private var hasTapered = false
    
    // Distance conversion (1 pixel = 0.001 km)
    private let pixelsToKm: CGFloat = 0.001
    
    // City database with real-world distances
    private struct CityRoute {
        let name: String
        let distanceKm: CGFloat
        let description: String
    }
    
    private let cityRoutes: [CityRoute] = [
        CityRoute(name: "Belfast → Dublin", distanceKm: 167, description: "Kraw flew across the Irish Sea!"),
        CityRoute(name: "London → Paris", distanceKm: 344, description: "Kraw crossed the English Channel!"),
        CityRoute(name: "New York → Boston", distanceKm: 306, description: "Kraw traveled the Northeast Corridor!"),
        CityRoute(name: "Tokyo → Osaka", distanceKm: 515, description: "Kraw journeyed through Japan!"),
        CityRoute(name: "Sydney → Melbourne", distanceKm: 713, description: "Kraw crossed the Australian continent!"),
        CityRoute(name: "Los Angeles → San Francisco", distanceKm: 559, description: "Kraw flew the California coast!"),
        CityRoute(name: "Berlin → Munich", distanceKm: 504, description: "Kraw traveled through Germany!"),
        CityRoute(name: "Moscow → St. Petersburg", distanceKm: 635, description: "Kraw crossed Russia!"),
        CityRoute(name: "Cairo → Alexandria", distanceKm: 220, description: "Kraw flew along the Nile!"),
        CityRoute(name: "Barcelona → Madrid", distanceKm: 505, description: "Kraw crossed Spain!")
    ]
    
    private var unlockedCities: Set<String> = []
    
    // Pet selection
    private enum PetType {
        case original
        case newKraw
        case yellowEgg
        case babyBird
    }
    
    private var currentPetType: PetType = .original // Back to original Kraw
    
    // Click detection for pet interactions
    private var clickCount = 0
    private var clickTimer: Timer?
    private let doubleClickDelay: TimeInterval = 0.3 // 300ms delay for double click detection
    
    // Pet interaction states
    private var isInteracting = false
    private var interactionTimer: Timer?
    
    // Animation frame tracking
    private var currentFrame = 0
    
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
        statusItem.button?.action = #selector(handleClick)
        
        // Create the menu
        let menu = createMenu()
        statusItem.menu = menu
        
        print("Kraw is now running in the menu bar!")
        print("Look for the pixel crow in your menu bar!")
    }
    
    private func createCatImage() -> NSImage? {
        // Load the first frame from the appropriate GIF as stationary image
        let gifFile: String
        switch currentPetType {
        case .original:
            gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/right crow .gif"
        case .newKraw:
            gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/Left_Kraw.gif" // Use Left_Kraw.gif for resting
        case .yellowEgg:
            gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/hd-single-yellow-egg-clipart-transparent-background-735811696682996dk46wnzpqa.png" // Use yellow egg PNG for resting
        case .babyBird:
            gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/c846ca41824ae2ba3ecab07859dafbec65188d29.gif" // Use baby bird GIF for resting
        }
        
        guard let gifData = NSData(contentsOfFile: gifFile) else {
            print("Failed to load stationary GIF: \(gifFile)")
            return nil
        }
        
        guard let imageSource = CGImageSourceCreateWithData(gifData, nil) else {
            print("Failed to create image source from stationary GIF")
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        guard frameCount > 0 else {
            print("Stationary GIF has no frames")
            return nil
        }
        
        // Get the first frame
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            print("Failed to create image from first frame")
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
        
        // Center the image
        let x = (targetSize.width - scaledWidth) / 2
        let y = (targetSize.height - scaledHeight) / 2
        
        let drawRect = NSRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
        nsImage.draw(in: drawRect)
        
        resizedImage.unlockFocus()
        return resizedImage
    }
    
    @objc private func handleClick() {
        clickCount += 1
        
        // Cancel previous timer if it exists
        clickTimer?.invalidate()
        
        if clickCount == 1 {
            // Start timer to wait for potential double click
            clickTimer = Timer.scheduledTimer(withTimeInterval: doubleClickDelay, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                if self.clickCount == 1 {
                    // Single click - poke the pet
                    self.pokePet()
                }
                self.clickCount = 0
            }
        } else if clickCount == 2 {
            // Double click - show menu
            clickTimer?.invalidate()
            showMenu()
            clickCount = 0
        }
    }
    
    @objc private func showMenu() {
        statusItem?.menu?.popUp(positioning: nil, at: NSPoint(x: 0, y: 0), in: statusItem?.button)
    }
    
    // MARK: - Pet Interactions
    
    private func pokePet() {
        guard !isInteracting else { return } // Prevent multiple interactions
        
        isInteracting = true
        print("Poking \(currentPetType)")
        
        switch currentPetType {
        case .yellowEgg:
            pokeEgg()
        case .babyBird:
            pokeBabyBird()
        case .original:
            pokeOriginalKraw()
        case .newKraw:
            pokeNewKraw()
        }
        
        // Reset interaction state after animation
        interactionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.isInteracting = false
        }
    }
    
    private func pokeEgg() {
        print("🥚 Egg wobbles when poked!")
        // Create a wobble animation
        let originalImage = statusItem?.button?.image
        
        // Create a wobbled version
        if let image = originalImage {
            let wobbleImage = createWobbleImage(from: image)
            statusItem?.button?.image = wobbleImage
            
            // Return to original after wobble
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
                self?.statusItem?.button?.image = originalImage
            }
        }
    }
    
    private func pokeBabyBird() {
        print("🐣 Baby bird chirps and flaps excitedly!")
        // Create an excited animation
        let originalImage = statusItem?.button?.image
        
        // Create an excited version
        if let image = originalImage {
            let excitedImage = createExcitedImage(from: image)
            statusItem?.button?.image = excitedImage
            
            // Return to original after excitement
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false) { [weak self] _ in
                self?.statusItem?.button?.image = originalImage
            }
        }
    }
    
    private func pokeOriginalKraw() {
        print("🐦 Original Kraw caws and hops!")
        // Create a hop animation
        let originalImage = statusItem?.button?.image
        
        // Create a hopped version
        if let image = originalImage {
            let hopImage = createHopImage(from: image)
            statusItem?.button?.image = hopImage
            
            // Return to original after hop
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] _ in
                self?.statusItem?.button?.image = originalImage
            }
        }
    }
    
    private func pokeNewKraw() {
        print("🐦 New Kraw does a little dance!")
        // Create a dance animation
        let originalImage = statusItem?.button?.image
        
        // Create a dancing version
        if let image = originalImage {
            let danceImage = createDanceImage(from: image)
            statusItem?.button?.image = danceImage
            
            // Return to original after dance
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                self?.statusItem?.button?.image = originalImage
            }
        }
    }
    
    private func createWobbleImage(from image: NSImage) -> NSImage {
        let size = image.size
        let wobbleImage = NSImage(size: size)
        
        wobbleImage.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        
        // Apply wobble effect (slight rotation and scale)
        context?.translateBy(x: size.width / 2, y: size.height / 2)
        context?.rotate(by: 0.15) // Wobble rotation
        context?.scaleBy(x: 1.1, y: 0.9) // Slight squash
        context?.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        image.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        wobbleImage.unlockFocus()
        
        return wobbleImage
    }
    
    private func createExcitedImage(from image: NSImage) -> NSImage {
        let size = image.size
        let excitedImage = NSImage(size: size)
        
        excitedImage.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        
        // Apply excited effect (bigger and bouncy)
        context?.translateBy(x: size.width / 2, y: size.height / 2)
        context?.scaleBy(x: 1.3, y: 1.3) // Bigger
        context?.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        image.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        excitedImage.unlockFocus()
        
        return excitedImage
    }
    
    private func createHopImage(from image: NSImage) -> NSImage {
        let size = image.size
        let hopImage = NSImage(size: size)
        
        hopImage.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        
        // Apply hop effect (upward movement)
        context?.translateBy(x: 0, y: 5) // Move up
        context?.scaleBy(x: 1.1, y: 1.1) // Slightly bigger
        
        image.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        hopImage.unlockFocus()
        
        return hopImage
    }
    
    private func createDanceImage(from image: NSImage) -> NSImage {
        let size = image.size
        let danceImage = NSImage(size: size)
        
        danceImage.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        
        // Apply dance effect (rotation and scale)
        context?.translateBy(x: size.width / 2, y: size.height / 2)
        context?.rotate(by: 0.2) // Dance rotation
        context?.scaleBy(x: 1.2, y: 1.2) // Bigger
        context?.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        image.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        danceImage.unlockFocus()
        
        return danceImage
    }
    
    // MARK: - Pet Interactions
    
    private func interactWithPet() {
        guard !isInteracting else { return } // Prevent multiple interactions
        
        isInteracting = true
        print("Interacting with \(currentPetType)")
        
        switch currentPetType {
        case .yellowEgg:
            animateEggShake()
        case .babyBird:
            animateBabyJump()
        case .original:
            speedBoostAnimation()
        case .newKraw:
            specialMoveAnimation()
        }
        
        // Reset interaction state after animation
        interactionTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.isInteracting = false
        }
    }
    
    private func animateEggShake() {
        print("🥚 Egg is shaking!")
        // Create a subtle shake animation by temporarily changing the image
        let originalImage = statusItem?.button?.image
        
        // Create a slightly rotated version for shake effect
        if let image = originalImage {
            let shakeImage = createShakeImage(from: image)
            statusItem?.button?.image = shakeImage
            
            // Return to original after shake
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                self?.statusItem?.button?.image = originalImage
            }
        }
    }
    
    private func animateBabyJump() {
        print("🐣 Baby bird is jumping!")
        // Create a jump animation by temporarily changing the image
        let originalImage = statusItem?.button?.image
        
        // Create a slightly scaled up version for jump effect
        if let image = originalImage {
            let jumpImage = createJumpImage(from: image)
            statusItem?.button?.image = jumpImage
            
            // Return to original after jump
            Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
                self?.statusItem?.button?.image = originalImage
            }
        }
    }
    
    private func speedBoostAnimation() {
        print("⚡ Kraw got a speed boost!")
        // Temporarily increase walking speed
        let originalSpeed = getTimerInterval()
        let boostSpeed = originalSpeed * 0.5 // 2x faster
        
        // Stop current walking and restart with boost
        stopCatWalkingAnimation()
        
        // Start with boosted speed
        walkingTimer = Timer.scheduledTimer(withTimeInterval: boostSpeed, repeats: true) { [weak self] _ in
            guard let self = self, self.isWalking else { return }
            
            // Update walking animation with current frame
            if let walkingImage = self.createWalkingImage(frameIndex: self.currentFrame, offset: self.walkPosition) {
                self.statusItem?.button?.image = walkingImage
            }
            
            // Update frame and position
            self.currentFrame = (self.currentFrame + 1) % 4
            self.walkPosition += self.walkDirection * 6.0 // Boosted movement speed
            
            // Check boundaries
            if self.walkPosition <= -200.0 || self.walkPosition >= 40.0 {
                self.walkDirection = -self.walkDirection
            }
        }
        
        // Return to normal speed after 3 seconds
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.stopCatWalkingAnimation()
            self?.startCatWalkingAnimation() // Restart with normal speed
        }
    }
    
    private func specialMoveAnimation() {
        print("✨ New Kraw is doing a special move!")
        // Create a special animation by temporarily changing direction
        let originalDirection = walkDirection
        
        // Quick direction change
        walkDirection = -walkDirection
        
        // Return to original direction after 1 second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.walkDirection = originalDirection
        }
    }
    
    private func createShakeImage(from image: NSImage) -> NSImage {
        let size = image.size
        let shakeImage = NSImage(size: size)
        
        shakeImage.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        
        // Apply slight rotation for shake effect
        context?.translateBy(x: size.width / 2, y: size.height / 2)
        context?.rotate(by: 0.1) // Small rotation
        context?.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        image.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        shakeImage.unlockFocus()
        
        return shakeImage
    }
    
    private func createJumpImage(from image: NSImage) -> NSImage {
        let size = image.size
        let jumpImage = NSImage(size: size)
        
        jumpImage.lockFocus()
        let context = NSGraphicsContext.current?.cgContext
        
        // Apply slight scale up for jump effect
        context?.translateBy(x: size.width / 2, y: size.height / 2)
        context?.scaleBy(x: 1.2, y: 1.2) // 20% larger
        context?.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        image.draw(at: NSPoint.zero, from: NSRect(origin: .zero, size: size), operation: .sourceOver, fraction: 1.0)
        jumpImage.unlockFocus()
        
        return jumpImage
    }
    
    private func createEggImage() -> NSImage? {
        // Yellow egg just sits there - no animation needed
        let gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/hd-single-yellow-egg-clipart-transparent-background-735811696682996dk46wnzpqa.png"
        
        guard let imageData = NSData(contentsOfFile: gifFile) else {
            print("Failed to load egg image: \(gifFile)")
            return nil
        }
        
        guard let image = NSImage(data: imageData as Data) else {
            print("Failed to create image from egg data")
            return nil
        }
        
        // Resize to fit menu bar
        let targetSize = NSSize(width: 22, height: 22)
        let resizedImage = NSImage(size: targetSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize))
        resizedImage.unlockFocus()
        return resizedImage
    }
    
    private func createBabyBirdImage() -> NSImage? {
        // Baby bird flaps wings but stays in place
        let gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/c846ca41824ae2ba3ecab07859dafbec65188d29.gif"
        
        guard let gifData = NSData(contentsOfFile: gifFile) else {
            print("Failed to load baby bird GIF: \(gifFile)")
            return nil
        }
        
        guard let imageSource = CGImageSourceCreateWithData(gifData, nil) else {
            print("Failed to create image source from baby bird GIF")
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(imageSource)
        guard frameCount > 0 else {
            print("Baby bird GIF has no frames")
            return nil
        }
        
        // Use current frame for animation
        let currentFrame = self.currentFrame % frameCount
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, currentFrame, nil) else {
            print("Failed to create image from baby bird frame \(currentFrame)")
            return nil
        }
        
        let image = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        
        // Resize to fit menu bar
        let targetSize = NSSize(width: 22, height: 22)
        let resizedImage = NSImage(size: targetSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize))
        resizedImage.unlockFocus()
        
        // Advance frame for next animation
        self.currentFrame += 1
        
        return resizedImage
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Pet header
        let petHeader = NSMenuItem(title: "Kraw", action: nil, keyEquivalent: "")
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
        
        // Energy mode controls
        let energyHeader = NSMenuItem(title: "⚡ Energy Mode", action: nil, keyEquivalent: "")
        energyHeader.isEnabled = false
        menu.addItem(energyHeader)
        
        let ecoModeItem = NSMenuItem(title: "🌱 Eco Mode (2.0s)", action: #selector(setEcoMode), keyEquivalent: "")
        ecoModeItem.target = self
        ecoModeItem.state = currentEnergyMode == .eco ? .on : .off
        menu.addItem(ecoModeItem)
        
        let normalModeItem = NSMenuItem(title: "⚡ Normal Mode (0.4s)", action: #selector(setNormalMode), keyEquivalent: "")
        normalModeItem.target = self
        normalModeItem.state = currentEnergyMode == .normal ? .on : .off
        menu.addItem(normalModeItem)
        
        let performanceModeItem = NSMenuItem(title: "🚀 Performance Mode (0.2s)", action: #selector(setPerformanceMode), keyEquivalent: "")
        performanceModeItem.target = self
        performanceModeItem.state = currentEnergyMode == .performance ? .on : .off
        menu.addItem(performanceModeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Bird selection
        let birdHeader = NSMenuItem(title: "Bird Selection", action: nil, keyEquivalent: "")
        birdHeader.isEnabled = false
        menu.addItem(birdHeader)
        
        let originalBirdItem = NSMenuItem(title: "Original Kraw", action: #selector(setOriginalBird), keyEquivalent: "")
        originalBirdItem.target = self
        originalBirdItem.state = currentPetType == .original ? .on : .off
        menu.addItem(originalBirdItem)
        
        let newKrawItem = NSMenuItem(title: "New Kraw", action: #selector(setNewKraw), keyEquivalent: "")
        newKrawItem.target = self
        newKrawItem.state = currentPetType == .newKraw ? .on : .off
        menu.addItem(newKrawItem)
        
        let yellowEggItem = NSMenuItem(title: "Yellow Egg", action: #selector(setYellowEgg), keyEquivalent: "")
        yellowEggItem.target = self
        yellowEggItem.state = currentPetType == .yellowEgg ? .on : .off
        menu.addItem(yellowEggItem)
        
        let babyBirdItem = NSMenuItem(title: "Baby Bird", action: #selector(setBabyBird), keyEquivalent: "")
        babyBirdItem.target = self
        babyBirdItem.state = currentPetType == .babyBird ? .on : .off
        menu.addItem(babyBirdItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // About
        let aboutItem = NSMenuItem(title: "❓ About", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Walking stats
        let statsHeader = NSMenuItem(title: "📊 Walking Stats", action: nil, keyEquivalent: "")
        statsHeader.isEnabled = false
        menu.addItem(statsHeader)
        
        let distanceItem = NSMenuItem(title: "Distance: \(getDistanceWalked())", action: #selector(showDistancePopup), keyEquivalent: "")
        distanceItem.target = self
        menu.addItem(distanceItem)
        
        if let startTime = sessionStartTime {
            let sessionDuration = Date().timeIntervalSince(startTime)
            let durationText = String(format: "Session: %.0f min", sessionDuration / 60)
            let durationItem = NSMenuItem(title: durationText, action: nil, keyEquivalent: "")
            durationItem.isEnabled = false
            menu.addItem(durationItem)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "🚪 Quit Kraw", action: #selector(quitApplication), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        return menu
    }
    
    @objc private func startFocusSession() {
        print("Starting focus session...")
        
        // Reset tracking variables
        totalDistanceWalked = 0.0
        sessionStartTime = Date()
        hasTapered = false
        
        // Start with normal mode
        currentEnergyMode = .normal
        
        // Start the cat walking animation by updating the menu bar icon
        startCatWalkingAnimation()
        
        // Start the focus timer
        focusTimer = Timer.scheduledTimer(withTimeInterval: focusDuration, repeats: false) { [weak self] _ in
            self?.focusSessionCompleted()
        }
        
        // Start energy taper after 30 seconds
        energyTaperTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: false) { [weak self] _ in
            self?.taperEnergy()
        }
    }
    
    private func focusSessionCompleted() {
        print("Focus session completed!")
        
        // Stop the cat walking
        stopCatWalkingAnimation()
        
        // Focus session completed - no popup needed
    }
    
    @objc private func startBreak() {
        print("Starting break...")
        
        // Stop the walking animation
        stopCatWalkingAnimation()
        
        let alert = NSAlert()
        alert.messageText = "☕ Kraw's Break Time!"
        alert.informativeText = "Your crow companion is taking a well-earned rest. Enjoy your 5-minute break - Kraw will be ready to patrol again when you return!"
        alert.addButton(withTitle: "Enjoy Break!")
        alert.runModal()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "About Kraw"
        alert.informativeText = "Meet Kraw, your loyal crow companion! He patrols your menu bar during focus sessions, keeping you company while you work. When you focus, Kraw walks. When you rest, Kraw rests.\n\nVersion 1.0 - The Crow Edition"
        alert.addButton(withTitle: "Fly On!")
        alert.runModal()
    }
    
    @objc private func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    // Energy mode controls
    @objc private func setEcoMode() {
        currentEnergyMode = .eco
        print("🌱 Switched to Eco Mode (2.0s interval)")
        updateMenu()
    }
    
    @objc private func setNormalMode() {
        currentEnergyMode = .normal
        print("⚡ Switched to Normal Mode (0.4s interval)")
        updateMenu()
    }
    
    @objc private func setPerformanceMode() {
        currentEnergyMode = .performance
        print("🚀 Switched to Performance Mode (0.2s interval)")
        updateMenu()
    }
    
    // Pet selection controls
    @objc private func setOriginalBird() {
        currentPetType = .original
        print("Switched to Original Kraw")
        updateBirdImage()
        updateMenu()
    }
    
    @objc private func setNewKraw() {
        currentPetType = .newKraw
        print("Switched to New Kraw")
        updateBirdImage()
        updateMenu()
    }
    
    @objc private func setYellowEgg() {
        currentPetType = .yellowEgg
        print("Switched to Yellow Egg")
        updateBirdImage()
        updateMenu()
    }
    
    @objc private func setBabyBird() {
        currentPetType = .babyBird
        print("Switched to Baby Bird")
        updateBirdImage()
        updateMenu()
    }
    
    private func updateBirdImage() {
        // Update the current image to reflect the new bird type
        if let newImage = createCatImage() {
            statusItem?.button?.image = newImage
        }
    }
    
    private func updateMenu() {
        // Recreate menu to update checkmarks
        if let statusItem = statusItem {
            statusItem.menu = createMenu()
        }
    }
    
    private func taperEnergy() {
        if !hasTapered {
            hasTapered = true
            currentEnergyMode = .eco
            print("🌱 Energy tapered to Eco Mode after 30 seconds")
            
            // Restart animation with new energy mode
            if isWalking {
                stopCatWalkingAnimation()
                startCatWalkingAnimation()
            }
        }
    }
    
    private func getDistanceWalked() -> String {
        let distanceKm = totalDistanceWalked * pixelsToKm
        if distanceKm < 1 {
            return String(format: "%.0f pixels", totalDistanceWalked)
        } else {
            return String(format: "%.1f km", distanceKm)
        }
    }
    
    private func checkCityUnlocks() {
        let currentDistanceKm = totalDistanceWalked * pixelsToKm
        
        for route in cityRoutes {
            if !unlockedCities.contains(route.name) && currentDistanceKm >= route.distanceKm {
                unlockedCities.insert(route.name)
                showCityUnlockAlert(route: route)
            }
        }
    }
    
    private func showCityUnlockAlert(route: CityRoute) {
        let alert = NSAlert()
        alert.messageText = "🏆 City Unlocked!"
        alert.informativeText = "\(route.description)\n\nRoute: \(route.name)\nDistance: \(route.distanceKm) km"
        alert.addButton(withTitle: "Amazing!")
        alert.runModal()
    }
    
    @objc private func showDistancePopup() {
        let currentDistanceKm = totalDistanceWalked * pixelsToKm
        let currentDistancePixels = totalDistanceWalked
        
        var message = "Distance Traveled:\n\n"
        message += "Pixels: \(String(format: "%.0f", currentDistancePixels))\n"
        message += "Kilometers: \(String(format: "%.2f", currentDistanceKm))\n\n"
        
        message += "Unlocked Cities (\(unlockedCities.count)/\(cityRoutes.count)):\n"
        if unlockedCities.isEmpty {
            message += "None yet - keep walking!\n\n"
        } else {
            for city in unlockedCities.sorted() {
                message += "✅ \(city)\n"
            }
            message += "\n"
        }
        
        message += "Next City Unlock:\n"
        let nextCity = cityRoutes.first { !unlockedCities.contains($0.name) }
        if let next = nextCity {
            let progress = (currentDistanceKm / next.distanceKm) * 100
            message += "\(next.name) - \(String(format: "%.1f", progress))% complete"
        } else {
            message += "All cities unlocked! 🎉"
        }
        
        let alert = NSAlert()
        alert.messageText = "Distance Stats"
        alert.informativeText = message
        alert.addButton(withTitle: "Keep Walking!")
        alert.runModal()
    }
    
    private func getTimerInterval() -> TimeInterval {
        switch currentEnergyMode {
        case .eco:
            return 2.0 // 80% reduction from 0.4s
        case .normal:
            return 0.4 // Current speed
        case .performance:
            return 0.2 // Faster
        }
    }
    
    private func startCatWalkingAnimation() {
        isWalking = true
        
        // Each pet type has its own animation system
        switch currentPetType {
        case .yellowEgg:
            startEggAnimation()
            return
        case .babyBird:
            startBabyBirdAnimation()
            return
        case .original, .newKraw:
            startWalkingAnimation()
            return
        }
    }
    
    private func startEggAnimation() {
        let timerInterval = getTimerInterval()
        print("Starting egg animation with \(currentEnergyMode) mode (interval: \(timerInterval)s)")
        
        walkingTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isWalking else { return }
            
            // Egg just sits and occasionally wobbles - no movement
            if let eggImage = self.createEggImage() {
                self.statusItem?.button?.image = eggImage
            }
        }
    }
    
    private func startBabyBirdAnimation() {
        let timerInterval = getTimerInterval()
        print("Starting baby bird animation with \(currentEnergyMode) mode (interval: \(timerInterval)s)")
        
        walkingTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isWalking else { return }
            
            // Baby bird stays in place but flaps wings
            if let babyImage = self.createBabyBirdImage() {
                self.statusItem?.button?.image = babyImage
            }
        }
    }
    
    private func startWalkingAnimation() {
        let timerInterval = getTimerInterval()
        print("Starting walking animation with \(currentEnergyMode) mode (interval: \(timerInterval)s)")
        
        walkingTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self, self.isWalking else { return }
            
            // Update walk position - faster movement
            let stepDistance = self.walkDirection * 6.0
            self.walkPosition += stepDistance
            
            // Track total distance walked
            self.totalDistanceWalked += abs(stepDistance)
            
            // Check for city unlocks
            self.checkCityUnlocks()
            
            // Walk within the 6 icon spaces allocated (starts 2 icons to the right)
            if self.walkPosition <= -120.0 { // 5 icons left from start = 5 * 40px = 200px, but start is at 80px, so 80-200 = -120px
                self.walkDirection = 1.0 // Turn around
            } else if self.walkPosition >= 40.0 { // Back to 1 icon right (not 2)
                self.walkDirection = -1.0 // Walk left again
            }
            
            // Load walking animation from GIF
            if let walkingImage = self.createWalkingImage(frameIndex: self.currentFrame, offset: self.walkPosition) {
                self.statusItem?.button?.image = walkingImage
            }
            self.currentFrame += 1
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
        // Choose the correct GIF based on pet type and walking direction
        let gifFile: String
        switch currentPetType {
        case .original:
            // Original Kraw: right crow.gif for left, Left crow.gif for right
            gifFile = walkDirection < 0 ? "/Users/amre/Barfly/KrawMacPet/assets/images/right crow .gif" : "/Users/amre/Barfly/KrawMacPet/assets/images/Left crow.gif"
        case .newKraw:
            // New Kraw: Right_kraw copy.gif for left, Left_Kraw.gif for right
            gifFile = walkDirection < 0 ? "/Users/amre/Barfly/KrawMacPet/assets/images/Right_kraw copy.gif" : "/Users/amre/Barfly/KrawMacPet/assets/images/Left_Kraw.gif"
        case .yellowEgg:
            // Yellow Egg: stays in place, no walking animation
            gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/hd-single-yellow-egg-clipart-transparent-background-735811696682996dk46wnzpqa.png"
        case .babyBird:
            // Baby Bird: stays in place, no walking animation
            gifFile = "/Users/amre/Barfly/KrawMacPet/assets/images/c846ca41824ae2ba3ecab07859dafbec65188d29.gif"
        }
        
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
