//
//  AppState.swift
//  LiDARMapper
//
//  Central state manager for ARKit session and spatial tracking
//

import ARKit
import RealityKit
import SwiftUI

@MainActor
@Observable
class AppState {
    // AR Session components
    let arkitSession = ARKitSession()
    let worldTracking = WorldTrackingProvider()
    let planeDetection = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
    let sceneReconstruction = SceneReconstructionProvider(modes: [.classification])

    // Managers
    var planeManager: PlaneManager?
    var meshManager: MeshManager?

    // Session state
    var isSessionRunning = false
    var isImmersiveSpaceOpened = false
    var isAuthorized = false

    // Tracking data
    var devicePosition: SIMD3<Float>?
    var detectedPlaneCount = 0
    var meshAnchorCount = 0

    // Visualization settings
    var showPlanes = true
    var showMesh = true
    var meshStyle: MeshStyle = .wireframe

    init() {
        Task {
            await requestAuthorization()
        }
    }

    /// Request ARKit authorization for world sensing
    func requestAuthorization() async {
        let result = await arkitSession.requestAuthorization(for: [.worldSensing])

        for (authType, authStatus) in result {
            print("Authorization for \(authType): \(authStatus)")
            if authStatus == .allowed {
                isAuthorized = true
            }
        }

        if !isAuthorized {
            print("⚠️ World sensing authorization denied")
        }
    }

    /// Start the AR session with all providers
    func startSession() async {
        guard isAuthorized else {
            print("❌ Cannot start session: not authorized")
            return
        }

        do {
            print("🚀 Starting ARKit session...")
            try await arkitSession.run([worldTracking, planeDetection, sceneReconstruction])
            isSessionRunning = true
            print("✅ ARKit session running")
        } catch {
            print("❌ Failed to start ARKit session: \(error)")
        }
    }

    /// Stop the AR session
    func stopSession() {
        arkitSession.stop()
        isSessionRunning = false
        devicePosition = nil
        detectedPlaneCount = 0
        meshAnchorCount = 0
        print("⏹️ ARKit session stopped")
    }

    /// Update device position from world tracking
    func updateDevicePosition() {
        guard let pose = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return
        }

        let transform = pose.originFromAnchorTransform
        devicePosition = SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
    }
}
