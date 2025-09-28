import Cocoa
import AppKit

class ActivityController: NSObject {
    
    private let activityModel = ActivityModel()
    private var activityWindow: ActivityWindow?
    
    override init() {
        super.init()
    }
    
    func recordSession(type: ActivitySession.SessionType, startTime: Date, endTime: Date) {
        let session = ActivitySession(type: type, startTime: startTime, endTime: endTime)
        activityModel.addSession(session)
    }
    
    func showActivityWindow() {
        if activityWindow == nil {
            activityWindow = ActivityWindow(activityModel: activityModel)
        }
        activityWindow?.showWindow()
    }
    
    func getTodaysActivity() -> DailyActivity? {
        return activityModel.getTodaysActivity()
    }
    
    func getActivityStats() -> ActivityStats {
        return activityModel.getActivityStats()
    }
    
    func getCurrentStreak() -> Int {
        return activityModel.currentStreak
    }
}

// MARK: - Activity Window

class ActivityWindow: NSWindowController {
    
    private let activityModel: ActivityModel
    private var activityView: ActivityView?
    
    init(activityModel: ActivityModel) {
        self.activityModel = activityModel
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Activity Statistics"
        window.center()
        window.setFrameAutosaveName("ActivityWindow")
        
        super.init(window: window)
        
        setupActivityView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupActivityView() {
        activityView = ActivityView(activityModel: activityModel)
        window?.contentView = activityView
    }
    
    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        activityView?.refreshData()
    }
}

// MARK: - Activity View

class ActivityView: NSView {
    
    private let activityModel: ActivityModel
    private var scrollView: NSScrollView!
    private var contentView: NSView!
    
    // UI Elements
    private var currentStreakLabel: NSTextField!
    private var totalSessionsLabel: NSTextField!
    private var totalFocusTimeLabel: NSTextField!
    private var averageSessionLabel: NSTextField!
    private var weeklyChartView: WeeklyChartView!
    
    init(activityModel: ActivityModel) {
        self.activityModel = activityModel
        super.init(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        
        setupUI()
        refreshData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Create scroll view
        scrollView = NSScrollView(frame: bounds)
        scrollView.autoresizingMask = [.width, .height]
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        // Create content view
        contentView = NSView(frame: NSRect(x: 0, y: 0, width: bounds.width, height: 600))
        
        // Set up scroll view
        scrollView.documentView = contentView
        addSubview(scrollView)
        
        setupStatsSection()
        setupWeeklyChart()
        setupButtons()
    }
    
    private func setupStatsSection() {
        // Title
        let titleLabel = NSTextField(labelWithString: "Activity Statistics")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 18)
        titleLabel.frame = NSRect(x: 20, y: 550, width: 200, height: 30)
        contentView.addSubview(titleLabel)
        
        // Current streak
        let streakTitleLabel = NSTextField(labelWithString: "Current Streak:")
        streakTitleLabel.frame = NSRect(x: 20, y: 520, width: 100, height: 20)
        contentView.addSubview(streakTitleLabel)
        
        currentStreakLabel = NSTextField(labelWithString: "0 days")
        currentStreakLabel.font = NSFont.boldSystemFont(ofSize: 16)
        currentStreakLabel.textColor = NSColor.systemBlue
        currentStreakLabel.frame = NSRect(x: 130, y: 520, width: 100, height: 20)
        contentView.addSubview(currentStreakLabel)
        
        // Total sessions
        let sessionsTitleLabel = NSTextField(labelWithString: "Total Sessions:")
        sessionsTitleLabel.frame = NSRect(x: 20, y: 490, width: 100, height: 20)
        contentView.addSubview(sessionsTitleLabel)
        
        totalSessionsLabel = NSTextField(labelWithString: "0")
        totalSessionsLabel.font = NSFont.boldSystemFont(ofSize: 16)
        totalSessionsLabel.frame = NSRect(x: 130, y: 490, width: 100, height: 20)
        contentView.addSubview(totalSessionsLabel)
        
        // Total focus time
        let focusTitleLabel = NSTextField(labelWithString: "Total Focus Time:")
        focusTitleLabel.frame = NSRect(x: 20, y: 460, width: 100, height: 20)
        contentView.addSubview(focusTitleLabel)
        
        totalFocusTimeLabel = NSTextField(labelWithString: "0h 00m")
        totalFocusTimeLabel.font = NSFont.boldSystemFont(ofSize: 16)
        totalFocusTimeLabel.textColor = NSColor.systemGreen
        totalFocusTimeLabel.frame = NSRect(x: 130, y: 460, width: 100, height: 20)
        contentView.addSubview(totalFocusTimeLabel)
        
        // Average session
        let avgTitleLabel = NSTextField(labelWithString: "Average Session:")
        avgTitleLabel.frame = NSRect(x: 20, y: 430, width: 100, height: 20)
        contentView.addSubview(avgTitleLabel)
        
        averageSessionLabel = NSTextField(labelWithString: "0 min")
        averageSessionLabel.font = NSFont.boldSystemFont(ofSize: 16)
        averageSessionLabel.frame = NSRect(x: 130, y: 430, width: 100, height: 20)
        contentView.addSubview(averageSessionLabel)
    }
    
    private func setupWeeklyChart() {
        let chartTitleLabel = NSTextField(labelWithString: "This Week")
        chartTitleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        chartTitleLabel.frame = NSRect(x: 20, y: 380, width: 100, height: 20)
        contentView.addSubview(chartTitleLabel)
        
        weeklyChartView = WeeklyChartView(frame: NSRect(x: 20, y: 200, width: 560, height: 170))
        contentView.addSubview(weeklyChartView)
    }
    
    private func setupButtons() {
        // Export button
        let exportButton = NSButton(title: "Export Data", target: self, action: #selector(exportData))
        exportButton.frame = NSRect(x: 20, y: 150, width: 100, height: 32)
        exportButton.bezelStyle = .rounded
        contentView.addSubview(exportButton)
        
        // Clear data button
        let clearButton = NSButton(title: "Clear All Data", target: self, action: #selector(clearData))
        clearButton.frame = NSRect(x: 130, y: 150, width: 120, height: 32)
        clearButton.bezelStyle = .rounded
        contentView.addSubview(clearButton)
        
        // Refresh button
        let refreshButton = NSButton(title: "Refresh", target: self, action: #selector(refreshData))
        refreshButton.frame = NSRect(x: 260, y: 150, width: 80, height: 32)
        refreshButton.bezelStyle = .rounded
        contentView.addSubview(refreshButton)
    }
    
    func refreshData() {
        let stats = activityModel.getActivityStats()
        
        currentStreakLabel.stringValue = "\(stats.currentStreak) days"
        totalSessionsLabel.stringValue = "\(stats.totalSessions)"
        totalFocusTimeLabel.stringValue = stats.formattedTotalFocusTime
        averageSessionLabel.stringValue = stats.formattedAverageSession
        
        weeklyChartView.updateData(activityModel.getWeeklyActivity())
    }
    
    @objc private func exportData() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "macpet_activity_\(DateFormatter().string(from: Date()))"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.exportActivityData(to: url)
            }
        }
    }
    
    private func exportActivityData(to url: URL) {
        // Export activity data as JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let exportData = [
            "stats": activityModel.getActivityStats(),
            "sessions": activityModel.sessions,
            "dailyActivities": activityModel.dailyActivities
        ]
        
        do {
            let data = try encoder.encode(exportData)
            try data.write(to: url)
            
            let alert = NSAlert()
            alert.messageText = "Export Successful"
            alert.informativeText = "Activity data has been exported to \(url.lastPathComponent)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Export Failed"
            alert.informativeText = "Could not export activity data: \(error.localizedDescription)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    @objc private func clearData() {
        let alert = NSAlert()
        alert.messageText = "Clear All Data"
        alert.informativeText = "Are you sure you want to clear all activity data? This action cannot be undone."
        alert.addButton(withTitle: "Clear Data")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            activityModel.clearAllData()
            refreshData()
        }
    }
}

// MARK: - Weekly Chart View

class WeeklyChartView: NSView {
    
    private var dailyActivities: [DailyActivity] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(_ activities: [DailyActivity]) {
        dailyActivities = activities
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard !dailyActivities.isEmpty else { return }
        
        let context = NSGraphicsContext.current?.cgContext
        context?.setLineWidth(2.0)
        
        // Draw chart background
        NSColor.controlBackgroundColor.setFill()
        dirtyRect.fill()
        
        // Calculate bar dimensions
        let barWidth = (bounds.width - 40) / CGFloat(dailyActivities.count)
        let maxFocusTime = dailyActivities.map { $0.totalFocusTime }.max() ?? 1
        
        // Draw bars for each day
        for (index, activity) in dailyActivities.enumerated() {
            let barHeight = CGFloat(activity.totalFocusTime / maxFocusTime) * (bounds.height - 40)
            let x = 20 + CGFloat(index) * barWidth
            let y = 20
            let barRect = NSRect(x: x, y: y, width: barWidth - 2, height: barHeight)
            
            // Color based on focus time
            let intensity = CGFloat(activity.totalFocusTime / maxFocusTime)
            NSColor(red: 0.2 + intensity * 0.6, green: 0.6 + intensity * 0.4, blue: 0.8, alpha: 1.0).setFill()
            barRect.fill()
            
            // Draw day label
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "E"
            let dayLabel = dayFormatter.string(from: activity.date)
            
            let labelRect = NSRect(x: x, y: 5, width: barWidth, height: 15)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 10),
                .foregroundColor: NSColor.labelColor,
                .paragraphStyle: paragraphStyle
            ]
            
            dayLabel.draw(in: labelRect, withAttributes: attributes)
        }
    }
}