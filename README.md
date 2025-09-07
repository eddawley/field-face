# FieldFace

A battery-efficient Garmin watch face with pixel-perfect design, built using a layered field architecture.

## Device Compatibility

Currently supports:
- **Instinct 3 Solar 45mm** only

## Supported Fields

- **Time** - Main time display with right-justified formatting
- **Date** - Current date display
- **Weather** - Weather information with icon support
- **Battery** - Battery level indicator
- **Steps** - Step count tracker
- **Heart Rate** - Heart rate monitoring
- **Seconds** - Seconds display (hidden during sleep mode)

## Architecture

Each field is optimally rendered as its own independent layer, providing:

- **Battery Efficiency** - Fields only redraw when their content actually changes
- **Pixel Perfect Design** - Each layer is positioned precisely for optimal visual layout  
- **Smart Updates** - Intelligent refresh intervals based on field type (e.g., seconds update frequently, weather updates rarely)
- **Sleep Mode Optimization** - Non-essential fields are automatically hidden during sleep mode to conserve battery

## Key Goals

- **Maximum Battery Life** - Primary focus on power efficiency through intelligent drawing and layer management
- **Clean Visual Design** - Minimalist, readable interface with careful attention to typography and spacing
- **Performance** - Optimized rendering pipeline that avoids unnecessary screen updates

## Technical Details

The watch face uses a custom `RegionManager` and `Field` system where each display element is managed independently, allowing for granular control over when and how screen updates occur.