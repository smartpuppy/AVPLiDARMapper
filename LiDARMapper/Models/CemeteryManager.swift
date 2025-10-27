//
//  CemeteryManager.swift
//  LiDARMapper
//
//  Manages AR Cemetery elements: graves on floors, portraits on walls
//

import ARKit
import RealityKit

@MainActor
class CemeteryManager {
    private weak var appState: AppState?
    private var cemeteryEntities: [UUID: [ModelEntity]] = [:]
    private let rootEntity: Entity

    init(appState: AppState, rootEntity: Entity) {
        self.appState = appState
        self.rootEntity = rootEntity
    }

    /// Spawn cemetery elements for a plane anchor
    func spawnCemeteryElements(for anchor: PlaneAnchor) {
        guard let appState = appState else { return }

        // Only spawn in cemetery theme
        guard appState.theme == .cemetery else { return }

        var entities: [ModelEntity] = []

        switch (anchor.classification, anchor.alignment) {
        case (.floor, _):
            // Spawn graves and tombstones on floors
            if let grave = createGrave(at: anchor) {
                entities.append(grave)
            }
            if let tombstone = createTombstone(at: anchor) {
                entities.append(tombstone)
            }

        case (.wall, _):
            // Spawn haunted portraits on walls
            if let portrait = createHauntedPortrait(at: anchor) {
                entities.append(portrait)
            }

        default:
            break
        }

        // Store and add to scene
        if !entities.isEmpty {
            cemeteryEntities[anchor.id] = entities
            for entity in entities {
                rootEntity.addChild(entity)
            }
            print("⚰️ Spawned \(entities.count) cemetery element(s) for \(anchor.classification)")
        }
    }

    /// Remove cemetery elements for a specific plane anchor
    func removeCemeteryElements(for anchorID: UUID) {
        guard let entities = cemeteryEntities.removeValue(forKey: anchorID) else { return }
        for entity in entities {
            entity.removeFromParent()
        }
        print("⚰️ Removed cemetery elements for anchor \(anchorID)")
    }

    /// Clear all cemetery elements
    func clearAll() {
        for entities in cemeteryEntities.values {
            for entity in entities {
                entity.removeFromParent()
            }
        }
        cemeteryEntities.removeAll()
    }

    // MARK: - Cemetery Element Creators

    private func createGrave(at anchor: PlaneAnchor) -> ModelEntity? {
        // Create a mound of dirt (elongated sphere)
        let grave = ModelEntity(
            mesh: .generateBox(width: 0.8, height: 0.15, depth: 0.4),
            materials: [HalloweenMaterials.cemeteryGroundMaterial()]
        )

        // Position on floor
        var transform = Transform(matrix: anchor.originFromAnchorTransform)
        transform.translation.y += 0.075 // Half height to sit on surface

        // Add some randomness to position
        let randomX = Float.random(in: -0.5...0.5)
        let randomZ = Float.random(in: -0.5...0.5)
        transform.translation.x += randomX
        transform.translation.z += randomZ

        // Random rotation
        let randomRotation = Float.random(in: 0...(2 * .pi))
        transform.rotation = simd_quatf(angle: randomRotation, axis: SIMD3<Float>(0, 1, 0))

        grave.transform = transform
        grave.name = "Grave-\(anchor.id)"

        return grave
    }

    private func createTombstone(at anchor: PlaneAnchor) -> ModelEntity? {
        // Create tombstone base
        let base = ModelEntity(
            mesh: .generateBox(width: 0.4, height: 0.1, depth: 0.15),
            materials: [HalloweenMaterials.gravestoneMaterial()]
        )

        // Create tombstone main part (rounded top with box + sphere)
        let stone = ModelEntity(
            mesh: .generateBox(width: 0.35, height: 0.5, depth: 0.12),
            materials: [HalloweenMaterials.gravestoneMaterial()]
        )
        stone.position = SIMD3<Float>(0, 0.3, 0)

        // Rounded top
        let top = ModelEntity(
            mesh: .generateSphere(radius: 0.175),
            materials: [HalloweenMaterials.gravestoneMaterial()]
        )
        top.position = SIMD3<Float>(0, 0.175, 0)
        top.scale = SIMD3<Float>(1, 0.7, 0.7) // Flatten it

        stone.addChild(top)
        base.addChild(stone)

        // Add a cross or "RIP" marker (using small boxes)
        let crossVertical = ModelEntity(
            mesh: .generateBox(width: 0.05, height: 0.2, depth: 0.05),
            materials: [HalloweenMaterials.gravestoneMaterial()]
        )
        crossVertical.position = SIMD3<Float>(0, 0.25, 0.08)

        let crossHorizontal = ModelEntity(
            mesh: .generateBox(width: 0.15, height: 0.05, depth: 0.05),
            materials: [HalloweenMaterials.gravestoneMaterial()]
        )
        crossHorizontal.position = SIMD3<Float>(0, 0.28, 0.08)

        stone.addChild(crossVertical)
        stone.addChild(crossHorizontal)

        // Position on floor next to grave
        var transform = Transform(matrix: anchor.originFromAnchorTransform)
        transform.translation.y += 0.05 // Slightly above ground

        // Random position
        let randomX = Float.random(in: -0.6...0.6)
        let randomZ = Float.random(in: -0.6...0.6)
        transform.translation.x += randomX
        transform.translation.z += randomZ

        // Random rotation
        let randomRotation = Float.random(in: 0...(2 * .pi))
        transform.rotation = simd_quatf(angle: randomRotation, axis: SIMD3<Float>(0, 1, 0))

        // Add slight tilt for aged effect
        let tiltAngle = Float.random(in: -0.1...0.1)
        let tiltAxis = SIMD3<Float>(Float.random(in: -1...1), 0, Float.random(in: -1...1))
        transform.rotation = transform.rotation * simd_quatf(angle: tiltAngle, axis: normalize(tiltAxis))

        base.transform = transform
        base.name = "Tombstone-\(anchor.id)"

        return base
    }

    private func createHauntedPortrait(at anchor: PlaneAnchor) -> ModelEntity? {
        // Create portrait frame
        let frame = ModelEntity(
            mesh: .generateBox(width: 0.4, height: 0.5, depth: 0.05),
            materials: [HalloweenMaterials.hauntedFrameMaterial()]
        )

        // Create portrait "canvas" (dark surface)
        let canvas = ModelEntity(
            mesh: .generateBox(width: 0.35, height: 0.45, depth: 0.02),
            materials: [createHauntedPortraitMaterial()]
        )
        canvas.position = SIMD3<Float>(0, 0, 0.035)
        frame.addChild(canvas)

        // Add spooky eyes (glowing)
        let leftEye = ModelEntity(
            mesh: .generateSphere(radius: 0.03),
            materials: [createGlowingEyeMaterial()]
        )
        leftEye.position = SIMD3<Float>(-0.08, 0.1, 0.05)

        let rightEye = ModelEntity(
            mesh: .generateSphere(radius: 0.03),
            materials: [createGlowingEyeMaterial()]
        )
        rightEye.position = SIMD3<Float>(0.08, 0.1, 0.05)

        frame.addChild(leftEye)
        frame.addChild(rightEye)

        // Position on wall
        var transform = Transform(matrix: anchor.originFromAnchorTransform)

        // Move away from wall slightly
        let wallNormal = anchor.geometry.meshVertices.normal
        transform.translation.x += wallNormal.x * 0.1
        transform.translation.y += wallNormal.y * 0.1
        transform.translation.z += wallNormal.z * 0.1

        // Random vertical position
        let randomY = Float.random(in: 0.5...1.5)
        transform.translation.y += randomY

        // Random horizontal position
        let randomOffset = Float.random(in: -0.5...0.5)
        transform.translation.x += randomOffset * 0.5

        frame.transform = transform
        frame.name = "HauntedPortrait-\(anchor.id)"

        return frame
    }

    // MARK: - Helper Materials

    private func createHauntedPortraitMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        // Dark, mysterious portrait color
        material.color = .init(tint: UIColor(red: 0.15, green: 0.1, blue: 0.15, alpha: 0.95))
        material.roughness = .init(floatLiteral: 0.7)
        return material
    }

    private func createGlowingEyeMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        // Eerie red glow
        material.color = .init(tint: UIColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1.0))
        return material
    }

    /// Toggle visibility of all cemetery elements
    func setVisibility(_ visible: Bool) {
        for entities in cemeteryEntities.values {
            for entity in entities {
                entity.isEnabled = visible
            }
        }
    }
}
