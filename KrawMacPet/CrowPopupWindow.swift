import Cocoa

class CrowPopupWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless], backing: backingStoreType, defer: flag)
        
        // Make it a floating window
        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
        
        // Center the window
        self.center()
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}

class CrowPopupView: NSView {
    
    private var titleLabel: NSTextField!
    private var messageLabel: NSTextField!
    private var actionButton: NSButton!
    private var crowImageView: NSImageView!
    
    var onAction: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Create the main container with dark theme
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.95).cgColor
        self.layer?.cornerRadius = 12
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
        
        // Create title label
        titleLabel = NSTextField(labelWithString: "🐦 Kraw Takes Flight!")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = NSColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0)
        titleLabel.alignment = .center
        titleLabel.backgroundColor = NSColor.clear
        titleLabel.isBordered = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        addSubview(titleLabel)
        
        // Create message label
        messageLabel = NSTextField(labelWithString: "Your crow companion will patrol the menu bar while you focus. Watch him walk back and forth - he's keeping you company during your 25-minute work session!")
        messageLabel.font = NSFont.systemFont(ofSize: 12)
        messageLabel.textColor = NSColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0)
        messageLabel.alignment = .center
        messageLabel.backgroundColor = NSColor.clear
        messageLabel.isBordered = false
        messageLabel.isEditable = false
        messageLabel.isSelectable = false
        messageLabel.maximumNumberOfLines = 0
        addSubview(messageLabel)
        
        // Create action button
        actionButton = NSButton(title: "Let's Focus!", target: self, action: #selector(actionButtonClicked))
        actionButton.wantsLayer = true
        actionButton.layer?.backgroundColor = NSColor(red: 0.2, green: 0.3, blue: 0.1, alpha: 1.0).cgColor
        actionButton.layer?.cornerRadius = 6
        actionButton.layer?.borderWidth = 1
        actionButton.layer?.borderColor = NSColor(red: 0.4, green: 0.5, blue: 0.3, alpha: 1.0).cgColor
        actionButton.font = NSFont.boldSystemFont(ofSize: 14)
        actionButton.contentTintColor = NSColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0)
        addSubview(actionButton)
        
        // Create crow image view
        crowImageView = NSImageView()
        crowImageView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(crowImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        crowImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Title label
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            // Message label
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            // Action button
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 15),
            actionButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 100),
            actionButton.heightAnchor.constraint(equalToConstant: 30),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            
            // Crow image
            crowImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            crowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            crowImageView.widthAnchor.constraint(equalToConstant: 32),
            crowImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func configure(title: String, message: String, buttonTitle: String, crowImage: NSImage?) {
        titleLabel.stringValue = title
        messageLabel.stringValue = message
        actionButton.title = buttonTitle
        crowImageView.image = crowImage
    }
    
    @objc private func actionButtonClicked() {
        DispatchQueue.main.async { [weak self] in
            self?.onAction?()
        }
    }
}

class CrowPopupManager {
    static let shared = CrowPopupManager()
    private var currentWindow: CrowPopupWindow?
    
    private init() {}
    
    func showPopup(title: String, message: String, buttonTitle: String, crowImage: NSImage?, onAction: @escaping () -> Void) {
        // Close any existing popup
        closePopup()
        
        // Create new popup window - much smaller
        let window = CrowPopupWindow(contentRect: NSRect(x: 0, y: 0, width: 280, height: 140), 
                                   styleMask: [.borderless], 
                                   backing: .buffered, 
                                   defer: false)
        
        let popupView = CrowPopupView(frame: window.contentView!.bounds)
        popupView.configure(title: title, message: message, buttonTitle: buttonTitle, crowImage: crowImage)
        popupView.onAction = { [weak self] in
            onAction()
            self?.closePopup()
        }
        
        window.contentView = popupView
        window.makeKeyAndOrderFront(nil)
        
        currentWindow = window
        
        // Auto-close after 8 seconds if no action
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            self?.closePopup()
        }
    }
    
    func closePopup() {
        DispatchQueue.main.async { [weak self] in
            self?.currentWindow?.close()
            self?.currentWindow = nil
        }
    }
}