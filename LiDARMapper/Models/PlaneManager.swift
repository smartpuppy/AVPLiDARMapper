//
//  PlaneManager.swift
//  LiDARMapper
//
//  Manages plane detection and visualization
//

import ARKit
import RealityKit

@MainActor
class PlaneManager {
    private weak var appState: AppState?
    private var planeEntities: [UUID: ModelEntity] = [:]
    private let rootEntity: Entity

    // Monitoring tasks
    private var planeProducerTask: Task<Void, Never>?
    private var planeConsumerTask: Task<Void, Never>?

    // Halloween managers
    var decorationManager: DecorationManager?
    var cemeteryManager: CemeteryManager?

    init(appState: AppState, rootEntity: Entity) {
        self.appState = appState
        self.rootEntity = rootEntity

        // Initialize Halloween managers
        self.decorationManager = DecorationManager(appState: appState, rootEntity: rootEntity)
        self.cemeteryManager = CemeteryManager(appState: appState, rootEntity: rootEntity)
    }

    /// Start monitoring plane updates
    func startMonitoring() async {
        // Capture a strong local reference to AppState first (no actor hop yet)
        guard let appState = self.appState else { return }
        // Access MainActor-isolated provider
        let provider = appState.planeDetection

        print("👀 PlaneManager: Starting to monitor plane updates...")

        // Create a stream/continuation pair to bridge between background producer and MainActor consumer
        let (stream, continuation) = AsyncStream<AnchorUpdate<PlaneAnchor>>.makeStream()

        // Producer: consume provider updates off-main and yield into the stream
        planeProducerTask = Task {
            for await update in provider.anchorUpdates {
                if Task.isCancelled { break }
                continuation.yield(update)
            }
            continuation.finish()
        }

        // Consumer: run on MainActor and perform RealityKit/AppState mutations
        planeConsumerTask = Task { @MainActor in
            for await update in stream {
                self.handlePlaneUpdate(update)
            }
        }
    }

    /// Stop monitoring plane updates
    func stopMonitoring() {
        planeProducerTask?.cancel(); planeProducerTask = nil
        planeConsumerTask?.cancel(); planeConsumerTask = nil
    }

    /// Handle plane anchor updates
    private func handlePlaneUpdate(_ update: AnchorUpdate<PlaneAnchor>) {
        guard let appState = appState else { return }

        let anchor = update.anchor

        switch update.event {
        case .added:
            addPlane(anchor)
            appState.detectedPlaneCount = planeEntities.count

        case .updated:
            updatePlane(anchor)

        case .removed:
            removePlane(anchor)
            appState.detectedPlaneCount = planeEntities.count
        }
    }

    /// Add a new plane entity
    private func addPlane(_ anchor: PlaneAnchor) {
        guard let meshResource = MeshConverter.planeMeshResource(from: anchor.geometry) else {
            print("⚠️ Failed to create mesh resource for plane \(anchor.id)")
            return
        }

        guard let appState = appState else { return }

        // Get themed material based on current theme
        let material = HalloweenMaterials.themedPlaneMaterial(
            for: anchor.classification,
            alignment: anchor.alignment,
            theme: appState.theme
        )

        let entity = ModelEntity(mesh: meshResource, materials: [material])
        entity.name = "Plane-\(anchor.classification)-\(anchor.id)"

        // Set transform from anchor
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)

        // Add collision for interaction (optional)
        entity.collision = CollisionComponent(shapes: [.generateBox(width: 1, height: 0.01, depth: 1)])

        // Set initial visibility based on current setting
        entity.isEnabled = appState.showPlanes

        planeEntities[anchor.id] = entity
        rootEntity.addChild(entity)

        print("➕ Added \(anchor.alignment) plane: \(anchor.classification) (\(anchor.id))")

        // Spawn theme-specific decorations
        switch appState.theme {
        case .hauntedHouse:
            decorationManager?.spawnDecorations(for: anchor)
        case .cemetery:
            cemeteryManager?.spawnCemeteryElements(for: anchor)
        default:
            break
        }
    }

    /// Update an existing plane entity
    private func updatePlane(_ anchor: PlaneAnchor) {
        guard let entity = planeEntities[anchor.id] else { return }
        guard let appState = appState else { return }

        // Update mesh
        if let meshResource = MeshConverter.planeMeshResource(from: anchor.geometry) {
            let material = HalloweenMaterials.themedPlaneMaterial(
                for: anchor.classification,
                alignment: anchor.alignment,
                theme: appState.theme
            )
            entity.model?.mesh = meshResource
            entity.model?.materials = [material]
        }

        // Update transform
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }

    /// Remove a plane entity
    private func removePlane(_ anchor: PlaneAnchor) {
        guard let entity = planeEntities.removeValue(forKey: anchor.id) else { return }
        entity.removeFromParent()

        // Remove associated decorations
        decorationManager?.removeDecorations(for: anchor.id)
        cemeteryManager?.removeCemeteryElements(for: anchor.id)

        print("➖ Removed plane: \(anchor.id)")
    }

    /// Toggle plane visibility
    func setVisibility(_ visible: Bool) {
        for entity in planeEntities.values {
            entity.isEnabled = visible
        }
    }

    /// Clear all planes
    func clear() {
        stopMonitoring()
        for entity in planeEntities.values {
            entity.removeFromParent()
        }
        planeEntities.removeAll()

        // Clear all decorations
        decorationManager?.clearAll()
        cemeteryManager?.clearAll()
    }

    /// Update all plane materials when theme changes
    func updateTheme(_ theme: Theme) {
        // Update all existing plane materials
        for (id, entity) in planeEntities {
            // We need to get the anchor classification, but we don't have it stored
            // For now, we'll just clear and let them regenerate
            // In production, you might want to store anchor data
        }
    }
}

