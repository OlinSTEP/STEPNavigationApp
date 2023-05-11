//
//  STEP_MappingApp.swift
//  STEP Mapping
//
//  Created by Paul Ruvolo on 4/14/23.
//

import SwiftUI
import Firebase

@main
struct STEP_MappingApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(SettingsManager.shared)
                .onAppear() {
                    FirebaseManager.shared.setMode(mode: .mapping)
                }
        }
    }
}
