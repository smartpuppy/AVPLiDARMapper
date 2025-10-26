# AVPLiDARMapper

**Real-Time 3D Spatial Mapping for Apple Vision Pro**

A native visionOS application that demonstrates real-time 3D environment mapping using the Vision Pro's LiDAR sensors, ARKit scene understanding, and RealityKit visualization.

[![visionOS](https://img.shields.io/badge/visionOS-2.0+-blue)](https://developer.apple.com/visionos/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-Apple%20Vision%20Pro-lightgrey)](https://www.apple.com/apple-vision-pro/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

![AVPLiDARMapper Demo](https://img.shields.io/badge/Demo-Proof%20of%20Concept-yellow)

---

## Overview

AVPLiDARMapper is a proof-of-concept application that showcases the spatial computing capabilities of Apple Vision Pro. It provides real-time visualization of ARKit's plane detection and scene reconstruction features, creating a live 3D map of your environment with color-coded surfaces and detailed mesh reconstruction.

**Key Highlights:**
- 🌍 **Unbounded Mixed Reality**: AR overlays persist as you walk around your entire space
- 🎨 **Color-Coded Surfaces**: Automatic classification (floors, walls, ceilings, furniture)
- 🔷 **Multiple Visualization Modes**: Wireframe, solid, and transparent mesh rendering
- 📊 **Real-Time Statistics**: Live plane/mesh counts and device position tracking
- ⚡ **Optimized for visionOS 2.0**: Uses latest ARKit and RealityKit APIs

---

## Features

### Core Capabilities

- **Real-Time Plane Detection**
  - Detects horizontal surfaces (floors, tables, desks)
  - Detects vertical surfaces (walls, doors, windows)
  - Identifies ceiling planes
  - Color-coded by surface type

- **Scene Reconstruction**
  - Generates detailed 3D mesh from Vision Pro sensors
  - Physics-ready collision shapes
  - Classification-based visualization
  - Adaptive mesh updates

- **Live Device Tracking**
  - Shows device position in 3D space (X, Y, Z coordinates)
  - Continuous world tracking
  - Automatic coordinate updates

- **Visualization Controls**
  - Toggle plane visibility
  - Toggle mesh visibility
  - Switch between wireframe/solid/transparent rendering
  - Real-time statistics display

### visionOS 2.0 Technologies

- ✅ **ARKitSession** - Manages ARKit data providers
- ✅ **WorldTrackingProvider** - Device position and orientation tracking
- ✅ **PlaneDetectionProvider** - Surface detection and classification
- ✅ **SceneReconstructionProvider** - Detailed mesh generation
- ✅ **RealityKit** - 3D rendering and physics simulation
- ✅ **SwiftUI** - Modern UI with immersive spaces
- ✅ **Mixed Immersion Style** - Unbounded AR content with passthrough

---

## Screenshots

### Color-Coded Surface Detection
- 🔵 **Blue** - Floors and horizontal surfaces
- 🟠 **Orange** - Walls and vertical surfaces
- 🟣 **Purple** - Ceilings
- 🟢 **Green** - Tables and desks
- 🟡 **Yellow** - Seats and chairs

### Visualization Modes
- **Wireframe** - See the triangulated mesh structure
- **Solid** - Opaque colored mesh with lighting
- **Transparent** - Semi-transparent overlay

---

## Requirements

### Hardware
- **Apple Vision Pro** (physical device required)
- Simulator **not supported** (ARKit features require real sensors)

### Software
- **Xcode 16+** with visionOS 2.0 SDK
- **macOS Sequoia 15.0+**
- **visionOS 2.0+** on your Vision Pro
- **Apple Developer Account** (free or paid)

---

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/smartpuppy/AVPLiDARMapper.git
cd AVPLiDARMapper
```

### 2. Generate Xcode Project

This project uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) for project generation:

```bash
# Install XcodeGen if needed
brew install xcodegen

# Generate the Xcode project
xcodegen generate

# Open the project
open AVPLiDARMapper.xcodeproj
```

### 3. Configure Code Signing

1. In Xcode, select the **AVPLiDARMapper** target
2. Go to **Signing & Capabilities**
3. Select your **Team** from the dropdown
4. Xcode will automatically provision the app

### 4. Connect Your Vision Pro

#### Enable Developer Mode on Vision Pro:
1. **Settings → Privacy & Security → Developer Mode** - Toggle ON
2. Device will restart
3. **Settings → General → Remote Devices** - Enable pairing mode

#### Pair with Xcode:
1. In Xcode: **Window → Devices and Simulators** (⇧⌘2)
2. Your Vision Pro should appear
3. Click it and follow pairing prompts
4. Confirm pairing code on both devices

**Note**: Both devices must be on the same WiFi network.

### 5. Build and Run

1. Select your **Vision Pro** as the run destination
2. Press **⌘R** to build and run
3. First install may take 5-10 minutes over WiFi

### 6. Grant Permissions

On first launch:
- Grant **World Sensing** permission when prompted
- Trust your developer certificate:
  - **Settings → General → VPN & Device Management**
  - Tap your profile → Trust

---

## Usage

### Getting Started

1. Launch the app - control panel window appears
2. Tap **"Start Mapping"** to enter immersive mode
3. AR session starts automatically
4. Look around slowly to let ARKit detect surfaces

### What You'll See

**Plane Detection:**
- Colored translucent overlays on detected surfaces
- Real-time classification of surface types
- Planes persist at their physical locations

**3D Mesh Reconstruction:**
- Cyan wireframe showing detailed room geometry
- Updates in real-time as you look around
- Toggle between visualization styles

**Statistics Panel:**
- AR session status indicator (green = active)
- Number of detected planes
- Number of mesh anchors
- Current device position (X, Y, Z)

### Controls

- **Show Planes** - Toggle plane detection overlays
- **Show Mesh** - Toggle 3D mesh visualization
- **Mesh Style** - Choose Wireframe/Solid/Transparent
- **Stop Mapping** - Exit immersive mode

### Tips for Best Results

- **Lighting**: Works best in well-lit environments
- **Movement**: Look around slowly for initial scan
- **Coverage**: Actively look at floors, walls, furniture
- **Unbounded**: Walk throughout your space - overlays persist!

---

## Project Structure

```
AVPLiDARMapper/
├── LiDARMapper/
│   ├── App/
│   │   ├── LiDARMapperApp.swift       # App entry point & scene config
│   │   └── ContentView.swift          # Control panel UI
│   ├── Models/
│   │   ├── AppState.swift             # AR session state management
│   │   ├── PlaneManager.swift         # Plane detection logic
│   │   └── MeshManager.swift          # Mesh reconstruction logic
│   ├── Views/
│   │   └── ImmersiveView.swift        # 3D immersive space
│   ├── Utilities/
│   │   ├── MeshConverter.swift        # ARKit → RealityKit conversion
│   │   └── MaterialProvider.swift    # Visualization materials
│   └── Info.plist                     # App configuration & permissions
├── project.yml                         # XcodeGen configuration
├── README.md                          # This file
├── LICENSE                            # MIT License
└── .gitignore                         # Git ignore rules
```

### Architecture

**App Layer** (`App/`)
- SwiftUI app structure
- Window and immersive space definitions
- User interface controls

**Model Layer** (`Models/`)
- `AppState`: Centralized state using @Observable
- `PlaneManager`: Handles plane anchor lifecycle
- `MeshManager`: Handles mesh anchor lifecycle

**View Layer** (`Views/`)
- `ImmersiveView`: RealityKit content and AR session

**Utilities** (`Utilities/`)
- Mesh conversion from ARKit to RealityKit formats
- Material generation for visualization

---

## Technical Details

### ARKit Session Flow

1. Request world sensing authorization
2. Create `ARKitSession` with providers:
   - `WorldTrackingProvider` - Device position
   - `PlaneDetectionProvider` - Surface detection
   - `SceneReconstructionProvider` - Mesh generation
3. Run session with mixed immersion style
4. Monitor anchor updates asynchronously
5. Convert anchors to RealityKit entities
6. Render in unbounded immersive space

### Mesh Conversion Pipeline

```
ARKit MeshAnchor/PlaneAnchor
    ↓
Extract geometry (vertices, normals, faces)
    ↓
Create RealityKit MeshDescriptor
    ↓
Generate MeshResource
    ↓
Apply material based on classification
    ↓
Create ModelEntity with collision shape
    ↓
Add to scene at physical location
```

### Key visionOS 2.0 Features Used

- **Mixed Immersion Style**: Unbounded AR content with passthrough
- **@Observable Macro**: Modern Swift state management
- **Async/Await ARKit**: Asynchronous anchor monitoring
- **RealityKit Physics**: Collision shapes for realistic interaction
- **Scene Manifest**: Multi-scene support for window + immersive space

---

## Performance Considerations

### Current Implementation

- **Device Position Updates**: 100ms interval (10 Hz)
- **Mesh Storage**: Unlimited (all detected meshes kept in memory)
- **Collision Shapes**: Generated asynchronously per anchor
- **Visualization**: Real-time material updates on toggle

### Optimization Opportunities

For production apps, consider:
- Distance-based mesh culling (remove distant anchors)
- Level-of-detail (LOD) for far objects
- Batch mesh updates during rapid changes
- Memory limits on total mesh count

### Known Limitations

1. **Simulator Not Supported** - Requires physical Vision Pro
2. **Lighting Dependent** - Best in well-lit environments
3. **Initial Detection Delay** - May take 5-10 seconds to start
4. **Memory Usage** - Large spaces generate many anchors

---

## Troubleshooting

### "Authorization denied"
- Check: **Settings → Privacy & Security → World Sensing**
- Ensure permission granted for AVPLiDARMapper

### No planes detected
- Look around slowly for 5-10 seconds
- Ensure adequate lighting
- Point at distinct surfaces (not blank walls)

### No mesh appearing
- Wait 10-15 seconds for initial reconstruction
- Toggle mesh visibility off/on
- Try different mesh styles
- Check that mesh toggle is enabled

### App won't install
- Verify code signing configured
- Check WiFi network (same for Mac and Vision Pro)
- Disable VPN if active
- Try restarting both devices

### Content fades when walking
- **Fixed in current version!** Uses `.mixed` immersion style
- If still experiencing: Clean build and reinstall

---

## Development

### Building from Source

```bash
# Clone repository
git clone https://github.com/smartpuppy/AVPLiDARMapper.git
cd AVPLiDARMapper

# Generate Xcode project
xcodegen generate

# Open in Xcode
open AVPLiDARMapper.xcodeproj
```

### Project Configuration

- **Deployment Target**: visionOS 2.0+
- **Swift Version**: 6.0
- **Architecture**: arm64 (Apple Silicon)
- **Code Signing**: Automatic (set your team)

### Regenerating Project

After modifying `project.yml`:

```bash
xcodegen generate
```

This regenerates the `.xcodeproj` file with your changes.

---

## Roadmap

Potential enhancements for future versions:

- [ ] Mesh export to USDZ/OBJ format
- [ ] Spatial persistence (save/load maps)
- [ ] Shared spatial anchors for multiplayer
- [ ] Object placement with physics simulation
- [ ] Room measurement and dimensions
- [ ] Custom mesh filtering and cleanup
- [ ] Recording and playback of spatial data
- [ ] Integration with spatial audio
- [ ] Hand tracking integration
- [ ] Multi-room support with room transitions

---

## Contributing

Contributions are welcome! This is a proof-of-concept project intended for learning and experimentation.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Reporting Issues

Please use GitHub Issues to report bugs or request features. Include:
- visionOS version
- Vision Pro model
- Steps to reproduce
- Expected vs actual behavior

---

## Resources

### Apple Documentation

- [ARKit in visionOS](https://developer.apple.com/documentation/arkit/arkit-in-visionos)
- [RealityKit Scene Understanding](https://developer.apple.com/documentation/realitykit/realitykit-scene-understanding)
- [Creating Immersive Spaces](https://developer.apple.com/documentation/visionOS/creating-immersive-spaces-in-visionos-with-swiftui)
- [SpatialTrackingSession](https://developer.apple.com/documentation/realitykit/spatialtrackingsession)

### WWDC Sessions

- WWDC 2025-317: "What's new in visionOS 2.0"
- WWDC 2024-10153: "Dive deep into volumes and immersive spaces"
- WWDC 2024-10100: "Create enhanced spatial computing experiences with ARKit"
- WWDC 2023-10082: "Meet ARKit for spatial computing"

### Related Projects

- [visionOS-Sampler](https://github.com/shu223/visionOS-Sampler) - ARKit examples
- [Apple Sample Code](https://developer.apple.com/sample-code/visionos/)

---

## Credits

### Original Implementation

Created by **Claude Code** (Anthropic) on October 25, 2025

- Commit: `25a0c94`
- Author: Claude <noreply@anthropic.com>
- Platform: Claude Code in the cloud

### Refinements & Bug Fixes

Enhanced by **Claude Code** (local instance) on October 25-26, 2025:
- Fixed visionOS 2.0 API compatibility issues
- Corrected Info.plist scene manifest configuration
- Changed to `.mixed` immersion style for unbounded experience
- Updated documentation and project structure

### Maintained By

**SmartPuppy Software**
- GitHub: [@smartpuppy](https://github.com/smartpuppy)
- Email: west@smartpuppysoftware.com

---

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 SmartPuppy Software

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Acknowledgments

- **Apple** - For visionOS, ARKit, and RealityKit frameworks
- **Anthropic** - For Claude Code development platform
- **visionOS Community** - For examples and best practices

---

## Disclaimer

This is a **proof-of-concept / demo application** for educational and experimental purposes.

**Not recommended for production use without:**
- Comprehensive error handling
- Memory management optimization
- Thorough testing across environments
- Accessibility features
- Performance profiling

Use at your own risk. The authors are not responsible for any issues arising from use of this software.

---

**Built with ❤️ for Apple Vision Pro**

*Making spatial computing accessible to developers*

---

## Star History

If you find this project useful, please consider giving it a ⭐ on GitHub!

---

**Last Updated**: October 26, 2025
**Version**: 1.0.0
**Status**: Active Development
