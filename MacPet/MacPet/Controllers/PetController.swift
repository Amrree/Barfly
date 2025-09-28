import Cocoa
import AppKit

class PetController: NSObject {
    
    private let petModel = PetModel()
    private var animationTimer: Timer?
    private var walkingTimer: Timer?
    private var currentFrameIndex = 0
    private var petView: PetView?
    
    override init() {
        super.init()
        setupPet()
    }
    
    private func setupPet() {
        // Initialize pet in idle state
        petModel.setState(.idle)
    }
    
    func createPetView() -> PetView {
        petView = PetView(petModel: petModel)
        return petView!
    }
    
    func startAnimation() {
        stopAnimation()
        
        // Start the main animation loop
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAnimation()
        }
        
        // Start random walking behavior
        scheduleNextWalk()
    }
    
    func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
        walkingTimer?.invalidate()
        walkingTimer = nil
    }
    
    private func updateAnimation() {
        guard let animation = petModel.getAnimation(for: petModel.currentState) else {
            return
        }
        
        // Update frame index
        currentFrameIndex += 1
        let frameCount = animation.frames.count
        
        if currentFrameIndex >= frameCount {
            currentFrameIndex = 0
        }
        
        // Update the pet view with current frame
        let currentFrame = animation.frames[currentFrameIndex]
        petView?.updateFrame(currentFrame)
    }
    
    private func scheduleNextWalk() {
        // Random delay between 5-15 seconds before next walk
        let delay = Double.random(in: 5...15)
        
        walkingTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.startWalking()
        }
    }
    
    private func startWalking() {
        // Change to walking state
        petModel.setState(.walking)
        
        // Walk across the menu bar
        animateWalkAcrossMenuBar()
        
        // Schedule return to idle after walking
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
            self?.returnToIdle()
        }
    }
    
    private func animateWalkAcrossMenuBar() {
        guard let petView = petView else { return }
        
        // Get the current frame of the status item
        let statusItem = petView.superview as? NSStatusItem
        guard let statusItemView = statusItem?.view else { return }
        
        // Animate the pet walking across the menu bar
        let walkDuration: TimeInterval = 2.0
        let startX = statusItemView.frame.minX
        let endX = startX + 100 // Walk 100 points to the right
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = walkDuration
            context.timingFunction = CAMediaTimingFunction(name: .linear)
            
            // Animate the position
            petView.animator().frame.origin.x = endX
        } completionHandler: { [weak self] in
            // Walk back to original position
            self?.walkBack()
        }
    }
    
    private func walkBack() {
        guard let petView = petView else { return }
        
        let walkDuration: TimeInterval = 2.0
        let endX = petView.frame.minX - 100 // Walk back 100 points to the left
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = walkDuration
            context.timingFunction = CAMediaTimingFunction(name: .linear)
            
            petView.animator().frame.origin.x = endX
        } completionHandler: { [weak self] in
            // Return to original position
            self?.returnToOriginalPosition()
        }
    }
    
    private func returnToOriginalPosition() {
        guard let petView = petView else { return }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
            petView.animator().frame.origin.x = 0
        }
    }
    
    private func returnToIdle() {
        petModel.setState(.idle)
        scheduleNextWalk()
    }
    
    func setPetState(_ newState: PetState) {
        petModel.setState(newState)
        
        // Handle state-specific behaviors
        switch newState {
        case .sleeping:
            // Sleep for a longer duration
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
                self?.petModel.setState(.idle)
            }
        case .working:
            // Working state - more active animations
            break
        case .excited:
            // Excited state - faster animations
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                self?.petModel.setState(.idle)
            }
        default:
            break
        }
    }
    
    func changePet(to newPet: PetType) {
        petModel.changePet(to: newPet)
    }
    
    deinit {
        stopAnimation()
    }
}