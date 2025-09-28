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
        // Create pixel art cat animations using the sprite generator
        let catSprites = CatSpriteGenerator.generateCatSprites()
        
        for (stateName, frames) in catSprites {
            let animationKey = "cat_\(stateName)"
            let duration = getAnimationDuration(for: stateName)
            animations[animationKey] = PetAnimation(name: stateName, frames: frames, duration: duration)
        }
    }
    
    private func getAnimationDuration(for stateName: String) -> Double {
        switch stateName {
        case "idle": return 2.0
        case "walking": return 0.8
        case "sleeping": return 3.0
        case "working": return 1.5
        case "excited": return 0.6
        default: return 1.0
        }
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