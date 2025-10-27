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

    init(appState: AppState, rootEntity: Entity) {
        self.appState = appState
        self.rootEntity = rootEntity
    }

    /// Start monitoring plane updates
    func startMonitoring() async {
        guard let appState = appState else { return }

        print("👀 PlaneManager: Starting to monitor plane updates...")

        for await update in appState.planeDetection.anchorUpdates {
            await handlePlaneUpdate(update)
        }
    }

    /// Handle plane anchor updates
    private func handlePlaneUpdate(_ update: AnchorUpdate<PlaneAnchor>) async {
        guard let appState = appState else { return }

        let anchor = update.anchor

        switch update.event {
        case .added:
            await addPlane(anchor)
            appState.detectedPlaneCount = planeEntities.count

        case .updated:
            await updatePlane(anchor)

        case .removed:
            removePlane(anchor)
            appState.detectedPlaneCount = planeEntities.count
        }
    }

    /// Add a new plane entity
    private func addPlane(_ anchor: PlaneAnchor) async {
        guard let meshResource = MeshConverter.planeMeshResource(from: anchor.geometry) else {
            print("⚠️ Failed to create mesh resource for plane \(anchor.id)")
            return
        }

        let material = MaterialProvider.planeMaterial(
            for: anchor.classification,
            alignment: anchor.alignment
        )

        let entity = ModelEntity(mesh: meshResource, materials: [material])
        entity.name = "Plane-\(anchor.classification)-\(anchor.id)"

        // Set transform from anchor
        entity.transform = Transform(matrix: anchor.originFromAnchorTransform)

        // Add collision for interaction (optional)
        entity.collision = CollisionComponent(shapes: [.generateBox(width: 1, height: 0.01, depth: 1)])

        // Set initial visibility based on current setting
        entity.isEnabled = appState?.showPlanes ?? true

        planeEntities[anchor.id] = entity
        rootEntity.addChild(entity)

        print("➕ Added \(anchor.alignment) plane: \(anchor.classification) (\(anchor.id))")
    }

    /// Update an existing plane entity
    private func updatePlane(_ anchor: PlaneAnchor) async {
        guard let entity = planeEntities[anchor.id] else { return }

        // Update mesh
        if let meshResource = MeshConverter.planeMeshResource(from: anchor.geometry) {
            let material = MaterialProvider.planeMaterial(
                for: anchor.classification,
                alignment: anchor.alignment
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
        for entity in planeEntities.values {
            entity.removeFromParent()
        }
        planeEntities.removeAll()
    }
}
