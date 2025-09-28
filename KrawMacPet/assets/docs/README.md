# Mac Pet 🐱

A delightful macOS menu bar application featuring an animated pixel art cat companion with integrated Pomodoro timer and activity tracking.

## Features

### 🐱 Animated Pet
- **Pixel Art Cat**: Adorable pixel art cat that lives in your menu bar
- **Walking Animation**: Cat walks across the menu bar periodically
- **State-Based Animations**: Different animations for idle, walking, sleeping, working, and excited states
- **Interactive**: Click the cat to see reactions and hear sounds

### ⏱️ Pomodoro Timer
- **Customizable Intervals**: Set your own focus and break durations
- **Visual Progress**: Circular progress indicator with color-coded states
- **Auto-Transitions**: Automatically start breaks after focus sessions
- **Notifications**: System notifications for session changes
- **Session Tracking**: Keep track of completed focus sessions

### 📊 Activity Tracking
- **Daily Statistics**: Track your daily focus time and sessions
- **Streak Tracking**: Monitor your consistency with daily streaks
- **Weekly Charts**: Visual representation of your weekly activity
- **Export Data**: Export your activity data as JSON
- **Achievement System**: Unlock milestones and achievements

### ⚙️ Customization
- **Multiple Pets**: Choose from cat, dog, rabbit, or mouse (future updates)
- **Animation Speed**: Adjust how fast the pet animates
- **Sound Controls**: Enable/disable notification sounds
- **Menu Bar Integration**: Seamless integration with macOS menu bar
- **Auto-Start Options**: Configure automatic session transitions

## Screenshots

*Coming soon - the app will show:*
- Cat walking across the menu bar
- Pomodoro timer with circular progress
- Activity statistics window
- Settings panel with customization options

## Installation

### Requirements
- macOS 11.0 (Big Sur) or later
- Xcode 14.0 or later (for building from source)

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/mac-pet.git
cd mac-pet
```

2. Open the project in Xcode:
```bash
open MacPet.xcodeproj
```

3. Build and run the project:
- Select the MacPet target
- Press Cmd+R to build and run

### Distribution

The app will be available for download as a `.dmg` file (coming soon).

## Usage

### Getting Started

1. **Launch the App**: After building/running, the cat will appear in your menu bar
2. **Start a Focus Session**: Click the cat or use the menu to start a Pomodoro timer
3. **Take Breaks**: The app will remind you to take breaks between focus sessions
4. **Track Progress**: View your activity statistics through the menu

### Menu Options

- **🐱 Mac Pet**: App header with current status
- **▶ Start Focus Session**: Begin a 25-minute focus session
- **▶ Start Break**: Take a 5-minute break
- **📊 View Activity**: Open activity statistics window
- **⚙️ Settings**: Configure app preferences
- **❓ About**: App information
- **🚪 Quit Mac Pet**: Exit the application

### Settings

Access settings through the menu bar to customize:
- **Timer Durations**: Adjust focus and break lengths
- **Pet Behavior**: Change animation speed and pet type
- **Notifications**: Control sound and alert preferences
- **Auto-Start**: Configure automatic session transitions
- **General**: Start at login, dock visibility, etc.

## Technical Details

### Architecture
- **Language**: Swift 5.0+
- **Frameworks**: AppKit, Core Animation, UserNotifications
- **Pattern**: Model-View-Controller (MVC)
- **Data Storage**: UserDefaults for settings, Core Data for activity tracking

### Project Structure
```
MacPet/
├── App/
│   ├── AppDelegate.swift          # Main application delegate
│   └── MenuBarController.swift    # Menu bar integration
├── Models/
│   ├── PetModel.swift            # Pet state and animations
│   ├── TimerModel.swift          # Pomodoro timer logic
│   └── ActivityModel.swift       # Activity tracking data
├── Views/
│   ├── PetView.swift             # Pet display and interaction
│   ├── TimerView.swift           # Timer UI components
│   └── SettingsView.swift        # Settings interface
├── Controllers/
│   ├── PetController.swift       # Pet behavior management
│   ├── TimerController.swift     # Timer functionality
│   └── ActivityController.swift  # Activity tracking
├── Utils/
│   ├── AnimationManager.swift    # Animation utilities
│   └── NotificationManager.swift # System notifications
└── Assets/
    ├── Sprites/                  # Pixel art assets
    └── Sounds/                   # Audio files
```

### Key Features Implementation

#### Pet Animation System
- Sprite-based animations using Core Animation
- State machine for different pet behaviors
- Smooth transitions between animation states
- Menu bar positioning and movement

#### Pomodoro Timer
- Customizable focus/break durations
- Visual progress indicators
- System notification integration
- Session state management

#### Activity Tracking
- Local data persistence using UserDefaults
- Daily/weekly/monthly statistics
- Streak calculation and tracking
- Data export functionality

## Development

### Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

### Code Style

- Follow Swift style guidelines
- Use meaningful variable and function names
- Add comments for complex logic
- Maintain consistent indentation (4 spaces)

### Testing

- Test on multiple macOS versions (11.0+)
- Verify menu bar integration works correctly
- Test timer functionality and notifications
- Ensure proper data persistence

## Roadmap

### Version 1.1
- [ ] Additional pet types (dog, rabbit, mouse)
- [ ] Custom pet animations
- [ ] Sound effects for pet interactions
- [ ] Dark mode support

### Version 1.2
- [ ] Widget support for macOS
- [ ] Cloud sync for activity data
- [ ] Integration with productivity apps
- [ ] Advanced statistics and insights

### Version 2.0
- [ ] Custom pet creation tools
- [ ] Achievement system with badges
- [ ] Social features (share streaks)
- [ ] Plugin system for extensions

## Troubleshooting

### Common Issues

**Cat not appearing in menu bar:**
- Ensure the app has proper permissions
- Check that the app is running in the background
- Restart the application

**Timer not working:**
- Verify notification permissions are granted
- Check system sound settings
- Restart the timer from the menu

**Activity data not saving:**
- Check app permissions for file access
- Verify UserDefaults are working correctly
- Try resetting app data in settings

### Getting Help

- Check the [Issues](https://github.com/yourusername/mac-pet/issues) page
- Create a new issue with detailed information
- Include macOS version and app version

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the original Mac Pet application
- Pixel art assets created with Aseprite
- Built with love for the macOS community

## Support

If you enjoy using Mac Pet, please consider:
- ⭐ Starring this repository
- 🐛 Reporting bugs and issues
- 💡 Suggesting new features
- 📢 Sharing with friends

---

Made with ❤️ for productive macOS users who need a little companionship in their workflow.