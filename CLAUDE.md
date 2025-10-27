# CLAUDE.md - AVPLiDARMapper Project Guide

## Project Overview

**AVPLiDARMapper** is a proof-of-concept visionOS application demonstrating real-time 3D spatial mapping for Apple Vision Pro using ARKit and RealityKit.

**Key Purpose:** Showcase ARKit's plane detection and scene reconstruction capabilities with live visualization of the physical environment.

**Status:** Active development / Proof of concept
**Platform:** visionOS 2.0+ (Apple Vision Pro only - simulator not supported)
**Language:** Swift 6.0
**Architecture:** SwiftUI + RealityKit + ARKit

---

## Core Technologies

### ARKit Session Components
- **ARKitSession** - Manages AR data providers
- **WorldTrackingProvider** - Device position/orientation tracking
- **PlaneDetectionProvider** - Surface detection (horizontal/vertical/ceiling)
- **SceneReconstructionProvider** - Detailed mesh generation

### RealityKit
- **ModelEntity** - 3D visualization of detected geometry
- **MeshResource** - Converted from ARKit geometry
- **Materials** - Color-coded by surface classification
- **CollisionComponent** - Physics-ready shapes

### SwiftUI
- **@Observable** - Modern state management (Swift 6.0)
- **WindowGroup** - Control panel window
- **ImmersiveSpace** - Unbounded mixed reality content
- **.mixed** immersion style - AR overlays with passthrough

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│ LiDARMapperApp.swift                            │
│ - App entry point                               │
│ - Scene configuration (WindowGroup + Immersive) │
└────────────┬────────────────────────────────────┘
             │
             ├─> ContentView.swift (Control Panel)
             │   - UI controls and statistics
             │   - Toggle visualization options
             │
             └─> ImmersiveView.swift (3D Space)
                 - RealityKit content
                 - AR session management
                 │
                 ├─> AppState.swift (Central State)
                 │   - ARKit session + providers
                 │   - Device tracking data
                 │   - Visualization settings
                 │
                 ├─> PlaneManager.swift
                 │   - Monitors PlaneAnchor updates
                 │   - Creates/updates plane entities
                 │   - Handles visibility toggles
                 │
                 └─> MeshManager.swift
                     - Monitors MeshAnchor updates
                     - Creates/updates mesh entities
                     - Handles style changes
```

### Data Flow
1. **ARKitSession** runs with providers (world tracking, plane detection, scene reconstruction)
2. **Providers** emit anchor updates asynchronously
3. **Managers** monitor anchor updates and create RealityKit entities
4. **AppState** tracks counts and device position
5. **ContentView** displays statistics and controls
6. **ImmersiveView** renders 3D content in mixed reality

---

## Project Structure

```
LiDARMapper/
├── App/
│   ├── LiDARMapperApp.swift       # Entry point, scene config
│   └── ContentView.swift          # Control panel UI
├── Models/
│   ├── AppState.swift             # @Observable state manager
│   ├── PlaneManager.swift         # Plane detection logic
│   └── MeshManager.swift          # Mesh reconstruction logic
├── Views/
│   └── ImmersiveView.swift        # 3D immersive space
└── Utilities/
    ├── MeshConverter.swift        # ARKit → RealityKit conversion
    └── MaterialProvider.swift     # Visualization materials
```

---

## Key Patterns & Conventions

### State Management
- **@Observable** macro for AppState (Swift 6.0+)
- **@Environment** for passing state to views
- **@Bindable** for two-way bindings in views
- **@MainActor** on managers to ensure UI thread safety

### Async Patterns
```swift
// Monitoring anchor updates
for await update in provider.anchorUpdates {
    await handleUpdate(update)
}
```

### Entity Lifecycle
1. **Added** - Create entity, add to scene, update count
2. **Updated** - Update mesh/transform in place
3. **Removed** - Remove from parent, delete reference, update count

### Visibility Control
- **Initial state**: Entities created with `isEnabled` based on current toggle
- **Runtime toggle**: Loop through entities and set `isEnabled`
- **Pattern**: Always respect AppState settings when creating entities

### Material Coding
- 🔵 Blue - Floors (horizontal)
- 🟠 Orange - Walls (vertical)
- 🟣 Purple - Ceilings
- 🟢 Green - Tables/desks
- 🟡 Yellow - Seats/chairs
- 🔷 Cyan - Mesh reconstruction (wireframe)

---

## Development Workflow

### Project Generation
This project uses **XcodeGen** for project file management:

```bash
# Install XcodeGen
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Open project
open AVPLiDARMapper.xcodeproj
```

**Important:** After modifying `project.yml`, always regenerate the project.

### Building & Running

**Requirements:**
- Physical Apple Vision Pro (simulator not supported)
- Xcode 16+ with visionOS 2.0 SDK
- macOS Sequoia 15.0+
- Developer account (free or paid)

**Setup:**
1. Enable Developer Mode on Vision Pro: Settings → Privacy & Security → Developer Mode
2. Enable pairing: Settings → General → Remote Devices
3. Pair in Xcode: Window → Devices and Simulators (⇧⌘2)
4. Both devices must be on same WiFi network

**First build:**
- Takes 5-10 minutes over WiFi
- Grant World Sensing permission when prompted
- Trust developer certificate: Settings → General → VPN & Device Management

### Testing

**Manual testing checklist:**
- [ ] Plane detection works (floors, walls, ceilings)
- [ ] Mesh reconstruction appears within 10-15 seconds
- [ ] Toggle controls work (Show Planes, Show Mesh)
- [ ] Mesh style switching works (wireframe/solid/transparent)
- [ ] Statistics update in real-time
- [ ] Content persists when walking around (unbounded space)
- [ ] Stop/Start mapping works correctly

**Known limitations:**
- Requires well-lit environments
- Initial detection may take 5-10 seconds
- Large spaces generate many anchors (memory consideration)
- No simulator support (requires real sensors)

---

## Common Development Tasks

### Adding a New Surface Classification

1. Update `MaterialProvider.swift` with new color
2. Test with appropriate physical surface
3. Update README color legend

### Modifying Window Layout

**Best practice (visionOS 2.0):**
- Set size at **WindowGroup** level using `.defaultSize()`
- Use `.windowResizability()` for adaptive behavior
- Avoid hardcoded `.frame()` on ContentView
- Let SwiftUI handle content-driven sizing

Example:
```swift
WindowGroup {
    ContentView()
}
.defaultSize(width: 600, height: 700)
.windowResizability(.contentSize)
```

### Adding New Visualization Options

1. Add property to `AppState.swift`
2. Add UI control in `ContentView.swift`
3. Implement behavior in appropriate manager
4. Update existing entities if needed

### Debugging AR Session Issues

**Common problems:**
- Authorization denied → Check World Sensing permission
- No planes detected → Wait 5-10s, ensure good lighting
- No mesh appearing → Wait 10-15s, toggle mesh on/off
- Content fades when walking → Verify `.mixed` immersion style

**Logging patterns:**
- `🚀` Session start
- `✅` Success
- `❌` Error
- `⚠️` Warning
- `➕` Entity added
- `➖` Entity removed
- `👀` Monitoring started

---

## Important Notes

### Race Conditions to Avoid

**Visibility synchronization:**
When creating new entities, always set initial `isEnabled` based on current AppState:

```swift
// ✅ Good - respects current setting
entity.isEnabled = appState?.showPlanes ?? true

// ❌ Bad - creates then hides (causes flicker)
entity.isEnabled = true
// ... later ...
entity.isEnabled = appState.showPlanes
```

### Memory Management

**Current implementation:**
- Unlimited mesh/plane storage (all kept in memory)
- No distance-based culling
- No LOD (level of detail)

**For production:**
- Implement distance-based culling
- Add memory limits on anchor count
- Consider LOD for distant objects
- Batch mesh updates during rapid changes

### Performance Considerations

- Device position updates: 100ms interval (10 Hz)
- Collision shapes generated asynchronously
- Material updates happen immediately on toggle
- Mesh conversion uses async/await pattern

### visionOS Immersion Styles

**Current:** `.mixed` - Unbounded AR with passthrough
- Content persists throughout entire space
- User can walk around freely
- Overlays stay at physical locations

**Alternatives:**
- `.progressive` - Partial immersion with dial control
- `.full` - Complete immersion, no passthrough

---

## Git & Collaboration

### Commit Conventions
- Follow existing pattern from Claude Code commits
- Include descriptive commit messages
- Reference issue numbers if applicable
- Use conventional commit prefixes: `feat:`, `fix:`, `docs:`, `refactor:`

### Branch Naming
- Feature branches: `feat/description`
- Bug fixes: `fix/description`
- Claude Code uses: `claude/description-{id}`

### PR Guidelines
- One logical change per PR
- Include description of problem + solution
- Test on actual Vision Pro before submitting
- Update documentation if needed

---

## Code Style Guidelines

### Swift Conventions
- Use explicit types for complex expressions
- Prefer `guard` for early returns
- Use `async/await` over completion handlers
- Mark concurrent code with `@MainActor` when needed

### RealityKit Patterns
- Name entities descriptively: `"Plane-horizontal-{id}"`
- Always remove entities from parent before dereferencing
- Use `CollisionComponent` for interactive entities
- Update transforms using `Transform(matrix:)` from ARKit

### SwiftUI Patterns
- Extract complex views into separate files
- Use `@Environment` for dependency injection
- Keep computed properties in ViewModels
- Prefer composition over inheritance

---

## Resources

### Essential Documentation
- [ARKit in visionOS](https://developer.apple.com/documentation/arkit/arkit-in-visionos)
- [RealityKit Scene Understanding](https://developer.apple.com/documentation/realitykit/realitykit-scene-understanding)
- [visionOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/visionos)

### WWDC Sessions
- WWDC 2025-317: "What's new in visionOS 2.0"
- WWDC 2024-10153: "Dive deep into volumes and immersive spaces"
- WWDC 2024-10100: "Create enhanced spatial computing experiences with ARKit"

### Community
- [visionOS-Sampler](https://github.com/shu223/visionOS-Sampler) - Code examples
- [Apple Sample Code](https://developer.apple.com/sample-code/visionos/)

---

## Roadmap & Future Ideas

Potential enhancements documented in README.md:
- Mesh export to USDZ/OBJ
- Spatial persistence (save/load maps)
- Shared spatial anchors for multiplayer
- Object placement with physics
- Room measurement tools
- Hand tracking integration

---

## Contact & Contribution

**Maintained by:** SmartPuppy Software
**Email:** west@smartpuppysoftware.com
**GitHub:** [@smartpuppy](https://github.com/smartpuppy)

**Contributing:**
1. Fork the repository
2. Create feature branch
3. Test on physical Vision Pro
4. Submit PR with description

---

## License

MIT License - See LICENSE file for details

---

**Last Updated:** October 27, 2025
**Project Version:** 1.0.0
**visionOS Target:** 2.0+

---

## Quick Reference

### Start Development Session
```bash
cd /Users/west/Code/AVPLiDARMapper
xcodegen generate  # If project.yml changed
open AVPLiDARMapper.xcodeproj
```

### Key Files to Know
- `AppState.swift` - Central truth for all state
- `PlaneManager.swift` - Plane detection logic
- `MeshManager.swift` - Mesh reconstruction logic
- `ContentView.swift` - UI and controls
- `ImmersiveView.swift` - 3D rendering setup

### Common Commands
```bash
# Regenerate project
xcodegen generate

# Check git status
git status

# Run on Vision Pro (in Xcode)
⌘R

# View devices
Window → Devices and Simulators (⇧⌘2)
```
