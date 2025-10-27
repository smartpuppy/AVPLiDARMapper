//
//  DecorationManager.swift
//  LiDARMapper
//
//  Manages spawning Halloween decorations based on detected planes
//

import ARKit
import RealityKit

@MainActor
class DecorationManager {
    private weak var appState: AppState?
    private var decorationEntities: [UUID: [ModelEntity]] = [:]
    private let rootEntity: Entity

    init(appState: AppState, rootEntity: Entity) {
        self.appState = appState
        self.rootEntity = rootEntity
    }

    /// Spawn decorations for a plane anchor based on classification
    func spawnDecorations(for anchor: PlaneAnchor) {
        guard let appState = appState else { return }

        // Only spawn decorations in haunted house theme
        guard appState.theme == .hauntedHouse else { return }

        var entities: [ModelEntity] = []

        switch (anchor.classification, anchor.alignment) {
        case (.floor, _):
            // Spawn pumpkins on floors
            if let pumpkin = createPumpkin(at: anchor) {
                entities.append(pumpkin)
            }

        case (.ceiling, _):
            // Spawn bats on ceilings
            if let bat = createBat(at: anchor) {
                entities.append(bat)
            }

        case (.wall, _):
            // Spawn ghosts on walls
            if let ghost = createGhost(at: anchor) {
                entities.append(ghost)
            }

        default:
            break
        }

        // Store and add to scene
        if !entities.isEmpty {
            decorationEntities[anchor.id] = entities
            for entity in entities {
                rootEntity.addChild(entity)
            }
            print("🎃 Spawned \(entities.count) decoration(s) for \(anchor.classification)")
        }
    }

    /// Remove decorations for a specific plane anchor
    func removeDecorations(for anchorID: UUID) {
        guard let entities = decorationEntities.removeValue(forKey: anchorID) else { return }
        for entity in entities {
            entity.removeFromParent()
        }
        print("🎃 Removed decorations for anchor \(anchorID)")
    }

    /// Clear all decorations
    func clearAll() {
        for entities in decorationEntities.values {
            for entity in entities {
                entity.removeFromParent()
            }
        }
        decorationEntities.removeAll()
    }

    // MARK: - Decoration Creators

    private func createPumpkin(at anchor: PlaneAnchor) -> ModelEntity? {
        // Create a pumpkin using a sphere
        let pumpkin = ModelEntity(
            mesh: .generateSphere(radius: 0.15),
            materials: [HalloweenMaterials.pumpkinMaterial()]
        )

        // Position on the plane surface (slightly above to avoid z-fighting)
        var transform = Transform(matrix: anchor.originFromAnchorTransform)
        transform.translation.y += 0.15 // Raise it to sit on surface

        // Add some randomness to position within the plane
        let randomX = Float.random(in: -0.3...0.3)
        let randomZ = Float.random(in: -0.3...0.3)
        transform.translation.x += randomX
        transform.translation.z += randomZ

        pumpkin.transform = transform
        pumpkin.name = "Pumpkin-\(anchor.id)"

        // Add glow eyes (simplified as small spheres)
        let leftEye = ModelEntity(
            mesh: .generateSphere(radius: 0.03),
            materials: [HalloweenMaterials.pumpkinGlowMaterial()]
        )
        leftEye.position = SIMD3<Float>(-0.05, 0.05, 0.14)

        let rightEye = ModelEntity(
            mesh: .generateSphere(radius: 0.03),
            materials: [HalloweenMaterials.pumpkinGlowMaterial()]
        )
        rightEye.position = SIMD3<Float>(0.05, 0.05, 0.14)

        pumpkin.addChild(leftEye)
        pumpkin.addChild(rightEye)

        return pumpkin
    }

    private func createBat(at anchor: PlaneAnchor) -> ModelEntity? {
        // Create a bat using a box with wings (simplified)
        let body = ModelEntity(
            mesh: .generateBox(width: 0.08, height: 0.04, depth: 0.06),
            materials: [HalloweenMaterials.batMaterial()]
        )

        // Create wings
        let leftWing = ModelEntity(
            mesh: .generateBox(width: 0.12, height: 0.01, depth: 0.08),
            materials: [HalloweenMaterials.batMaterial()]
        )
        leftWing.position = SIMD3<Float>(-0.08, 0, 0)
        leftWing.orientation = simd_quatf(angle: .pi / 6, axis: SIMD3<Float>(0, 0, 1))

        let rightWing = ModelEntity(
            mesh: .generateBox(width: 0.12, height: 0.01, depth: 0.08),
            materials: [HalloweenMaterials.batMaterial()]
        )
        rightWing.position = SIMD3<Float>(0.08, 0, 0)
        rightWing.orientation = simd_quatf(angle: -.pi / 6, axis: SIMD3<Float>(0, 0, 1))

        body.addChild(leftWing)
        body.addChild(rightWing)

        // Position on ceiling (hanging down)
        var transform = Transform(matrix: anchor.originFromAnchorTransform)
        transform.translation.y -= 0.1 // Hang down from ceiling

        // Add some randomness
        let randomX = Float.random(in: -0.4...0.4)
        let randomZ = Float.random(in: -0.4...0.4)
        transform.translation.x += randomX
        transform.translation.z += randomZ

        body.transform = transform
        body.name = "Bat-\(anchor.id)"

        return body
    }

    private func createGhost(at anchor: PlaneAnchor) -> ModelEntity? {
        // Create a ghost using a sphere with a tail
        let head = ModelEntity(
            mesh: .generateSphere(radius: 0.12),
            materials: [HalloweenMaterials.ghostMaterial()]
        )

        // Ghost body (cone-like)
        let body = ModelEntity(
            mesh: .generateCone(height: 0.3, radius: 0.15),
            materials: [HalloweenMaterials.ghostMaterial()]
        )
        body.position = SIMD3<Float>(0, -0.2, 0)

        head.addChild(body)

        // Position floating in front of wall
        var transform = Transform(matrix: anchor.originFromAnchorTransform)

        // Move away from wall based on wall normal
        let wallNormal = anchor.geometry.meshVertices.normal
        transform.translation.x += wallNormal.x * 0.2
        transform.translation.y += wallNormal.y * 0.2
        transform.translation.z += wallNormal.z * 0.2

        // Add some randomness
        let randomY = Float.random(in: -0.2...0.2)
        transform.translation.y += randomY

        head.transform = transform
        head.name = "Ghost-\(anchor.id)"

        return head
    }

    /// Toggle visibility of all decorations
    func setVisibility(_ visible: Bool) {
        for entities in decorationEntities.values {
            for entity in entities {
                entity.isEnabled = visible
            }
        }
    }
}
