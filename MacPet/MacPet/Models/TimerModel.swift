import Foundation

enum TimerState {
    case idle
    case focus
    case shortBreak
    case longBreak
}

struct TimerSettings {
    var focusDuration: TimeInterval = 25 * 60 // 25 minutes
    var shortBreakDuration: TimeInterval = 5 * 60 // 5 minutes
    var longBreakDuration: TimeInterval = 15 * 60 // 15 minutes
    var longBreakInterval: Int = 4 // Every 4 focus sessions
    var autoStartBreaks: Bool = true
    var autoStartFocus: Bool = false
    var playSounds: Bool = true
}

class TimerModel: ObservableObject {
    @Published var currentState: TimerState = .idle
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalTime: TimeInterval = 0
    @Published var isRunning: Bool = false
    @Published var focusSessionsCompleted: Int = 0
    
    private var timer: Timer?
    private var settings = TimerSettings()
    
    var progressPercentage: Double {
        guard totalTime > 0 else { return 0 }
        return (totalTime - timeRemaining) / totalTime
    }
    
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedTotalTime: String {
        let minutes = Int(totalTime) / 60
        let seconds = Int(totalTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func startFocusSession() {
        stopTimer()
        currentState = .focus
        totalTime = settings.focusDuration
        timeRemaining = settings.focusDuration
        startTimer()
    }
    
    func startShortBreak() {
        stopTimer()
        currentState = .shortBreak
        totalTime = settings.shortBreakDuration
        timeRemaining = settings.shortBreakDuration
        startTimer()
    }
    
    func startLongBreak() {
        stopTimer()
        currentState = .longBreak
        totalTime = settings.longBreakDuration
        timeRemaining = settings.longBreakDuration
        startTimer()
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resumeTimer() {
        if timeRemaining > 0 {
            startTimer()
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        currentState = .idle
        timeRemaining = 0
        totalTime = 0
    }
    
    private func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        timeRemaining -= 1
        
        if timeRemaining <= 0 {
            timerCompleted()
        }
    }
    
    private func timerCompleted() {
        stopTimer()
        
        switch currentState {
        case .focus:
            focusSessionsCompleted += 1
            handleFocusSessionComplete()
        case .shortBreak, .longBreak:
            handleBreakComplete()
        case .idle:
            break
        }
    }
    
    private func handleFocusSessionComplete() {
        // Show notification
        if settings.playSounds {
            // Play completion sound
            NSSound.beep()
        }
        
        // Determine if it's time for a long break
        if focusSessionsCompleted % settings.longBreakInterval == 0 {
            // Start long break
            if settings.autoStartBreaks {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.startLongBreak()
                }
            }
        } else {
            // Start short break
            if settings.autoStartBreaks {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.startShortBreak()
                }
            }
        }
    }
    
    private func handleBreakComplete() {
        // Show notification
        if settings.playSounds {
            NSSound.beep()
        }
        
        // Auto-start next focus session if enabled
        if settings.autoStartFocus {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startFocusSession()
            }
        }
    }
    
    func updateSettings(_ newSettings: TimerSettings) {
        settings = newSettings
    }
    
    func getSettings() -> TimerSettings {
        return settings
    }
}