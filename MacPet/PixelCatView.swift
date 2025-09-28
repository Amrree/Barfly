import Cocoa

class PixelCatView: NSView {
    
    private var currentFrame = 0
    private var animationTimer: Timer?
    private var walkingTimer: Timer?
    private var isWalking = false
    private var walkDirection: CGFloat = 1.0 // 1 for right, -1 for left
    private var walkPosition: CGFloat = 0.0
    private var maxWalkDistance: CGFloat = 100.0
    
    // Pixel cat frames for walking animation
    private let catFrames = [
        // Frame 1: Cat standing
        [
            "  ████  ",
            " ██████ ",
            "████████",
            "████████",
            " ██████ ",
            "  ████  ",
            "  ████  ",
            "  ████  "
        ],
        // Frame 2: Cat walking right
        [
            "  ████  ",
            " ██████ ",
            "████████",
            "████████",
            " ██████ ",
            "  ████  ",
            " ████   ",
            " ████   "
        ],
        // Frame 3: Cat walking left
        [
            "  ████  ",
            " ██████ ",
            "████████",
            "████████",
            " ██████ ",
            "  ████  ",
            "   ████ ",
            "   ████ "
        ]
    ]
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Set up the view
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Start idle animation
        startIdleAnimation()
    }
    
    func startWalking(duration: TimeInterval) {
        stopWalking()
        isWalking = true
        
        // Start walking animation
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            self?.updateWalkingFrame()
        }
        
        // Start position movement
        walkingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateWalkPosition()
        }
        
        // Stop walking after duration
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.stopWalking()
        }
    }
    
    func stopWalking() {
        isWalking = false
        animationTimer?.invalidate()
        animationTimer = nil
        walkingTimer?.invalidate()
        walkingTimer = nil
        walkPosition = 0.0
        currentFrame = 0
        needsDisplay = true
    }
    
    private func startIdleAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateIdleFrame()
        }
    }
    
    private func updateIdleFrame() {
        if !isWalking {
            currentFrame = (currentFrame + 1) % 2
            needsDisplay = true
        }
    }
    
    private func updateWalkingFrame() {
        if isWalking {
            currentFrame = (currentFrame + 1) % 3
            needsDisplay = true
        }
    }
    
    private func updateWalkPosition() {
        if isWalking {
            walkPosition += walkDirection * 2.0
            
            // Reverse direction when reaching limits
            if walkPosition >= maxWalkDistance {
                walkDirection = -1.0
            } else if walkPosition <= -maxWalkDistance {
                walkDirection = 1.0
            }
            
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Clear the background
        NSColor.clear.setFill()
        dirtyRect.fill()
        
        // Draw the pixel cat
        drawPixelCat()
    }
    
    private func drawPixelCat() {
        let catFrame = catFrames[currentFrame]
        let cellSize: CGFloat = 2.0
        let startX = bounds.midX + walkPosition - (CGFloat(catFrame[0].count) * cellSize / 2)
        let startY = bounds.midY - (CGFloat(catFrame.count) * cellSize / 2)
        
        // Set cat color (orange like the website)
        NSColor.systemOrange.setFill()
        
        for (row, line) in catFrame.enumerated() {
            for (col, char) in line.enumerated() {
                if char == "█" {
                    let rect = NSRect(
                        x: startX + CGFloat(col) * cellSize,
                        y: startY + CGFloat(catFrame.count - 1 - row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    rect.fill()
                }
            }
        }
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 32, height: 32)
    }
}
