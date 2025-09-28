# Cat Pixel Art Assets

This file documents the pixel art assets needed for the cat pet.

## Required Assets

### Idle Animation (4 frames)
- `cat_idle_1.png` - Eyes open, normal pose
- `cat_idle_2.png` - Eyes open, slight movement
- `cat_idle_3.png` - Eyes open, normal pose
- `cat_idle_4.png` - Eyes closed, sleeping

### Walking Animation (4 frames)
- `cat_walk_1.png` - Standing pose
- `cat_walk_2.png` - Left leg forward
- `cat_walk_3.png` - Standing pose
- `cat_walk_4.png` - Right leg forward

### Sleeping Animation (2 frames)
- `cat_sleep_1.png` - Sleeping pose with closed eyes
- `cat_sleep_2.png` - Sleeping pose with Z's

### Working Animation (3 frames)
- `cat_work_1.png` - Alert pose
- `cat_work_2.png` - Focused pose
- `cat_work_3.png` - Alert pose

### Excited Animation (4 frames)
- `cat_excited_1.png` - Normal pose
- `cat_excited_2.png` - Bouncing up
- `cat_excited_3.png` - Normal pose
- `cat_excited_4.png` - Bouncing up

## Specifications
- Size: 16x16 pixels (menu bar), 32x32 pixels (settings)
- Format: PNG with transparency
- Color Palette: Limited colors for pixel art aesthetic
- Animation Speed: 8-12 FPS for smooth but not distracting motion

## Implementation Notes
The assets are currently generated programmatically in the PetModel.swift file using NSBezierPath for simple pixel art shapes. In a production version, these would be replaced with actual pixel art assets created in tools like Aseprite or Piskel.

## Future Enhancements
- High-resolution versions for Retina displays
- Multiple color schemes (light/dark mode)
- Seasonal variations (Christmas hat, etc.)
- Custom pet creation tools