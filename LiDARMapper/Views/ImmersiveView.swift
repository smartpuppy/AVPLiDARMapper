//
//  ImmersiveView.swift
//  LiDARMapper
//
//  Main immersive view for real-time 3D mapping
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        RealityView { content in
            // Create root entity for all spatial content
            let rootEntity = Entity()
            rootEntity.name = "LiDARMapperRoot"
            content.add(rootEntity)

            // Initialize managers
            let planeManager = PlaneManager(appState: appState, rootEntity: rootEntity)
            let meshManager = MeshManager(appState: appState, rootEntity: rootEntity)

            appState.planeManager = planeManager
            appState.meshManager = meshManager

            // Start AR session
            await appState.startSession()

            // Start monitoring anchors in background tasks
            Task {
                await planeManager.startMonitoring()
            }

            Task {
                await meshManager.startMonitoring()
            }

            // Start device position tracking
            Task {
                await trackDevicePosition()
            }

            print("✅ ImmersiveView setup complete")

        } update: { content in
            // Update visualization based on settings
            if let planeManager = appState.planeManager {
                planeManager.setVisibility(appState.showPlanes)
            }

            if let meshManager = appState.meshManager {
                meshManager.setVisibility(appState.showMesh)
                meshManager.updateStyle(appState.meshStyle)
            }
        }
        .onDisappear {
            // Cleanup when view disappears
            appState.stopSession()
            appState.planeManager?.clear()
            appState.meshManager?.clear()
        }
    }

    /// Continuously track device position
    private func trackDevicePosition() async {
        while appState.isSessionRunning {
            appState.updateDevicePosition()
            try? await Task.sleep(for: .milliseconds(100))
        }
    }
}

#Preview {
    ImmersiveView()
        .environment(AppState())
}
