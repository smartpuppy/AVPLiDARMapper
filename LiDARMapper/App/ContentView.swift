//
//  ContentView.swift
//  LiDARMapper
//
//  Main window view with controls and information display
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        @Bindable var appState = appState

        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text(headerTitle(for: appState.theme))
                    .font(.extraLargeTitle)
                    .fontWeight(.bold)

                Text(headerSubtitle(for: appState.theme))
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Status
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Circle()
                        .fill(appState.isSessionRunning ? .green : .red)
                        .frame(width: 12, height: 12)
                    Text(appState.isSessionRunning ? "AR Session Active" : "AR Session Inactive")
                        .font(.headline)
                }

                if appState.isSessionRunning {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(planeLabel(for: appState.theme)): \(appState.detectedPlaneCount)")
                        Text("\(meshLabel(for: appState.theme)): \(appState.meshAnchorCount)")
                        Text("\(positionLabel(for: appState.theme)): \(formatPosition(appState.devicePosition))")
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)

            Divider()

            // Theme Selector
            VStack(spacing: 15) {
                Text("Theme")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("Theme", selection: $appState.theme) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: appState.theme) { _, newTheme in
                    handleThemeChange(newTheme)
                }
            }
            .padding()
            .background(themeBackground(for: appState.theme))
            .cornerRadius(12)

            // Controls
            VStack(spacing: 20) {
                Text("Visualization Controls")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Toggle("Show Planes", isOn: $appState.showPlanes)
                    .toggleStyle(.switch)

                Toggle("Show Mesh", isOn: $appState.showMesh)
                    .toggleStyle(.switch)

                if appState.showMesh {
                    Picker("Mesh Style", selection: $appState.meshStyle) {
                        Text("Wireframe").tag(MeshStyle.wireframe)
                        Text("Solid").tag(MeshStyle.solid)
                        Text("Transparent").tag(MeshStyle.transparent)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(12)

            Spacer()

            // Action Button
            Button {
                Task {
                    if appState.isImmersiveSpaceOpened {
                        await dismissImmersiveSpace()
                        appState.isImmersiveSpaceOpened = false
                    } else {
                        await openImmersiveSpace(id: "ImmersiveSpace")
                        appState.isImmersiveSpaceOpened = true
                    }
                }
            } label: {
                Text(appState.isImmersiveSpaceOpened ? "Stop Mapping" : "Start Mapping")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
    }

    private func formatPosition(_ position: SIMD3<Float>?) -> String {
        guard let pos = position else { return "Unknown" }
        return String(format: "X: %.2f, Y: %.2f, Z: %.2f", pos.x, pos.y, pos.z)
    }

    // MARK: - Theme UI Helpers

    private func headerTitle(for theme: Theme) -> String {
        switch theme {
        case .normal:
            return "LiDAR Mapper"
        case .hauntedHouse:
            return "Haunted House"
        case .ectoplasm:
            return "Ectoplasm Scanner"
        case .paranormal:
            return "Paranormal Detector"
        case .cemetery:
            return "AR Cemetery"
        }
    }

    private func headerSubtitle(for theme: Theme) -> String {
        switch theme {
        case .normal:
            return "Real-time 3D Spatial Mapping"
        case .hauntedHouse:
            return "Spooky Decorations Everywhere"
        case .ectoplasm:
            return "Detecting Spectral Energy"
        case .paranormal:
            return "Tracking Supernatural Activity"
        case .cemetery:
            return "Rest in Pixels"
        }
    }

    private func planeLabel(for theme: Theme) -> String {
        switch theme {
        case .normal:
            return "Detected Planes"
        case .hauntedHouse:
            return "Haunted Surfaces"
        case .ectoplasm:
            return "Ectoplasmic Planes"
        case .paranormal:
            return "Paranormal Hot Spots"
        case .cemetery:
            return "Burial Grounds"
        }
    }

    private func meshLabel(for theme: Theme) -> String {
        switch theme {
        case .normal:
            return "Mesh Anchors"
        case .hauntedHouse:
            return "Spooky Meshes"
        case .ectoplasm:
            return "Spectral Manifestations"
        case .paranormal:
            return "Ghost Signatures"
        case .cemetery:
            return "Undead Meshes"
        }
    }

    private func positionLabel(for theme: Theme) -> String {
        switch theme {
        case .normal:
            return "Device Position"
        case .hauntedHouse:
            return "Your Location"
        case .ectoplasm:
            return "Scanner Position"
        case .paranormal:
            return "Investigator Position"
        case .cemetery:
            return "Visitor Position"
        }
    }

    private func themeBackground(for theme: Theme) -> Material {
        switch theme {
        case .normal:
            return .regularMaterial
        case .hauntedHouse:
            return .ultraThickMaterial
        case .ectoplasm:
            return .thinMaterial
        case .paranormal:
            return .thickMaterial
        case .cemetery:
            return .ultraThickMaterial
        }
    }

    private func handleThemeChange(_ newTheme: Theme) {
        // Update managers with new theme
        Task { @MainActor in
            appState.planeManager?.updateTheme(newTheme)
            appState.meshManager?.updateTheme(newTheme)
        }
    }
}

enum MeshStyle: String, Codable, CaseIterable {
    case wireframe
    case solid
    case transparent
}

enum Theme: String, Codable, CaseIterable {
    case normal
    case hauntedHouse
    case ectoplasm
    case paranormal
    case cemetery

    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .hauntedHouse: return "Haunted House"
        case .ectoplasm: return "Ectoplasm Scanner"
        case .paranormal: return "Paranormal Activity"
        case .cemetery: return "AR Cemetery"
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
