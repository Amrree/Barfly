import Cocoa
import UserNotifications

class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        setupNotificationCenter()
    }
    
    private func setupNotificationCenter() {
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Timer Notifications
    
    func showNotification(title: String, body: String, identifier: String, sound: UNNotificationSound = .default) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        
        // Add custom actions if needed
        let categoryIdentifier = "TIMER_CATEGORY"
        
        // Create category with actions
        let focusAction = UNNotificationAction(identifier: "START_FOCUS", title: "Start Focus", options: [])
        let breakAction = UNNotificationAction(identifier: "START_BREAK", title: "Start Break", options: [])
        let dismissAction = UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: [.destructive])
        
        let category = UNNotificationCategory(
            identifier: categoryIdentifier,
            actions: [focusAction, breakAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = categoryIdentifier
        
        // Create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        
        // Add notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to add notification: \(error.localizedDescription)")
            }
        }
    }
    
    func showFocusSessionComplete() {
        showNotification(
            title: "Focus Session Complete! 🎉",
            body: "Great work! Time for a well-deserved break.",
            identifier: "focus_complete",
            sound: .default
        )
    }
    
    func showBreakComplete() {
        showNotification(
            title: "Break Time Over",
            body: "Ready to get back to work?",
            identifier: "break_complete",
            sound: .default
        )
    }
    
    func showFocusSessionStarted(duration: Int) {
        showNotification(
            title: "Focus Session Started",
            body: "Time to focus for \(duration) minutes! 🎯",
            identifier: "focus_started",
            sound: .default
        )
    }
    
    func showBreakStarted(duration: Int) {
        showNotification(
            title: "Break Started",
            body: "Take a \(duration) minute break! ☕",
            identifier: "break_started",
            sound: .default
        )
    }
    
    // MARK: - Achievement Notifications
    
    func showStreakMilestone(days: Int) {
        let emoji = getStreakEmoji(for: days)
        showNotification(
            title: "Streak Milestone! \(emoji)",
            body: "You've maintained a \(days)-day focus streak!",
            identifier: "streak_\(days)",
            sound: .default
        )
    }
    
    func showSessionMilestone(sessions: Int) {
        let emoji = getSessionEmoji(for: sessions)
        showNotification(
            title: "Session Milestone! \(emoji)",
            body: "You've completed \(sessions) focus sessions!",
            identifier: "sessions_\(sessions)",
            sound: .default
        )
    }
    
    func showDailyGoalAchieved() {
        showNotification(
            title: "Daily Goal Achieved! 🏆",
            body: "You've reached your daily focus target!",
            identifier: "daily_goal",
            sound: .default
        )
    }
    
    // MARK: - Pet Notifications
    
    func showPetMessage(message: String) {
        showNotification(
            title: "🐱 Mac Pet",
            body: message,
            identifier: "pet_message_\(Date().timeIntervalSince1970)",
            sound: .default
        )
    }
    
    func showPetHungry() {
        showNotification(
            title: "🐱 Your pet is hungry!",
            body: "Take a break and give your pet some attention!",
            identifier: "pet_hungry",
            sound: .default
        )
    }
    
    func showPetHappy() {
        showNotification(
            title: "🐱 Your pet is happy!",
            body: "Great job staying focused! Your pet loves it!",
            identifier: "pet_happy",
            sound: .default
        )
    }
    
    // MARK: - Helper Methods
    
    private func getStreakEmoji(for days: Int) -> String {
        switch days {
        case 1...2: return "🌱"
        case 3...6: return "🌿"
        case 7...13: return "🌳"
        case 14...29: return "🏆"
        case 30...: return "👑"
        default: return "🎯"
        }
    }
    
    private func getSessionEmoji(for sessions: Int) -> String {
        switch sessions {
        case 1...4: return "🎯"
        case 5...9: return "⭐"
        case 10...19: return "🌟"
        case 20...49: return "💫"
        case 50...99: return "🚀"
        case 100...: return "🎆"
        default: return "🎯"
        }
    }
    
    // MARK: - Scheduled Notifications
    
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🐱 Mac Pet Daily Check-in"
        content.body = "How's your focus going today? Your pet is waiting!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleFocusReminder(afterMinutes: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🐱 Focus Reminder"
        content.body = "It's been a while since your last focus session. Ready to get back to work?"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(afterMinutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "focus_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule focus reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notification Management
    
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func clearNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
    
    func getDeliveredNotifications(completion: @escaping ([UNNotification]) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            completion(notifications)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case "START_FOCUS":
            // Start a new focus session
            NotificationCenter.default.post(name: .startFocusSession, object: nil)
        case "START_BREAK":
            // Start a break
            NotificationCenter.default.post(name: .startBreakSession, object: nil)
        case "DISMISS":
            // Just dismiss the notification
            break
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let startFocusSession = Notification.Name("startFocusSession")
    static let startBreakSession = Notification.Name("startBreakSession")
    static let timerCompleted = Notification.Name("timerCompleted")
    static let petClicked = Notification.Name("petClicked")
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
}