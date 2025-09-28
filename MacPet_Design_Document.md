# Mac Pet Clone - Design Document

## Project Overview

**Objective**: Create a macOS menu bar application featuring an animated pixel art cat that walks across the menu bar, integrates a Pomodoro timer, and tracks user activity to enhance productivity.

## Features Analysis (Based on Mac Pet Research)

### Core Features
1. **Pixel Art Pet Animation**
   - Cat walks across the menu bar periodically
   - Idle animations (sitting, blinking, yawning)
   - Sleep animations during breaks
   - Smooth pixel art animations using sprite sheets

2. **Menu Bar Integration**
   - Pet resides in macOS menu bar
   - Non-intrusive presence
   - Dropdown menu for controls and settings
   - Click interactions with the pet

3. **Pomodoro Timer**
   - Customizable focus and break durations (default: 25min work, 5min break)
   - Visual timer indicators
   - Audio/visual notifications for session transitions
   - Pet behavior changes based on timer state

4. **Activity Tracking**
   - Daily usage statistics
   - Streak tracking for consistent productivity
   - Weekly/monthly activity graphs
   - Achievement system

5. **Customization Options**
   - Multiple pet types (cat, dog, rabbit, mouse)
   - Adapt to macOS accent colors
   - Animation speed controls
   - Timer duration preferences

6. **Performance Optimization**
   - Minimal CPU usage (< 1%)
   - Low memory footprint
   - Battery-friendly animations
   - Background activity monitoring

## Technical Architecture

### Technology Stack
- **Language**: Swift
- **Frameworks**: 
  - AppKit (menu bar integration, UI components)
  - Core Animation (smooth pet animations)
  - SpriteKit (sprite-based animations)
  - UserNotifications (timer alerts)
- **Data Storage**: 
  - UserDefaults (settings and preferences)
  - Core Data (activity tracking and statistics)

### Project Structure
```
MacPet/
├── MacPet/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   └── MenuBarController.swift
│   ├── Models/
│   │   ├── PetModel.swift
│   │   ├── TimerModel.swift
│   │   └── ActivityModel.swift
│   ├── Views/
│   │   ├── PetView.swift
│   │   ├── TimerView.swift
│   │   └── SettingsView.swift
│   ├── Controllers/
│   │   ├── PetController.swift
│   │   ├── TimerController.swift
│   │   └── ActivityController.swift
│   ├── Assets/
│   │   ├── Sprites/
│   │   │   ├── cat_idle.png
│   │   │   ├── cat_walk_1.png
│   │   │   ├── cat_walk_2.png
│   │   │   └── cat_sleep.png
│   │   └── Sounds/
│   │       ├── meow.mp3
│   │       └── timer_beep.mp3
│   └── Utils/
│       ├── AnimationManager.swift
│       └── NotificationManager.swift
├── MacPet.xcodeproj
└── README.md
```

### Core Components

#### 1. Menu Bar Integration
- **NSStatusBar**: Creates the menu bar item
- **NSStatusItem**: Manages the pet icon and dropdown menu
- **Custom NSView**: Displays animated pet sprite

#### 2. Pet Animation System
- **Sprite Sheets**: Pre-rendered pixel art frames
- **Animation States**: idle, walking, sleeping, excited
- **Movement Logic**: Random walking patterns across menu bar
- **State Transitions**: Based on timer state and user activity

#### 3. Pomodoro Timer
- **Timer Logic**: Customizable focus/break intervals
- **State Management**: work, break, long break states
- **Notifications**: System notifications for session changes
- **Visual Feedback**: Progress indicators and pet behavior changes

#### 4. Activity Tracking
- **Session Recording**: Track focus sessions and breaks
- **Statistics Calculation**: Daily, weekly, monthly metrics
- **Streak Tracking**: Consecutive days with productivity
- **Data Persistence**: Store activity data locally

## User Interface Design

### Menu Bar Appearance
- **Pet Icon**: 16x16 or 22x22 pixel animated sprite
- **Visual Style**: Pixel art aesthetic matching macOS design
- **Animation**: Smooth, low-framerate animations (8-12 FPS)
- **Color Adaptation**: Automatically adapts to macOS accent colors

### Dropdown Menu
```
🐱 Mac Pet
─────────────
▶ Start Focus Session
▶ Start Break
▶ View Activity
─────────────
⚙️ Settings...
❓ About
─────────────
🚪 Quit Mac Pet
```

### Settings Window
- **Timer Settings**: Customize work/break durations
- **Pet Selection**: Choose from available pets
- **Animation Options**: Speed, frequency controls
- **Activity Stats**: View detailed statistics
- **Notifications**: Enable/disable alerts

## Implementation Plan

### Phase 1: Basic Menu Bar Pet (Week 1)
1. Create Xcode project with menu bar application
2. Implement basic cat sprite display in menu bar
3. Add simple idle animation (blinking)
4. Create dropdown menu structure

### Phase 2: Animation System (Week 2)
1. Design pixel art cat sprites
2. Implement sprite-based animation system
3. Add walking animation across menu bar
4. Create sleep/idle state animations

### Phase 3: Pomodoro Timer (Week 3)
1. Implement timer logic with customizable intervals
2. Add visual timer indicators
3. Integrate timer state with pet behavior
4. Add system notifications for session changes

### Phase 4: Activity Tracking (Week 4)
1. Implement session tracking system
2. Create activity statistics calculations
3. Add streak tracking functionality
4. Design activity visualization components

### Phase 5: Polish & Optimization (Week 5)
1. Performance optimization
2. UI/UX refinements
3. Bug fixes and testing
4. Documentation and deployment preparation

## Technical Specifications

### Performance Requirements
- **CPU Usage**: < 1% during idle, < 3% during animations
- **Memory Usage**: < 20MB total memory footprint
- **Battery Impact**: Minimal impact on battery life
- **Responsiveness**: 60fps animations, instant menu responses

### Compatibility
- **macOS Version**: 11.0 (Big Sur) and later
- **Architecture**: Universal binary (Intel + Apple Silicon)
- **Accessibility**: VoiceOver compatible
- **Localization**: English (primary), expandable to other languages

### Security & Privacy
- **Data Storage**: All data stored locally on device
- **Network Access**: No network connections required
- **Permissions**: No special permissions needed
- **Privacy**: No user data collection or transmission

## Asset Requirements

### Pixel Art Sprites
- **Resolution**: 16x16 pixels (menu bar), 32x32 pixels (settings)
- **Style**: Pixel art with 8-bit aesthetic
- **Color Palette**: Limited colors, adaptable to system themes
- **Animation Frames**: 2-4 frames per animation cycle

### Sound Effects
- **Format**: MP3 or AAC, low bitrate
- **Volume**: Subtle, non-intrusive
- **Frequency**: Occasional sounds (meows, timer alerts)
- **Customization**: User-controllable volume and enable/disable

## Future Enhancements

### Version 2.0 Features
- Multiple pet types (dog, rabbit, mouse)
- Custom pet creation tools
- Cloud sync for activity data
- Integration with productivity apps
- Widget support for macOS

### Community Features
- Pet sharing and customization
- Achievement system
- Leaderboards for productivity
- Plugin system for third-party integrations

## Success Metrics

### User Engagement
- Daily active usage
- Session duration and frequency
- Feature adoption rates
- User retention metrics

### Performance Metrics
- Application startup time
- Memory usage patterns
- CPU utilization
- Battery impact measurements

### Quality Metrics
- Crash-free sessions
- User satisfaction ratings
- Feature request frequency
- Bug report resolution time

---

This design document serves as the foundation for developing a Mac Pet clone that combines delightful pixel art animations with practical productivity tools, creating an engaging and useful companion for macOS users.