import Foundation

struct ActivitySession {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let type: SessionType
    let duration: TimeInterval
    
    enum SessionType {
        case focus
        case `break`
        case longBreak
    }
    
    init(type: SessionType, startTime: Date, endTime: Date) {
        self.id = UUID()
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
    }
}

struct DailyActivity {
    let date: Date
    let totalFocusTime: TimeInterval
    let totalBreakTime: TimeInterval
    let sessionCount: Int
    let streakDays: Int
    
    var formattedFocusTime: String {
        let hours = Int(totalFocusTime) / 3600
        let minutes = Int(totalFocusTime) % 3600 / 60
        return String(format: "%dh %02dm", hours, minutes)
    }
    
    var formattedBreakTime: String {
        let hours = Int(totalBreakTime) / 3600
        let minutes = Int(totalBreakTime) % 3600 / 60
        return String(format: "%dh %02dm", hours, minutes)
    }
}

struct ActivityStats {
    let totalSessions: Int
    let totalFocusTime: TimeInterval
    let totalBreakTime: TimeInterval
    let currentStreak: Int
    let longestStreak: Int
    let averageSessionLength: TimeInterval
    let mostProductiveDay: Date?
    
    var formattedTotalFocusTime: String {
        let hours = Int(totalFocusTime) / 3600
        let minutes = Int(totalFocusTime) % 3600 / 60
        return String(format: "%dh %02dm", hours, minutes)
    }
    
    var formattedAverageSession: String {
        let minutes = Int(averageSessionLength) / 60
        return String(format: "%d min", minutes)
    }
}

class ActivityModel: ObservableObject {
    @Published var sessions: [ActivitySession] = []
    @Published var dailyActivities: [DailyActivity] = []
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let sessionsKey = "MacPet_Sessions"
    private let streakKey = "MacPet_CurrentStreak"
    private let longestStreakKey = "MacPet_LongestStreak"
    
    init() {
        loadData()
        updateDailyActivities()
    }
    
    func addSession(_ session: ActivitySession) {
        sessions.append(session)
        saveSessions()
        updateDailyActivities()
        updateStreaks()
    }
    
    func getTodaysActivity() -> DailyActivity? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyActivities.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    func getWeeklyActivity() -> [DailyActivity] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return dailyActivities.filter { $0.date >= weekStart }
    }
    
    func getActivityStats() -> ActivityStats {
        let totalSessions = sessions.count
        let totalFocusTime = sessions.filter { $0.type == .focus }.reduce(0) { $0 + $1.duration }
        let totalBreakTime = sessions.filter { $0.type == .`break` || $0.type == .longBreak }.reduce(0) { $0 + $1.duration }
        
        let averageSessionLength = totalSessions > 0 ? totalFocusTime / Double(totalSessions) : 0
        
        // Find most productive day
        let mostProductiveDay = dailyActivities.max { $0.totalFocusTime < $1.totalFocusTime }?.date
        
        return ActivityStats(
            totalSessions: totalSessions,
            totalFocusTime: totalFocusTime,
            totalBreakTime: totalBreakTime,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            averageSessionLength: averageSessionLength,
            mostProductiveDay: mostProductiveDay
        )
    }
    
    private func updateDailyActivities() {
        let calendar = Calendar.current
        let groupedSessions = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.startTime)
        }
        
        dailyActivities = groupedSessions.map { date, sessions in
            let focusSessions = sessions.filter { $0.type == .focus }
            let breakSessions = sessions.filter { $0.type == .`break` || $0.type == .longBreak }
            
            let totalFocusTime = focusSessions.reduce(0) { $0 + $1.duration }
            let totalBreakTime = breakSessions.reduce(0) { $0 + $1.duration }
            
            return DailyActivity(
                date: date,
                totalFocusTime: totalFocusTime,
                totalBreakTime: totalBreakTime,
                sessionCount: sessions.count,
                streakDays: 0 // Will be calculated separately
            )
        }.sorted { $0.date > $1.date }
    }
    
    private func updateStreaks() {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var longestStreak = 0
        var currentStreak = 0
        
        // Calculate streaks
        for i in 0..<dailyActivities.count {
            let activity = dailyActivities[i]
            let daysDiff = calendar.dateComponents([.day], from: activity.date, to: today).day ?? 0
            
            if activity.totalFocusTime > 0 {
                if daysDiff == i {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                longestStreak = max(longestStreak, currentStreak)
                currentStreak = 0
            }
        }
        
        longestStreak = max(longestStreak, currentStreak)
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        
        // Save streaks
        userDefaults.set(currentStreak, forKey: streakKey)
        userDefaults.set(longestStreak, forKey: longestStreakKey)
    }
    
    private func saveSessions() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(sessions) {
            userDefaults.set(data, forKey: sessionsKey)
        }
    }
    
    private func loadData() {
        // Load sessions
        if let data = userDefaults.data(forKey: sessionsKey) {
            let decoder = JSONDecoder()
            if let loadedSessions = try? decoder.decode([ActivitySession].self, from: data) {
                sessions = loadedSessions
            }
        }
        
        // Load streaks
        currentStreak = userDefaults.integer(forKey: streakKey)
        longestStreak = userDefaults.integer(forKey: longestStreakKey)
    }
    
    func clearAllData() {
        sessions.removeAll()
        dailyActivities.removeAll()
        currentStreak = 0
        longestStreak = 0
        
        userDefaults.removeObject(forKey: sessionsKey)
        userDefaults.removeObject(forKey: streakKey)
        userDefaults.removeObject(forKey: longestStreakKey)
    }
}

// Make ActivitySession Codable
extension ActivitySession: Codable {
    enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, type, duration
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(duration, forKey: .duration)
        
        let typeString = type == .focus ? "focus" : type == .`break` ? "break" : "longBreak"
        try container.encode(typeString, forKey: .type)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        
        let typeString = try container.decode(String.self, forKey: .type)
        switch typeString {
        case "focus": type = .focus
        case "break": type = .`break`
        case "longBreak": type = .longBreak
        default: type = .focus
        }
    }
}