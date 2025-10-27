//
//  LiDARMapperApp.swift
//  LiDARMapper
//
//  Created for visionOS 26
//  Real-time LiDAR-based 3D spatial mapping for Apple Vision Pro
//

import SwiftUI

@main
struct LiDARMapperApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 600, height: 700)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
