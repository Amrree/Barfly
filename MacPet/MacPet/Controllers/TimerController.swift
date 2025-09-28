import Cocoa
import AppKit

class TimerController: NSObject {
    
    let timerModel = TimerModel()
    private var notificationManager: NotificationManager?
    
    override init() {
        super.init()
        setupNotificationManager()
    }
    
    private func setupNotificationManager() {
        notificationManager = NotificationManager()
    }
    
    func startFocusSession() {
        timerModel.startFocusSession()
        notificationManager?.showNotification(
            title: "Focus Session Started",
            body: "Time to focus for \(Int(timerModel.getSettings().focusDuration / 60)) minutes!",
            identifier: "focus_started"
        )
    }
    
    func startBreak() {
        timerModel.startShortBreak()
        notificationManager?.showNotification(
            title: "Break Started",
            body: "Take a \(Int(timerModel.getSettings().shortBreakDuration / 60)) minute break!",
            identifier: "break_started"
        )
    }
    
    func pauseTimer() {
        timerModel.pauseTimer()
    }
    
    func resumeTimer() {
        timerModel.resumeTimer()
    }
    
    func stopTimer() {
        timerModel.stopTimer()
    }
    
    func getCurrentState() -> TimerState {
        return timerModel.currentState
    }
    
    func getTimeRemaining() -> String {
        return timerModel.formattedTimeRemaining
    }
    
    func getProgress() -> Double {
        return timerModel.progressPercentage
    }
    
    func getFocusSessionsCompleted() -> Int {
        return timerModel.focusSessionsCompleted
    }
    
    func updateSettings(_ settings: TimerSettings) {
        timerModel.updateSettings(settings)
    }
    
    func getSettings() -> TimerSettings {
        return timerModel.getSettings()
    }
}

// MARK: - Timer Settings Window

class TimerSettingsWindow: NSWindowController {
    
    private let timerController: TimerController
    private var settingsView: TimerSettingsView?
    
    init(timerController: TimerController) {
        self.timerController = timerController
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Timer Settings"
        window.center()
        
        super.init(window: window)
        
        setupSettingsView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSettingsView() {
        settingsView = TimerSettingsView(timerController: timerController)
        window?.contentView = settingsView
    }
    
    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Timer Settings View

class TimerSettingsView: NSView {
    
    private let timerController: TimerController
    private var focusDurationField: NSTextField!
    private var shortBreakField: NSTextField!
    private var longBreakField: NSTextField!
    private var autoStartBreaksCheckbox: NSButton!
    private var playSoundsCheckbox: NSButton!
    
    init(timerController: TimerController) {
        self.timerController = timerController
        super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        
        setupUI()
        loadCurrentSettings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let settings = timerController.getSettings()
        
        // Focus Duration
        let focusLabel = NSTextField(labelWithString: "Focus Duration (minutes):")
        focusLabel.frame = NSRect(x: 20, y: 250, width: 150, height: 20)
        addSubview(focusLabel)
        
        focusDurationField = NSTextField()
        focusDurationField.frame = NSRect(x: 180, y: 250, width: 60, height: 22)
        focusDurationField.stringValue = "\(Int(settings.focusDuration / 60))"
        addSubview(focusDurationField)
        
        // Short Break Duration
        let shortBreakLabel = NSTextField(labelWithString: "Short Break (minutes):")
        shortBreakLabel.frame = NSRect(x: 20, y: 220, width: 150, height: 20)
        addSubview(shortBreakLabel)
        
        shortBreakField = NSTextField()
        shortBreakField.frame = NSRect(x: 180, y: 220, width: 60, height: 22)
        shortBreakField.stringValue = "\(Int(settings.shortBreakDuration / 60))"
        addSubview(shortBreakField)
        
        // Long Break Duration
        let longBreakLabel = NSTextField(labelWithString: "Long Break (minutes):")
        longBreakLabel.frame = NSRect(x: 20, y: 190, width: 150, height: 20)
        addSubview(longBreakLabel)
        
        longBreakField = NSTextField()
        longBreakField.frame = NSRect(x: 180, y: 190, width: 60, height: 22)
        longBreakField.stringValue = "\(Int(settings.longBreakDuration / 60))"
        addSubview(longBreakField)
        
        // Auto-start breaks checkbox
        autoStartBreaksCheckbox = NSButton(checkboxWithTitle: "Auto-start breaks", target: self, action: #selector(autoStartBreaksChanged))
        autoStartBreaksCheckbox.frame = NSRect(x: 20, y: 150, width: 200, height: 20)
        autoStartBreaksCheckbox.state = settings.autoStartBreaks ? .on : .off
        addSubview(autoStartBreaksCheckbox)
        
        // Play sounds checkbox
        playSoundsCheckbox = NSButton(checkboxWithTitle: "Play notification sounds", target: self, action: #selector(playSoundsChanged))
        playSoundsCheckbox.frame = NSRect(x: 20, y: 120, width: 200, height: 20)
        playSoundsCheckbox.state = settings.playSounds ? .on : .off
        addSubview(playSoundsCheckbox)
        
        // Save button
        let saveButton = NSButton(title: "Save Settings", target: self, action: #selector(saveSettings))
        saveButton.frame = NSRect(x: 20, y: 20, width: 100, height: 32)
        saveButton.bezelStyle = .rounded
        addSubview(saveButton)
        
        // Cancel button
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelSettings))
        cancelButton.frame = NSRect(x: 130, y: 20, width: 100, height: 32)
        cancelButton.bezelStyle = .rounded
        addSubview(cancelButton)
    }
    
    private func loadCurrentSettings() {
        let settings = timerController.getSettings()
        focusDurationField.stringValue = "\(Int(settings.focusDuration / 60))"
        shortBreakField.stringValue = "\(Int(settings.shortBreakDuration / 60))"
        longBreakField.stringValue = "\(Int(settings.longBreakDuration / 60))"
        autoStartBreaksCheckbox.state = settings.autoStartBreaks ? .on : .off
        playSoundsCheckbox.state = settings.playSounds ? .on : .off
    }
    
    @objc private func autoStartBreaksChanged() {
        // Handle checkbox change
    }
    
    @objc private func playSoundsChanged() {
        // Handle checkbox change
    }
    
    @objc private func saveSettings() {
        let focusMinutes = Int(focusDurationField.stringValue) ?? 25
        let shortBreakMinutes = Int(shortBreakField.stringValue) ?? 5
        let longBreakMinutes = Int(longBreakField.stringValue) ?? 15
        
        var newSettings = TimerSettings()
        newSettings.focusDuration = TimeInterval(focusMinutes * 60)
        newSettings.shortBreakDuration = TimeInterval(shortBreakMinutes * 60)
        newSettings.longBreakDuration = TimeInterval(longBreakMinutes * 60)
        newSettings.autoStartBreaks = autoStartBreaksCheckbox.state == .on
        newSettings.playSounds = playSoundsCheckbox.state == .on
        
        timerController.updateSettings(newSettings)
        
        // Close the window
        window?.close()
    }
    
    @objc private func cancelSettings() {
        window?.close()
    }
}