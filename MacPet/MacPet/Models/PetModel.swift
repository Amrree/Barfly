import Foundation
import AppKit

enum PetType: String, CaseIterable {
    case cat = "cat"
    case dog = "dog"
    case rabbit = "rabbit"
    case mouse = "mouse"
    
    var displayName: String {
        switch self {
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .rabbit: return "Rabbit"
        case .mouse: return "Mouse"
        }
    }
    
    var emoji: String {
        switch self {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .rabbit: return "🐰"
        case .mouse: return "🐭"
        }
    }
}

enum PetState {
    case idle
    case walking
    case sleeping
    case working
    case excited
    
    var animationSpeed: Double {
        switch self {
        case .idle: return 1.0
        case .walking: return 0.8
        case .sleeping: return 2.0
        case .working: return 1.2
        case .excited: return 0.6
        }
    }
}

struct PetAnimation {
    let name: String
    let frames: [NSImage]
    let duration: Double
    let loopCount: Int // -1 for infinite
    
    init(name: String, frames: [NSImage], duration: Double, loopCount: Int = -1) {
        self.name = name
        self.frames = frames
        self.duration = duration
        self.loopCount = loopCount
    }
}

class PetModel: ObservableObject {
    @Published var currentPet: PetType = .cat
    @Published var currentState: PetState = .idle
    @Published var position: CGPoint = CGPoint(x: 0, y: 0)
    @Published var isAnimating: Bool = false
    
    private var animations: [String: PetAnimation] = [:]
    
    init() {
        setupAnimations()
    }
    
    private func setupAnimations() {
        // Create pixel art cat animations
        createCatAnimations()
    }
    
    private func createCatAnimations() {
        // Idle animation (blinking)
        let idleFrames = createPixelArtFrames([
            createPixelCatImage(eyes: "oo", mouth: "="),  // Eyes open
            createPixelCatImage(eyes: "oo", mouth: "="),  // Eyes open
            createPixelCatImage(eyes: "oo", mouth: "="),  // Eyes open
            createPixelCatImage(eyes: "--", mouth: "="),  // Eyes closed
        ])
        animations["cat_idle"] = PetAnimation(name: "idle", frames: idleFrames, duration: 2.0)
        
        // Walking animation
        let walkFrames = createPixelArtFrames([
            createPixelCatImage(eyes: "oo", mouth: "=", legs: "||"),   // Standing
            createPixelCatImage(eyes: "oo", mouth: "=", legs: "\\/"),  // Left leg forward
            createPixelCatImage(eyes: "oo", mouth: "=", legs: "||"),   // Standing
            createPixelCatImage(eyes: "oo", mouth: "=", legs: "/\\"),  // Right leg forward
        ])
        animations["cat_walking"] = PetAnimation(name: "walking", frames: walkFrames, duration: 0.8)
        
        // Sleeping animation
        let sleepFrames = createPixelArtFrames([
            createPixelCatImage(eyes: "--", mouth: "~", body: "zZz"),  // Sleeping
            createPixelCatImage(eyes: "--", mouth: "~", body: "zZz"),  // Sleeping
            createPixelCatImage(eyes: "--", mouth: "~", body: "zZz"),  // Sleeping
            createPixelCatImage(eyes: "--", mouth: "~", body: "zZz"),  // Sleeping
        ])
        animations["cat_sleeping"] = PetAnimation(name: "sleeping", frames: sleepFrames, duration: 3.0)
    }
    
    private func createPixelCatImage(eyes: String = "oo", mouth: String = "=", legs: String = "||", body: String = "cat") -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Background
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Cat body (simple pixel representation)
        NSColor.black.setFill()
        
        // Draw a simple cat shape
        let catPath = NSBezierPath()
        catPath.appendRect(NSRect(x: 6, y: 8, width: 4, height: 6))  // Body
        catPath.appendRect(NSRect(x: 5, y: 10, width: 6, height: 4)) // Head
        catPath.appendRect(NSRect(x: 4, y: 12, width: 2, height: 2)) // Left ear
        catPath.appendRect(NSRect(x: 10, y: 12, width: 2, height: 2)) // Right ear
        catPath.appendRect(NSRect(x: 7, y: 6, width: 1, height: 2))  // Left leg
        catPath.appendRect(NSRect(x: 8, y: 6, width: 1, height: 2))  // Right leg
        catPath.appendRect(NSRect(x: 3, y: 7, width: 2, height: 1))  // Left foot
        catPath.appendRect(NSRect(x: 11, y: 7, width: 2, height: 1)) // Right foot
        catPath.appendRect(NSRect(x: 2, y: 11, width: 3, height: 1)) // Tail
        
        catPath.fill()
        
        // Eyes
        NSColor.white.setFill()
        NSRect(x: 6, y: 11, width: 1, height: 1).fill()  // Left eye
        NSRect(x: 9, y: 11, width: 1, height: 1).fill()  // Right eye
        
        image.unlockFocus()
        
        return image
    }
    
    private func createPixelArtFrames(_ images: [NSImage]) -> [NSImage] {
        return images
    }
    
    func getAnimation(for state: PetState) -> PetAnimation? {
        let animationKey = "\(currentPet.rawValue)_\(getStateName(state))"
        return animations[animationKey]
    }
    
    private func getStateName(_ state: PetState) -> String {
        switch state {
        case .idle: return "idle"
        case .walking: return "walking"
        case .sleeping: return "sleeping"
        case .working: return "working"
        case .excited: return "excited"
        }
    }
    
    func changePet(to newPet: PetType) {
        currentPet = newPet
        // TODO: Load animations for new pet type
    }
    
    func setState(_ newState: PetState) {
        currentState = newState
    }
    
    func updatePosition(_ newPosition: CGPoint) {
        position = newPosition
    }
}