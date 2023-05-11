//
//  STEP_NavigationApp.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import Firebase

@main
struct STEP_NavigationApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(SettingsManager.shared)
                .onAppear() {
                    FirebaseManager.shared.setMode(mode: .navigation)
                }
        }
    }
}
