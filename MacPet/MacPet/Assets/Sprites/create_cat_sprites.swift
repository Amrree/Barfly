import Cocoa
import AppKit

// This file contains code to generate simple pixel art cat sprites
// In a production app, these would be replaced with actual pixel art assets

class CatSpriteGenerator {
    
    static func generateCatSprites() -> [String: [NSImage]] {
        var sprites: [String: [NSImage]] = [:]
        
        // Generate idle animation frames
        sprites["idle"] = [
            createCatImage(eyes: "oo", mouth: "="),
            createCatImage(eyes: "oo", mouth: "="),
            createCatImage(eyes: "oo", mouth: "="),
            createCatImage(eyes: "--", mouth: "=")
        ]
        
        // Generate walking animation frames
        sprites["walking"] = [
            createCatImage(eyes: "oo", mouth: "=", legs: "||"),
            createCatImage(eyes: "oo", mouth: "=", legs: "\\/"),
            createCatImage(eyes: "oo", mouth: "=", legs: "||"),
            createCatImage(eyes: "oo", mouth: "=", legs: "/\\")
        ]
        
        // Generate sleeping animation frames
        sprites["sleeping"] = [
            createCatImage(eyes: "--", mouth: "~", body: "zZz"),
            createCatImage(eyes: "--", mouth: "~", body: "zZz")
        ]
        
        // Generate working animation frames
        sprites["working"] = [
            createCatImage(eyes: "oo", mouth: "=", alert: true),
            createCatImage(eyes: "oo", mouth: "=", alert: true),
            createCatImage(eyes: "oo", mouth: "=", alert: true)
        ]
        
        // Generate excited animation frames
        sprites["excited"] = [
            createCatImage(eyes: "oo", mouth: "^", excited: true),
            createCatImage(eyes: "oo", mouth: "^", excited: true),
            createCatImage(eyes: "oo", mouth: "^", excited: true),
            createCatImage(eyes: "oo", mouth: "^", excited: true)
        ]
        
        return sprites
    }
    
    private static func createCatImage(eyes: String = "oo", mouth: String = "=", legs: String = "||", body: String = "cat", alert: Bool = false, excited: Bool = false) -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Clear background
        NSColor.clear.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Cat body color
        let bodyColor = alert ? NSColor.systemOrange : excited ? NSColor.systemYellow : NSColor.systemBlue
        bodyColor.setFill()
        
        // Draw cat body parts
        let catPath = NSBezierPath()
        
        // Head
        catPath.appendRect(NSRect(x: 5, y: 10, width: 6, height: 4))
        
        // Ears
        catPath.appendRect(NSRect(x: 4, y: 12, width: 2, height: 2))
        catPath.appendRect(NSRect(x: 10, y: 12, width: 2, height: 2))
        
        // Body
        catPath.appendRect(NSRect(x: 6, y: 8, width: 4, height: 4))
        
        // Legs
        if legs == "||" {
            catPath.appendRect(NSRect(x: 7, y: 6, width: 1, height: 2))
            catPath.appendRect(NSRect(x: 8, y: 6, width: 1, height: 2))
        } else if legs == "\\/" {
            catPath.appendRect(NSRect(x: 6, y: 6, width: 1, height: 2))
            catPath.appendRect(NSRect(x: 9, y: 6, width: 1, height: 2))
        } else if legs == "/\\" {
            catPath.appendRect(NSRect(x: 9, y: 6, width: 1, height: 2))
            catPath.appendRect(NSRect(x: 6, y: 6, width: 1, height: 2))
        }
        
        // Tail
        catPath.appendRect(NSRect(x: 2, y: 11, width: 3, height: 1))
        
        catPath.fill()
        
        // Eyes
        NSColor.white.setFill()
        if eyes == "oo" {
            NSRect(x: 6, y: 11, width: 1, height: 1).fill()  // Left eye
            NSRect(x: 9, y: 11, width: 1, height: 1).fill()  // Right eye
        } else if eyes == "--" {
            NSRect(x: 6, y: 11, width: 2, height: 1).fill()  // Left closed eye
            NSRect(x: 8, y: 11, width: 2, height: 1).fill()  // Right closed eye
        }
        
        // Mouth
        NSColor.white.setFill()
        if mouth == "=" {
            NSRect(x: 7, y: 10, width: 2, height: 1).fill()
        } else if mouth == "^" {
            NSRect(x: 7, y: 10, width: 2, height: 1).fill()
        } else if mouth == "~" {
            NSRect(x: 7, y: 10, width: 2, height: 1).fill()
        }
        
        // Special effects
        if excited {
            // Add sparkles
            NSColor.systemYellow.setFill()
            NSRect(x: 3, y: 13, width: 1, height: 1).fill()
            NSRect(x: 12, y: 14, width: 1, height: 1).fill()
        }
        
        image.unlockFocus()
        
        return image
    }
}