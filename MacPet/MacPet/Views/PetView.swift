import Cocoa
import AppKit

class PetView: NSView {
    
    private let petModel: PetModel
    private var currentImage: NSImage?
    private let imageView = NSImageView()
    
    init(petModel: PetModel) {
        self.petModel = petModel
        super.init(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Set up the image view
        imageView.frame = bounds
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageAlignment = .alignCenter
        addSubview(imageView)
        
        // Set initial frame
        if let animation = petModel.getAnimation(for: petModel.currentState),
           let firstFrame = animation.frames.first {
            updateFrame(firstFrame)
        }
        
        // Add click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(clickGesture)
    }
    
    func updateFrame(_ image: NSImage) {
        currentImage = image
        imageView.image = image
        
        // Update the view's intrinsic content size
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 20, height: 20)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Draw the pet image
        if let image = currentImage {
            let imageRect = NSRect(x: 2, y: 2, width: 16, height: 16)
            image.draw(in: imageRect)
        }
    }
    
    @objc private func handleClick() {
        // Play a meow sound or show excitement
        petModel.setState(.excited)
        
        // Show a brief tooltip
        showTooltip("Meow! 🐱")
        
        // Post notification for pet interaction
        NotificationCenter.default.post(name: .petClicked, object: nil)
    }
    
    private func showTooltip(_ message: String) {
        let tooltip = NSTooltip(message: message)
        tooltip.show(at: NSEvent.mouseLocation)
    }
}

// Custom tooltip class for showing pet messages
class NSTooltip: NSWindow {
    
    private let messageLabel = NSTextField()
    
    init(message: String) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 100, height: 30),
                  styleMask: [.borderless],
                  backing: .buffered,
                  defer: false)
        
        setupTooltip(message: message)
    }
    
    private func setupTooltip(message: String) {
        // Configure window
        level = .floating
        isOpaque = false
        backgroundColor = NSColor.clear
        hasShadow = true
        
        // Create content view
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        contentView.layer?.cornerRadius = 8
        contentView.layer?.borderWidth = 1
        contentView.layer?.borderColor = NSColor.separatorColor.cgColor
        
        // Configure message label
        messageLabel.stringValue = message
        messageLabel.isEditable = false
        messageLabel.isBordered = false
        messageLabel.backgroundColor = NSColor.clear
        messageLabel.font = NSFont.systemFont(ofSize: 12)
        messageLabel.textColor = NSColor.controlTextColor
        messageLabel.alignment = .center
        
        messageLabel.frame = NSRect(x: 8, y: 6, width: 84, height: 18)
        contentView.addSubview(messageLabel)
        
        contentView = contentView
        
        // Auto-hide after 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] in
            self?.close()
        }
    }
    
    func show(at location: NSPoint) {
        // Position the tooltip near the mouse location
        let adjustedLocation = NSPoint(x: location.x - 50, y: location.y + 20)
        setFrameOrigin(adjustedLocation)
        
        // Show the window
        makeKeyAndOrderFront(nil)
        
        // Fade in animation
        alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 1.0
        }
    }
    
    override func close() {
        // Fade out animation before closing
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            self.animator().alphaValue = 0.0
        } completionHandler: {
            super.close()
        }
    }
}