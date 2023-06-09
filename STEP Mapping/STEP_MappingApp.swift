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

class AppDelegate: NSObject, UIApplicationDelegate {
        
    static var orientationLock = UIInterfaceOrientationMask.all //By default you want all your views to rotate freely

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
