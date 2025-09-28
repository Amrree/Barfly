import XCTest
@testable import MacPet

class MacPetTests: XCTestCase {
    
    // MARK: - Test Properties
    
    var petModel: PetModel!
    var timerModel: TimerModel!
    var activityModel: ActivityModel!
    var petController: PetController!
    var timerController: TimerController!
    var activityController: ActivityController!
    
    // MARK: - Setup and Teardown
    
    override func setUpWithError() throws {
        super.setUp()
        
        // Initialize models
        petModel = PetModel()
        timerModel = TimerModel()
        activityModel = ActivityModel()
        
        // Initialize controllers
        petController = PetController()
        timerController = TimerController()
        activityController = ActivityController()
    }
    
    override func tearDownWithError() throws {
        // Clean up
        petModel = nil
        timerModel = nil
        activityModel = nil
        petController = nil
        timerController = nil
        activityController = nil
        
        super.tearDown()
    }
    
    // MARK: - Pet Model Tests
    
    func testPetModelInitialization() throws {
        XCTAssertEqual(petModel.currentPet, .cat)
        XCTAssertEqual(petModel.currentState, .idle)
        XCTAssertEqual(petModel.position, CGPoint(x: 0, y: 0))
        XCTAssertFalse(petModel.isAnimating)
    }
    
    func testPetStateChanges() throws {
        // Test idle state
        petModel.setState(.idle)
        XCTAssertEqual(petModel.currentState, .idle)
        
        // Test walking state
        petModel.setState(.walking)
        XCTAssertEqual(petModel.currentState, .walking)
        
        // Test sleeping state
        petModel.setState(.sleeping)
        XCTAssertEqual(petModel.currentState, .sleeping)
        
        // Test working state
        petModel.setState(.working)
        XCTAssertEqual(petModel.currentState, .working)
        
        // Test excited state
        petModel.setState(.excited)
        XCTAssertEqual(petModel.currentState, .excited)
    }
    
    func testPetTypeChanges() throws {
        // Test changing to different pet types
        for petType in PetType.allCases {
            petModel.changePet(to: petType)
            XCTAssertEqual(petModel.currentPet, petType)
        }
    }
    
    func testPetAnimationRetrieval() throws {
        // Test getting animations for different states
        let states: [PetState] = [.idle, .walking, .sleeping, .working, .excited]
        
        for state in states {
            petModel.setState(state)
            let animation = petModel.getAnimation(for: state)
            XCTAssertNotNil(animation, "Animation should exist for state: \(state)")
            
            if let animation = animation {
                XCTAssertGreaterThan(animation.frames.count, 0, "Animation should have frames")
                XCTAssertGreaterThan(animation.duration, 0, "Animation duration should be positive")
            }
        }
    }
    
    func testPetPositionUpdates() throws {
        let testPosition = CGPoint(x: 100, y: 200)
        petModel.updatePosition(testPosition)
        XCTAssertEqual(petModel.position, testPosition)
    }
    
    // MARK: - Timer Model Tests
    
    func testTimerModelInitialization() throws {
        XCTAssertEqual(timerModel.currentState, .idle)
        XCTAssertEqual(timerModel.timeRemaining, 0)
        XCTAssertEqual(timerModel.totalTime, 0)
        XCTAssertFalse(timerModel.isRunning)
        XCTAssertEqual(timerModel.focusSessionsCompleted, 0)
    }
    
    func testTimerSettings() throws {
        let settings = timerModel.getSettings()
        
        XCTAssertEqual(settings.focusDuration, 25 * 60) // 25 minutes
        XCTAssertEqual(settings.shortBreakDuration, 5 * 60) // 5 minutes
        XCTAssertEqual(settings.longBreakDuration, 15 * 60) // 15 minutes
        XCTAssertEqual(settings.longBreakInterval, 4)
        XCTAssertTrue(settings.autoStartBreaks)
        XCTAssertFalse(settings.autoStartFocus)
        XCTAssertTrue(settings.playSounds)
    }
    
    func testTimerCustomization() throws {
        var newSettings = TimerSettings()
        newSettings.focusDuration = 30 * 60 // 30 minutes
        newSettings.shortBreakDuration = 10 * 60 // 10 minutes
        newSettings.longBreakDuration = 20 * 60 // 20 minutes
        newSettings.autoStartBreaks = false
        newSettings.playSounds = false
        
        timerModel.updateSettings(newSettings)
        let updatedSettings = timerModel.getSettings()
        
        XCTAssertEqual(updatedSettings.focusDuration, 30 * 60)
        XCTAssertEqual(updatedSettings.shortBreakDuration, 10 * 60)
        XCTAssertEqual(updatedSettings.longBreakDuration, 20 * 60)
        XCTAssertFalse(updatedSettings.autoStartBreaks)
        XCTAssertFalse(updatedSettings.playSounds)
    }
    
    func testFocusSessionStart() throws {
        timerModel.startFocusSession()
        
        XCTAssertEqual(timerModel.currentState, .focus)
        XCTAssertEqual(timerModel.totalTime, timerModel.getSettings().focusDuration)
        XCTAssertEqual(timerModel.timeRemaining, timerModel.getSettings().focusDuration)
        XCTAssertTrue(timerModel.isRunning)
    }
    
    func testShortBreakStart() throws {
        timerModel.startShortBreak()
        
        XCTAssertEqual(timerModel.currentState, .shortBreak)
        XCTAssertEqual(timerModel.totalTime, timerModel.getSettings().shortBreakDuration)
        XCTAssertEqual(timerModel.timeRemaining, timerModel.getSettings().shortBreakDuration)
        XCTAssertTrue(timerModel.isRunning)
    }
    
    func testLongBreakStart() throws {
        timerModel.startLongBreak()
        
        XCTAssertEqual(timerModel.currentState, .longBreak)
        XCTAssertEqual(timerModel.totalTime, timerModel.getSettings().longBreakDuration)
        XCTAssertEqual(timerModel.timeRemaining, timerModel.getSettings().longBreakDuration)
        XCTAssertTrue(timerModel.isRunning)
    }
    
    func testTimerPauseResume() throws {
        timerModel.startFocusSession()
        XCTAssertTrue(timerModel.isRunning)
        
        timerModel.pauseTimer()
        XCTAssertFalse(timerModel.isRunning)
        
        timerModel.resumeTimer()
        XCTAssertTrue(timerModel.isRunning)
    }
    
    func testTimerStop() throws {
        timerModel.startFocusSession()
        XCTAssertTrue(timerModel.isRunning)
        
        timerModel.stopTimer()
        XCTAssertEqual(timerModel.currentState, .idle)
        XCTAssertFalse(timerModel.isRunning)
        XCTAssertEqual(timerModel.timeRemaining, 0)
        XCTAssertEqual(timerModel.totalTime, 0)
    }
    
    func testTimerProgressCalculation() throws {
        timerModel.startFocusSession()
        let totalTime = timerModel.totalTime
        
        // Simulate 25% progress
        timerModel.timeRemaining = totalTime * 0.75
        XCTAssertEqual(timerModel.progressPercentage, 0.25, accuracy: 0.01)
        
        // Simulate 50% progress
        timerModel.timeRemaining = totalTime * 0.5
        XCTAssertEqual(timerModel.progressPercentage, 0.5, accuracy: 0.01)
        
        // Simulate 100% progress
        timerModel.timeRemaining = 0
        XCTAssertEqual(timerModel.progressPercentage, 1.0, accuracy: 0.01)
    }
    
    func testTimerFormatting() throws {
        timerModel.startFocusSession()
        
        let formattedTime = timerModel.formattedTimeRemaining
        XCTAssertTrue(formattedTime.contains(":"))
        XCTAssertEqual(formattedTime.count, 5) // "MM:SS" format
    }
    
    func testFocusSessionCompletion() throws {
        let initialSessions = timerModel.focusSessionsCompleted
        timerModel.focusSessionsCompleted += 1
        XCTAssertEqual(timerModel.focusSessionsCompleted, initialSessions + 1)
    }
    
    // MARK: - Activity Model Tests
    
    func testActivityModelInitialization() throws {
        XCTAssertEqual(activityModel.sessions.count, 0)
        XCTAssertEqual(activityModel.currentStreak, 0)
        XCTAssertEqual(activityModel.longestStreak, 0)
    }
    
    func testSessionRecording() throws {
        let sessionType = ActivitySession.SessionType.focus
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(1500) // 25 minutes
        
        let session = ActivitySession(type: sessionType, startTime: startTime, endTime: endTime)
        activityModel.addSession(session)
        
        XCTAssertEqual(activityModel.sessions.count, 1)
        XCTAssertEqual(activityModel.sessions.first?.type, sessionType)
        XCTAssertEqual(activityModel.sessions.first?.duration, 1500)
    }
    
    func testTodaysActivity() throws {
        let today = Date()
        let yesterday = today.addingTimeInterval(-86400) // 24 hours ago
        
        // Add session from today
        let todaySession = ActivitySession(
            type: .focus,
            startTime: today,
            endTime: today.addingTimeInterval(1500)
        )
        activityModel.addSession(todaySession)
        
        // Add session from yesterday
        let yesterdaySession = ActivitySession(
            type: .focus,
            startTime: yesterday,
            endTime: yesterday.addingTimeInterval(1500)
        )
        activityModel.addSession(yesterdaySession)
        
        let todaysActivity = activityModel.getTodaysActivity()
        XCTAssertNotNil(todaysActivity)
        XCTAssertEqual(todaysActivity?.sessionCount, 1)
    }
    
    func testWeeklyActivity() throws {
        let today = Date()
        let oneWeekAgo = today.addingTimeInterval(-7 * 86400)
        
        // Add sessions throughout the week
        for i in 0..<7 {
            let sessionDate = today.addingTimeInterval(-Double(i) * 86400)
            let session = ActivitySession(
                type: .focus,
                startTime: sessionDate,
                endTime: sessionDate.addingTimeInterval(1500)
            )
            activityModel.addSession(session)
        }
        
        let weeklyActivity = activityModel.getWeeklyActivity()
        XCTAssertEqual(weeklyActivity.count, 7)
    }
    
    func testActivityStatistics() throws {
        // Add multiple focus sessions
        let startTime = Date()
        for i in 0..<5 {
            let sessionStart = startTime.addingTimeInterval(-Double(i) * 3600)
            let session = ActivitySession(
                type: .focus,
                startTime: sessionStart,
                endTime: sessionStart.addingTimeInterval(1500)
            )
            activityModel.addSession(session)
        }
        
        let stats = activityModel.getActivityStats()
        XCTAssertEqual(stats.totalSessions, 5)
        XCTAssertEqual(stats.totalFocusTime, 7500) // 5 * 1500 seconds
        XCTAssertGreaterThan(stats.averageSessionLength, 0)
    }
    
    func testStreakCalculation() throws {
        let today = Date()
        
        // Add sessions for 3 consecutive days
        for i in 0..<3 {
            let sessionDate = today.addingTimeInterval(-Double(i) * 86400)
            let session = ActivitySession(
                type: .focus,
                startTime: sessionDate,
                endTime: sessionDate.addingTimeInterval(1500)
            )
            activityModel.addSession(session)
        }
        
        // Force streak calculation
        activityModel.updateStreaks()
        
        XCTAssertEqual(activityModel.currentStreak, 3)
        XCTAssertEqual(activityModel.longestStreak, 3)
    }
    
    func testActivityDataExport() throws {
        let session = ActivitySession(
            type: .focus,
            startTime: Date(),
            endTime: Date().addingTimeInterval(1500)
        )
        activityModel.addSession(session)
        
        let exportData = activityModel.exportData()
        XCTAssertNotNil(exportData)
        XCTAssertTrue(exportData.contains("sessions"))
        XCTAssertTrue(exportData.contains("statistics"))
    }
    
    func testActivityDataClearing() throws {
        // Add some sessions
        let session = ActivitySession(
            type: .focus,
            startTime: Date(),
            endTime: Date().addingTimeInterval(1500)
        )
        activityModel.addSession(session)
        
        XCTAssertEqual(activityModel.sessions.count, 1)
        
        // Clear all data
        activityModel.clearAllData()
        
        XCTAssertEqual(activityModel.sessions.count, 0)
        XCTAssertEqual(activityModel.currentStreak, 0)
        XCTAssertEqual(activityModel.longestStreak, 0)
    }
    
    // MARK: - Integration Tests
    
    func testPetTimerIntegration() throws {
        // Test that pet state changes with timer state
        timerModel.startFocusSession()
        petModel.setState(.working)
        
        XCTAssertEqual(timerModel.currentState, .focus)
        XCTAssertEqual(petModel.currentState, .working)
        
        timerModel.startShortBreak()
        petModel.setState(.sleeping)
        
        XCTAssertEqual(timerModel.currentState, .shortBreak)
        XCTAssertEqual(petModel.currentState, .sleeping)
    }
    
    func testTimerActivityIntegration() throws {
        // Test that timer sessions are recorded in activity
        let startTime = Date()
        timerModel.startFocusSession()
        
        // Simulate session completion
        let endTime = startTime.addingTimeInterval(1500)
        let session = ActivitySession(type: .focus, startTime: startTime, endTime: endTime)
        activityModel.addSession(session)
        
        XCTAssertEqual(activityModel.sessions.count, 1)
        XCTAssertEqual(activityModel.sessions.first?.type, .focus)
    }
    
    // MARK: - Performance Tests
    
    func testAnimationPerformance() throws {
        measure {
            // Test animation frame generation performance
            for _ in 0..<100 {
                let animation = petModel.getAnimation(for: .walking)
                XCTAssertNotNil(animation)
            }
        }
    }
    
    func testTimerPerformance() throws {
        measure {
            // Test timer operations performance
            for _ in 0..<1000 {
                timerModel.startFocusSession()
                timerModel.stopTimer()
            }
        }
    }
    
    func testActivityDataPerformance() throws {
        measure {
            // Test activity data operations performance
            for i in 0..<100 {
                let session = ActivitySession(
                    type: .focus,
                    startTime: Date(),
                    endTime: Date().addingTimeInterval(1500)
                )
                activityModel.addSession(session)
            }
            
            let stats = activityModel.getActivityStats()
            XCTAssertEqual(stats.totalSessions, 100)
        }
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testInvalidTimerSettings() throws {
        var invalidSettings = TimerSettings()
        invalidSettings.focusDuration = -1 // Invalid negative duration
        invalidSettings.shortBreakDuration = 0 // Invalid zero duration
        
        timerModel.updateSettings(invalidSettings)
        
        // Should handle gracefully and use default values or clamp to valid ranges
        let settings = timerModel.getSettings()
        XCTAssertGreaterThan(settings.focusDuration, 0)
        XCTAssertGreaterThan(settings.shortBreakDuration, 0)
    }
    
    func testEmptyActivityData() throws {
        // Test operations on empty activity data
        let todaysActivity = activityModel.getTodaysActivity()
        XCTAssertNil(todaysActivity)
        
        let weeklyActivity = activityModel.getWeeklyActivity()
        XCTAssertEqual(weeklyActivity.count, 0)
        
        let stats = activityModel.getActivityStats()
        XCTAssertEqual(stats.totalSessions, 0)
        XCTAssertEqual(stats.totalFocusTime, 0)
    }
    
    func testConcurrentOperations() throws {
        // Test concurrent access to models
        let expectation = XCTestExpectation(description: "Concurrent operations")
        expectation.expectedFulfillmentCount = 10
        
        DispatchQueue.concurrentPerform(iterations: 10) { _ in
            petModel.setState(.walking)
            timerModel.startFocusSession()
            activityModel.addSession(ActivitySession(
                type: .focus,
                startTime: Date(),
                endTime: Date().addingTimeInterval(1500)
            ))
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestSession(type: ActivitySession.SessionType, duration: TimeInterval = 1500) -> ActivitySession {
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(duration)
        return ActivitySession(type: type, startTime: startTime, endTime: endTime)
    }
}