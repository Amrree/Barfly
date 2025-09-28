import Cocoa
import AppKit

class SettingsView: NSView {
    
    private var timerController: TimerController?
    private var petController: PetController?
    private var activityController: ActivityController?
    
    // Timer settings
    private var focusDurationField: NSTextField!
    private var shortBreakField: NSTextField!
    private var longBreakField: NSTextField!
    private var autoStartBreaksCheckbox: NSButton!
    private var playSoundsCheckbox: NSButton!
    
    // Pet settings
    private var petTypePopup: NSPopUpButton!
    private var animationSpeedSlider: NSSlider!
    private var petSizeSlider: NSSlider!
    
    // General settings
    private var startAtLoginCheckbox: NSButton!
    private var showInDockCheckbox: NSButton!
    private var minimizeToMenuBarCheckbox: NSButton!
    
    init(timerController: TimerController, petController: PetController, activityController: ActivityController) {
        self.timerController = timerController
        self.petController = petController
        self.activityController = activityController
        super.init(frame: NSRect(x: 0, y: 0, width: 500, height: 600))
        
        setupUI()
        loadCurrentSettings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        
        setupScrollView()
    }
    
    private func setupScrollView() {
        let scrollView = NSScrollView(frame: bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 800))
        scrollView.documentView = contentView
        addSubview(scrollView)
        
        setupTimerSection(in: contentView)
        setupPetSection(in: contentView)
        setupGeneralSection(in: contentView)
        setupButtons(in: contentView)
    }
    
    private func setupTimerSection(in parentView: NSView) {
        // Timer section title
        let timerTitle = createSectionTitle("Timer Settings", y: 750)
        parentView.addSubview(timerTitle)
        
        // Focus duration
        let focusLabel = createLabel("Focus Duration (minutes):", y: 710)
        parentView.addSubview(focusLabel)
        
        focusDurationField = createTextField(y: 710, x: 200)
        parentView.addSubview(focusDurationField)
        
        // Short break duration
        let shortBreakLabel = createLabel("Short Break (minutes):", y: 680)
        parentView.addSubview(shortBreakLabel)
        
        shortBreakField = createTextField(y: 680, x: 200)
        parentView.addSubview(shortBreakField)
        
        // Long break duration
        let longBreakLabel = createLabel("Long Break (minutes):", y: 650)
        parentView.addSubview(longBreakLabel)
        
        longBreakField = createTextField(y: 650, x: 200)
        parentView.addSubview(longBreakField)
        
        // Auto-start breaks
        autoStartBreaksCheckbox = createCheckbox("Auto-start breaks", y: 620)
        parentView.addSubview(autoStartBreaksCheckbox)
        
        // Play sounds
        playSoundsCheckbox = createCheckbox("Play notification sounds", y: 590)
        parentView.addSubview(playSoundsCheckbox)
    }
    
    private func setupPetSection(in parentView: NSView) {
        // Pet section title
        let petTitle = createSectionTitle("Pet Settings", y: 540)
        parentView.addSubview(petTitle)
        
        // Pet type selection
        let petTypeLabel = createLabel("Pet Type:", y: 500)
        parentView.addSubview(petTypeLabel)
        
        petTypePopup = NSPopUpButton(frame: NSRect(x: 120, y: 500, width: 120, height: 26))
        petTypePopup.addItems(withTitles: PetType.allCases.map { $0.displayName })
        parentView.addSubview(petTypePopup)
        
        // Animation speed
        let speedLabel = createLabel("Animation Speed:", y: 460)
        parentView.addSubview(speedLabel)
        
        animationSpeedSlider = NSSlider(frame: NSRect(x: 120, y: 460, width: 200, height: 20))
        animationSpeedSlider.minValue = 0.5
        animationSpeedSlider.maxValue = 2.0
        animationSpeedSlider.doubleValue = 1.0
        parentView.addSubview(animationSpeedSlider)
        
        let speedValueLabel = createLabel("1.0x", y: 460, x: 330)
        parentView.addSubview(speedValueLabel)
        
        // Pet size
        let sizeLabel = createLabel("Pet Size:", y: 420)
        parentView.addSubview(sizeLabel)
        
        petSizeSlider = NSSlider(frame: NSRect(x: 120, y: 420, width: 200, height: 20))
        petSizeSlider.minValue = 0.8
        petSizeSlider.maxValue = 1.5
        petSizeSlider.doubleValue = 1.0
        parentView.addSubview(petSizeSlider)
        
        let sizeValueLabel = createLabel("100%", y: 420, x: 330)
        parentView.addSubview(sizeValueLabel)
    }
    
    private func setupGeneralSection(in parentView: NSView) {
        // General section title
        let generalTitle = createSectionTitle("General Settings", y: 360)
        parentView.addSubview(generalTitle)
        
        // Start at login
        startAtLoginCheckbox = createCheckbox("Start at login", y: 320)
        parentView.addSubview(startAtLoginCheckbox)
        
        // Show in dock
        showInDockCheckbox = createCheckbox("Show in dock", y: 290)
        parentView.addSubview(showInDockCheckbox)
        
        // Minimize to menu bar
        minimizeToMenuBarCheckbox = createCheckbox("Minimize to menu bar", y: 260)
        parentView.addSubview(minimizeToMenuBarCheckbox)
    }
    
    private func setupButtons(in parentView: NSView) {
        // Save button
        let saveButton = NSButton(title: "Save Settings", target: self, action: #selector(saveSettings))
        saveButton.frame = NSRect(x: 20, y: 20, width: 120, height: 32)
        saveButton.bezelStyle = .rounded
        parentView.addSubview(saveButton)
        
        // Reset button
        let resetButton = NSButton(title: "Reset to Defaults", target: self, action: #selector(resetSettings))
        resetButton.frame = NSRect(x: 150, y: 20, width: 140, height: 32)
        resetButton.bezelStyle = .rounded
        parentView.addSubview(resetButton)
        
        // Cancel button
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelSettings))
        cancelButton.frame = NSRect(x: 300, y: 20, width: 80, height: 32)
        cancelButton.bezelStyle = .rounded
        parentView.addSubview(cancelButton)
    }
    
    // MARK: - Helper Methods
    
    private func createSectionTitle(_ title: String, y: CGFloat) -> NSTextField {
        let label = NSTextField(labelWithString: title)
        label.font = NSFont.boldSystemFont(ofSize: 16)
        label.frame = NSRect(x: 20, y: y, width: 200, height: 25)
        return label
    }
    
    private func createLabel(_ text: String, y: CGFloat, x: CGFloat = 20) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.frame = NSRect(x: x, y: y, width: 150, height: 20)
        return label
    }
    
    private func createTextField(y: CGFloat, x: CGFloat) -> NSTextField {
        let textField = NSTextField()
        textField.frame = NSRect(x: x, y: y, width: 60, height: 22)
        textField.isEditable = true
        textField.isBordered = true
        return textField
    }
    
    private func createCheckbox(_ title: String, y: CGFloat) -> NSButton {
        let checkbox = NSButton(checkboxWithTitle: title, target: nil, action: nil)
        checkbox.frame = NSRect(x: 20, y: y, width: 200, height: 20)
        return checkbox
    }
    
    private func loadCurrentSettings() {
        let settings = timerController?.getSettings() ?? TimerSettings()
        
        // Load timer settings
        focusDurationField.stringValue = "\(Int(settings.focusDuration / 60))"
        shortBreakField.stringValue = "\(Int(settings.shortBreakDuration / 60))"
        longBreakField.stringValue = "\(Int(settings.longBreakDuration / 60))"
        autoStartBreaksCheckbox.state = settings.autoStartBreaks ? .on : .off
        playSoundsCheckbox.state = settings.playSounds ? .on : .off
        
        // Load general settings
        startAtLoginCheckbox.state = isStartAtLoginEnabled() ? .on : .off
        showInDockCheckbox.state = isShowInDockEnabled() ? .on : .off
        minimizeToMenuBarCheckbox.state = .on // Default to true
    }
    
    private func isStartAtLoginEnabled() -> Bool {
        // Check if app is set to start at login
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.macpet.app"
        let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)
        
        guard let loginItems = loginItems?.takeRetainedValue() else { return false }
        
        let loginItemsArray = LSSharedFileListCopySnapshot(loginItems, nil)
        guard let loginItemsArray = loginItemsArray else { return false }
        
        for item in loginItemsArray.takeRetainedValue() as! [LSSharedFileListItem] {
            if let itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?.takeRetainedValue() {
                if (itemURL as URL).path.contains(bundleIdentifier) {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func isShowInDockEnabled() -> Bool {
        return NSApp.activationPolicy() == .regular
    }
    
    // MARK: - Actions
    
    @objc private func saveSettings() {
        // Save timer settings
        let focusMinutes = Int(focusDurationField.stringValue) ?? 25
        let shortBreakMinutes = Int(shortBreakField.stringValue) ?? 5
        let longBreakMinutes = Int(longBreakField.stringValue) ?? 15
        
        var newSettings = TimerSettings()
        newSettings.focusDuration = TimeInterval(focusMinutes * 60)
        newSettings.shortBreakDuration = TimeInterval(shortBreakMinutes * 60)
        newSettings.longBreakDuration = TimeInterval(longBreakMinutes * 60)
        newSettings.autoStartBreaks = autoStartBreaksCheckbox.state == .on
        newSettings.playSounds = playSoundsCheckbox.state == .on
        
        timerController?.updateSettings(newSettings)
        
        // Save pet settings
        let selectedPetType = PetType.allCases[petTypePopup.indexOfSelectedItem]
        petController?.changePet(to: selectedPetType)
        
        // Save general settings
        if startAtLoginCheckbox.state == .on {
            setStartAtLogin(true)
        } else {
            setStartAtLogin(false)
        }
        
        if showInDockCheckbox.state == .on {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
        
        // Close settings window
        window?.close()
    }
    
    @objc private func resetSettings() {
        let alert = NSAlert()
        alert.messageText = "Reset Settings"
        alert.informativeText = "Are you sure you want to reset all settings to their default values?"
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            resetToDefaults()
        }
    }
    
    @objc private func cancelSettings() {
        window?.close()
    }
    
    private func resetToDefaults() {
        // Reset timer settings
        focusDurationField.stringValue = "25"
        shortBreakField.stringValue = "5"
        longBreakField.stringValue = "15"
        autoStartBreaksCheckbox.state = .on
        playSoundsCheckbox.state = .on
        
        // Reset pet settings
        petTypePopup.selectItem(at: 0) // Cat
        animationSpeedSlider.doubleValue = 1.0
        petSizeSlider.doubleValue = 1.0
        
        // Reset general settings
        startAtLoginCheckbox.state = .off
        showInDockCheckbox.state = .off
        minimizeToMenuBarCheckbox.state = .on
    }
    
    private func setStartAtLogin(_ enabled: Bool) {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.macpet.app"
        let loginItems = LSSharedFileListCreate(nil, kLSSharedFileListSessionLoginItems.takeRetainedValue(), nil)
        
        guard let loginItems = loginItems?.takeRetainedValue() else { return }
        
        if enabled {
            // Add to login items
            if let appURL = NSURL.fileURL(withPath: Bundle.main.bundlePath) as CFURL? {
                LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemBeforeFirst.takeRetainedValue(), nil, nil, appURL, nil, nil)
            }
        } else {
            // Remove from login items
            let loginItemsArray = LSSharedFileListCopySnapshot(loginItems, nil)
            guard let loginItemsArray = loginItemsArray else { return }
            
            for item in loginItemsArray.takeRetainedValue() as! [LSSharedFileListItem] {
                if let itemURL = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?.takeRetainedValue() {
                    if (itemURL as URL).path.contains(bundleIdentifier) {
                        LSSharedFileListItemRemove(loginItems, item)
                    }
                }
            }
        }
    }
}