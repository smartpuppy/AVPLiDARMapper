//
//  HalloweenMaterials.swift
//  LiDARMapper
//
//  Provides Halloween-themed materials for spooky visualization
//

import ARKit
import RealityKit
import SwiftUI

struct HalloweenMaterials {

    // MARK: - Ectoplasm Theme Materials

    /// Glowing green ectoplasm material with transparency
    static func ectoplasmMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 0.7))
        material.triangleFillMode = .lines
        return material
    }

    /// Purple spectral energy material
    static func spectralMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 0.8))
        material.triangleFillMode = .lines
        return material
    }

    /// Glowing mesh material based on classification
    static func ectoplasmMeshMaterial(for classification: MeshAnchor.MeshClassification) -> UnlitMaterial {
        var material = UnlitMaterial()

        let color: UIColor = switch classification {
        case .wall, .door:
            UIColor(red: 0.6, green: 0.2, blue: 1.0, alpha: 0.9) // Purple for walls
        case .floor:
            UIColor(red: 0.2, green: 1.0, blue: 0.4, alpha: 0.9) // Green for floors
        case .ceiling:
            UIColor(red: 1.0, green: 0.3, blue: 0.8, alpha: 0.9) // Pink for ceilings
        default:
            UIColor(red: 0.4, green: 1.0, blue: 0.8, alpha: 0.8) // Cyan for other
        }

        material.color = .init(tint: color)
        material.triangleFillMode = .lines
        return material
    }

    // MARK: - Cemetery Theme Materials

    /// Dark stone material for graves
    static func gravestoneMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 0.95))
        material.roughness = .init(floatLiteral: 0.9)
        return material
    }

    /// Dirt/ground material for cemetery floors
    static func cemeteryGroundMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.3, green: 0.2, blue: 0.15, alpha: 0.85))
        material.roughness = .init(floatLiteral: 0.95)
        return material
    }

    /// Haunted portrait frame material
    static func hauntedFrameMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.1, green: 0.05, blue: 0.05, alpha: 0.9))
        material.roughness = .init(floatLiteral: 0.3)
        return material
    }

    // MARK: - Haunted House Theme Materials

    /// Orange jack-o-lantern material
    static func pumpkinMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor.systemOrange.withAlphaComponent(0.9))
        material.roughness = .init(floatLiteral: 0.7)
        return material
    }

    /// Glowing yellow material for pumpkin eyes
    static func pumpkinGlowMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor.systemYellow)
        return material
    }

    /// Translucent ghost material
    static func ghostMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor.white.withAlphaComponent(0.4))
        material.blending = .transparent(opacity: 0.4)
        return material
    }

    /// Dark bat material
    static func batMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.95))
        material.roughness = .init(floatLiteral: 0.8)
        return material
    }

    /// Cobweb material (transparent gray)
    static func cobwebMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor.lightGray.withAlphaComponent(0.5))
        material.blending = .transparent(opacity: 0.5)
        return material
    }

    // MARK: - Paranormal Theme Materials

    /// Eerie red glow for paranormal activity
    static func paranormalGlowMaterial() -> UnlitMaterial {
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.6))
        return material
    }

    /// Dark ominous material for walls
    static func ominousWallMaterial() -> SimpleMaterial {
        var material = SimpleMaterial()
        material.color = .init(tint: UIColor(red: 0.3, green: 0.15, blue: 0.2, alpha: 0.7))
        material.roughness = .init(floatLiteral: 0.8)
        return material
    }

    // MARK: - Themed Plane Materials

    /// Get themed plane material based on theme and classification
    static func themedPlaneMaterial(
        for classification: PlaneAnchor.Classification,
        alignment: PlaneAnchor.Alignment,
        theme: Theme
    ) -> any RealityKit.Material {
        switch theme {
        case .normal:
            return MaterialProvider.planeMaterial(for: classification, alignment: alignment)

        case .hauntedHouse:
            // Semi-transparent materials to see decorations
            var material = UnlitMaterial()
            let color: UIColor = switch (classification, alignment) {
            case (.floor, _):
                UIColor.systemIndigo.withAlphaComponent(0.25)
            case (.ceiling, _):
                UIColor.systemPurple.withAlphaComponent(0.25)
            case (.wall, _):
                UIColor.darkGray.withAlphaComponent(0.25)
            default:
                UIColor.systemGray.withAlphaComponent(0.25)
            }
            material.color = .init(tint: color)
            return material

        case .ectoplasm:
            return ectoplasmMeshMaterial(for: .none)

        case .paranormal:
            return paranormalGlowMaterial()

        case .cemetery:
            return switch (classification, alignment) {
            case (.floor, _):
                cemeteryGroundMaterial()
            case (.wall, _):
                hauntedFrameMaterial()
            default:
                ominousWallMaterial()
            }
        }
    }

    /// Get themed mesh material based on theme
    static func themedMeshMaterial(
        for classification: MeshAnchor.MeshClassification,
        style: MeshStyle,
        theme: Theme
    ) -> any RealityKit.Material {
        switch theme {
        case .normal:
            return MaterialProvider.meshMaterial(for: classification, style: style)

        case .hauntedHouse:
            // Subtle dark wireframe
            var material = UnlitMaterial()
            material.color = .init(tint: UIColor.darkGray.withAlphaComponent(0.4))
            material.triangleFillMode = .lines
            return material

        case .ectoplasm:
            return ectoplasmMeshMaterial(for: classification)

        case .paranormal:
            return paranormalGlowMaterial()

        case .cemetery:
            // Dark, ominous mesh
            var material = UnlitMaterial()
            material.color = .init(tint: UIColor(red: 0.2, green: 0.1, blue: 0.15, alpha: 0.6))
            material.triangleFillMode = .lines
            return material
        }
    }
}
