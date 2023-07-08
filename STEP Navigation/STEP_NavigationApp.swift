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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            Group {
//                StartupPage0()
                if SettingsManager.shared.loadShowTutorials() {
                    StartupPage0()
                } else {
                    HomeView()
                }
            }
            .accentColor(AppColor.background)
            .environmentObject(SettingsManager.shared)
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                FirebaseManager.shared.setMode(mode: .navigation)
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
