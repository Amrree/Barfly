import Cocoa
import AppKit

class TimerView: NSView {
    
    private var timerController: TimerController?
    private var progressCircle: ProgressCircleView!
    private var timeLabel: NSTextField!
    private var statusLabel: NSTextField!
    private var startButton: NSButton!
    private var pauseButton: NSButton!
    private var stopButton: NSButton!
    
    private var updateTimer: Timer?
    
    init(timerController: TimerController) {
        self.timerController = timerController
        super.init(frame: NSRect(x: 0, y: 0, width: 200, height: 200))
        
        setupUI()
        startUpdateTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.cornerRadius = 12
        
        // Progress circle
        progressCircle = ProgressCircleView(frame: NSRect(x: 20, y: 80, width: 160, height: 160))
        addSubview(progressCircle)
        
        // Time label
        timeLabel = NSTextField(labelWithString: "25:00")
        timeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 24, weight: .medium)
        timeLabel.alignment = .center
        timeLabel.frame = NSRect(x: 20, y: 140, width: 160, height: 30)
        timeLabel.textColor = NSColor.labelColor
        addSubview(timeLabel)
        
        // Status label
        statusLabel = NSTextField(labelWithString: "Ready to focus")
        statusLabel.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        statusLabel.alignment = .center
        statusLabel.frame = NSRect(x: 20, y: 115, width: 160, height: 20)
        statusLabel.textColor = NSColor.secondaryLabelColor
        addSubview(statusLabel)
        
        // Control buttons
        setupControlButtons()
    }
    
    private func setupControlButtons() {
        // Start button
        startButton = NSButton(title: "Start", target: self, action: #selector(startTimer))
        startButton.frame = NSRect(x: 20, y: 20, width: 50, height: 32)
        startButton.bezelStyle = .rounded
        startButton.isEnabled = true
        addSubview(startButton)
        
        // Pause button
        pauseButton = NSButton(title: "Pause", target: self, action: #selector(pauseTimer))
        pauseButton.frame = NSRect(x: 80, y: 20, width: 50, height: 32)
        pauseButton.bezelStyle = .rounded
        pauseButton.isEnabled = false
        addSubview(pauseButton)
        
        // Stop button
        stopButton = NSButton(title: "Stop", target: self, action: #selector(stopTimer))
        stopButton.frame = NSRect(x: 140, y: 20, width: 50, height: 32)
        stopButton.bezelStyle = .rounded
        stopButton.isEnabled = false
        addSubview(stopButton)
    }
    
    private func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateDisplay()
        }
    }
    
    private func updateDisplay() {
        guard let timerController = timerController else { return }
        
        let timeRemaining = timerController.getTimeRemaining()
        let progress = timerController.getProgress()
        let state = timerController.getCurrentState()
        
        // Update time label
        timeLabel.stringValue = timeRemaining
        
        // Update progress circle
        progressCircle.setProgress(progress, animated: true)
        
        // Update status label
        statusLabel.stringValue = getStatusText(for: state)
        
        // Update button states
        updateButtonStates(for: state)
    }
    
    private func getStatusText(for state: TimerState) -> String {
        switch state {
        case .idle:
            return "Ready to focus"
        case .focus:
            return "Focus time"
        case .shortBreak:
            return "Short break"
        case .longBreak:
            return "Long break"
        }
    }
    
    private func updateButtonStates(for state: TimerState) {
        let isRunning = timerController?.isRunning ?? false
        
        switch state {
        case .idle:
            startButton.isEnabled = true
            pauseButton.isEnabled = false
            stopButton.isEnabled = false
        case .focus, .shortBreak, .longBreak:
            if isRunning {
                startButton.isEnabled = false
                pauseButton.isEnabled = true
                stopButton.isEnabled = true
                pauseButton.title = "Pause"
            } else {
                startButton.isEnabled = true
                pauseButton.isEnabled = true
                stopButton.isEnabled = true
                pauseButton.title = "Resume"
            }
        }
    }
    
    @objc private func startTimer() {
        let state = timerController?.getCurrentState() ?? .idle
        
        switch state {
        case .idle:
            timerController?.startFocusSession()
        case .focus, .shortBreak, .longBreak:
            timerController?.resumeTimer()
        }
    }
    
    @objc private func pauseTimer() {
        let isRunning = timerController?.isRunning ?? false
        
        if isRunning {
            timerController?.pauseTimer()
        } else {
            timerController?.resumeTimer()
        }
    }
    
    @objc private func stopTimer() {
        timerController?.stopTimer()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - Progress Circle View

class ProgressCircleView: NSView {
    
    private var progress: Double = 0.0
    private var progressLayer: CAShapeLayer!
    private var backgroundLayer: CAShapeLayer!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        wantsLayer = true
        
        // Background circle
        backgroundLayer = CAShapeLayer()
        backgroundLayer.fillColor = NSColor.clear.cgColor
        backgroundLayer.strokeColor = NSColor.separatorColor.cgColor
        backgroundLayer.lineWidth = 8
        backgroundLayer.lineCap = .round
        layer?.addSublayer(backgroundLayer)
        
        // Progress circle
        progressLayer = CAShapeLayer()
        progressLayer.fillColor = NSColor.clear.cgColor
        progressLayer.strokeColor = NSColor.systemBlue.cgColor
        progressLayer.lineWidth = 8
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer?.addSublayer(progressLayer)
        
        updatePaths()
    }
    
    private func updatePaths() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 8
        
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let path = CGMutablePath()
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        backgroundLayer.path = path
        progressLayer.path = path
    }
    
    override func layout() {
        super.layout()
        updatePaths()
    }
    
    func setProgress(_ progress: Double, animated: Bool = false) {
        self.progress = max(0, min(1, progress))
        
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progressLayer.strokeEnd
            animation.toValue = self.progress
            animation.duration = 0.3
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progress")
        }
        
        progressLayer.strokeEnd = CGFloat(self.progress)
        
        // Update color based on progress
        updateProgressColor()
    }
    
    private func updateProgressColor() {
        let color: NSColor
        
        switch progress {
        case 0.0..<0.25:
            color = .systemRed
        case 0.25..<0.5:
            color = .systemOrange
        case 0.5..<0.75:
            color = .systemYellow
        case 0.75...1.0:
            color = .systemGreen
        default:
            color = .systemBlue
        }
        
        progressLayer.strokeColor = color.cgColor
    }
}