import Cocoa
import QuartzCore

class AnimationManager: NSObject {
    
    static let shared = AnimationManager()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Pet Animations
    
    func createWalkingAnimation(for view: NSView, duration: TimeInterval) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        
        // Position animation (walking across screen)
        let positionAnimation = CABasicAnimation(keyPath: "position.x")
        positionAnimation.fromValue = view.frame.origin.x
        positionAnimation.toValue = view.frame.origin.x + 100
        positionAnimation.duration = duration
        
        // Scale animation (bobbing effect)
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale.y")
        scaleAnimation.values = [1.0, 0.95, 1.0, 0.95, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        scaleAnimation.duration = duration
        
        animationGroup.animations = [positionAnimation, scaleAnimation]
        animationGroup.duration = duration
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        return animationGroup
    }
    
    func createIdleAnimation(for view: NSView) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        
        // Gentle floating motion
        let positionAnimation = CAKeyframeAnimation(keyPath: "position.y")
        positionAnimation.values = [view.frame.origin.y, view.frame.origin.y + 1, view.frame.origin.y]
        positionAnimation.keyTimes = [0.0, 0.5, 1.0]
        positionAnimation.duration = 2.0
        positionAnimation.repeatCount = .infinity
        
        // Subtle scale animation (breathing effect)
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.02, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.5, 1.0]
        scaleAnimation.duration = 3.0
        scaleAnimation.repeatCount = .infinity
        
        animationGroup.animations = [positionAnimation, scaleAnimation]
        animationGroup.duration = 3.0
        animationGroup.repeatCount = .infinity
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        return animationGroup
    }
    
    func createSleepingAnimation(for view: NSView) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        
        // Slow breathing motion
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 0.98, 1.0, 0.98, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        scaleAnimation.duration = 4.0
        scaleAnimation.repeatCount = .infinity
        
        // Slight rotation (like a sleeping cat)
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.values = [0, 0.02, 0, -0.02, 0]
        rotationAnimation.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        rotationAnimation.duration = 6.0
        rotationAnimation.repeatCount = .infinity
        
        animationGroup.animations = [scaleAnimation, rotationAnimation]
        animationGroup.duration = 6.0
        animationGroup.repeatCount = .infinity
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        return animationGroup
    }
    
    func createExcitementAnimation(for view: NSView) -> CAAnimationGroup {
        let animationGroup = CAAnimationGroup()
        
        // Bouncing motion
        let positionAnimation = CAKeyframeAnimation(keyPath: "position.y")
        positionAnimation.values = [
            view.frame.origin.y,
            view.frame.origin.y + 3,
            view.frame.origin.y,
            view.frame.origin.y + 2,
            view.frame.origin.y
        ]
        positionAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 1.0]
        positionAnimation.duration = 0.8
        
        // Quick scale changes
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.1, 0.9, 1.1, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 1.0]
        scaleAnimation.duration = 0.8
        
        // Rotation for excitement
        let rotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.values = [0, 0.1, -0.1, 0.05, 0]
        rotationAnimation.keyTimes = [0.0, 0.2, 0.4, 0.6, 1.0]
        rotationAnimation.duration = 0.8
        
        animationGroup.animations = [positionAnimation, scaleAnimation, rotationAnimation]
        animationGroup.duration = 0.8
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        return animationGroup
    }
    
    // MARK: - Transition Animations
    
    func fadeIn(_ view: NSView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        view.alphaValue = 0.0
        view.isHidden = false
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            view.animator().alphaValue = 1.0
        }, completionHandler: completion)
    }
    
    func fadeOut(_ view: NSView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            view.animator().alphaValue = 0.0
        }, completionHandler: {
            view.isHidden = true
            completion?()
        })
    }
    
    func slideIn(from direction: SlideDirection, view: NSView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let originalFrame = view.frame
        var startFrame = originalFrame
        
        switch direction {
        case .left:
            startFrame.origin.x = -startFrame.width
        case .right:
            startFrame.origin.x = view.superview?.bounds.width ?? startFrame.width
        case .top:
            startFrame.origin.y = view.superview?.bounds.height ?? startFrame.height
        case .bottom:
            startFrame.origin.y = -startFrame.height
        }
        
        view.frame = startFrame
        view.isHidden = false
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            view.animator().frame = originalFrame
        }, completionHandler: completion)
    }
    
    func slideOut(to direction: SlideDirection, view: NSView, duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        let originalFrame = view.frame
        var endFrame = originalFrame
        
        switch direction {
        case .left:
            endFrame.origin.x = -endFrame.width
        case .right:
            endFrame.origin.x = view.superview?.bounds.width ?? endFrame.width
        case .top:
            endFrame.origin.y = view.superview?.bounds.height ?? endFrame.height
        case .bottom:
            endFrame.origin.y = -endFrame.height
        }
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            view.animator().frame = endFrame
        }, completionHandler: {
            view.isHidden = true
            view.frame = originalFrame
            completion?()
        })
    }
    
    // MARK: - Utility Animations
    
    func pulse(_ view: NSView, scale: CGFloat = 1.1, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, scale, 1.0]
        animation.keyTimes = [0.0, 0.5, 1.0]
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        view.layer?.add(animation, forKey: "pulse")
        CATransaction.commit()
    }
    
    func shake(_ view: NSView, intensity: CGFloat = 5.0, duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [0, -intensity, intensity, -intensity, intensity, -intensity, intensity, 0]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 1.0]
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        view.layer?.add(animation, forKey: "shake")
        CATransaction.commit()
    }
    
    func bounce(_ view: NSView, height: CGFloat = 20.0, duration: TimeInterval = 0.6, completion: (() -> Void)? = nil) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.values = [0, -height, 0, -height * 0.5, 0]
        animation.keyTimes = [0.0, 0.3, 0.6, 0.8, 1.0]
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        view.layer?.add(animation, forKey: "bounce")
        CATransaction.commit()
    }
}

enum SlideDirection {
    case left
    case right
    case top
    case bottom
}

// MARK: - Animation Extensions

extension NSView {
    
    func addAnimation(_ animation: CAAnimation, forKey key: String?) {
        self.wantsLayer = true
        self.layer?.add(animation, forKey: key)
    }
    
    func removeAnimation(forKey key: String) {
        self.layer?.removeAnimation(forKey: key)
    }
    
    func removeAllAnimations() {
        self.layer?.removeAllAnimations()
    }
}