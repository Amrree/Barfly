# Crow Mac Pet Customization Guide

## How to Adjust Speed, Direction, and Distance

### 1. Animation Speed (How fast the GIF frames change)
**Location**: `startCatWalkingAnimation()` function
```swift
walkingTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
```
- **Lower values** = Faster animation (0.2 = very fast, 0.8 = slow)
- **Higher values** = Slower animation
- **Current**: 0.4 seconds between frame changes

### 2. Movement Speed (How fast the crow moves across the screen)
**Location**: `startCatWalkingAnimation()` function
```swift
self.walkPosition += self.walkDirection * 6.0
```
- **Higher values** = Faster movement (8.0 = very fast, 2.0 = slow)
- **Lower values** = Slower movement
- **Current**: 6.0 pixels per step

### 3. Starting Position (Where the crow begins)
**Location**: Class properties
```swift
private var walkPosition: CGFloat = 40.0 // Start 1 icon to the right (1 * 40px = 40px)
```
- **40.0** = 1 icon to the right
- **80.0** = 2 icons to the right
- **0.0** = Center
- **-40.0** = 1 icon to the left

### 4. Walking Distance (How far the crow walks)
**Location**: `startCatWalkingAnimation()` function
```swift
if self.walkPosition <= -120.0 { // 5 icons left from start
    self.walkDirection = 1.0 // Turn around
} else if self.walkPosition >= 40.0 { // Back to 1 icon right
    self.walkDirection = -1.0 // Walk left again
}
```

**Left boundary**: `-120.0` (5 icons left from start)
- Change to `-80.0` for shorter left walk
- Change to `-160.0` for longer left walk

**Right boundary**: `40.0` (1 icon right from start)
- Change to `0.0` to return to center
- Change to `80.0` to go 2 icons right

### 5. Initial Direction (Which way the crow starts walking)
**Location**: Class properties
```swift
private var walkDirection: CGFloat = -1.0 // Start walking left
```
- **-1.0** = Start walking left
- **1.0** = Start walking right

### 6. Menu Bar Width (Total space available)
**Location**: `createCatImage()` and `createWalkingImage()` functions
```swift
let targetSize = NSSize(width: 240, height: 32) // 6 icon spaces = 6 * 40px = 240px
```
- **240px** = 6 icon spaces
- **320px** = 8 icon spaces
- **160px** = 4 icon spaces

## Quick Examples

### Make crow walk faster:
```swift
// Faster animation
walkingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in

// Faster movement
self.walkPosition += self.walkDirection * 8.0
```

### Make crow walk slower:
```swift
// Slower animation
walkingTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in

// Slower movement
self.walkPosition += self.walkDirection * 3.0
```

### Make crow walk further:
```swift
// Walk 8 icons left instead of 5
if self.walkPosition <= -200.0 { // 8 * 40px = 320px, but start is at 40px, so 40-320 = -200px
    self.walkDirection = 1.0
}
```

### Start crow in center:
```swift
private var walkPosition: CGFloat = 0.0 // Start in center
```

### Start crow walking right:
```swift
private var walkDirection: CGFloat = 1.0 // Start walking right
```

## Icon Space Reference
- 1 icon = 40px
- 2 icons = 80px
- 3 icons = 120px
- 4 icons = 160px
- 5 icons = 200px
- 6 icons = 240px

## Backup Files
- `SimpleMacPet_crow_perfect_final.swift` - Current perfect version
- `SimpleMacPet_crow_custom_backup.swift` - Previous working version
- `SimpleMacPet_crow_pixel_backup.swift` - Pixel art version
