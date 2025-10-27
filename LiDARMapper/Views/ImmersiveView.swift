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

    @State private var planeTask: Task<Void, Never>?
    @State private var meshTask: Task<Void, Never>?
    @State private var deviceTask: Task<Void, Never>?

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

            // Small warm-up delay to allow providers to reach running state
            try? await Task.sleep(for: .milliseconds(200))

            // Start monitoring anchors in background tasks
            planeTask = Task {
                await planeManager.startMonitoring()
            }

            meshTask = Task {
                await meshManager.startMonitoring()
            }

            // Start device position tracking
            deviceTask = Task {
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
            // Cancel background tasks BEFORE stopping the session
            planeTask?.cancel(); planeTask = nil
            meshTask?.cancel(); meshTask = nil
            deviceTask?.cancel(); deviceTask = nil

            // Cleanup when view disappears
            appState.stopSession()
            appState.planeManager?.clear()
            appState.meshManager?.clear()
        }
    }

    /// Continuously track device position
    private func trackDevicePosition() async {
        var firstSampleObtained = false

        while appState.isSessionRunning && !Task.isCancelled {
            if let _ = appState.worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) {
                appState.updateDevicePosition()
                firstSampleObtained = true
            } else if !firstSampleObtained {
                // Providers may still be spinning up; avoid spamming warnings
                try? await Task.sleep(for: .milliseconds(150))
                continue
            }

            try? await Task.sleep(for: .milliseconds(100))
        }
    }
}

#Preview {
    ImmersiveView()
        .environment(AppState())
}
