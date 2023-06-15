//
//  SettingsManager.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/6/23.
//

import Foundation
import SwiftUI

/// This class manages the settings of the app
class SettingsManager: ObservableObject {
    /// The shared handle to the singleton instance of this class
    public static var shared = SettingsManager()
    
    private var settingsToColor: [String: Color] = ["Red": AppColor.lightred,
                                                "Blue": AppColor.lightblue]
    
    /// if non-empty, put all mapping content in a subfolder
    var mappingSubFolder = ""
    
    /// true if we should adjust navigation based on phone / body offset
    var adjustPhoneBodyOffset = false
    
    /// true if we should provide the user with guidance when they appear to be lost
    var automaticDirectionsWhenUserIsLost = false
    
    /// true if we should visualize streetscape data (requires resetting the app for the setting to take effect)
    var visualizeStreetscapeData = false
    
    var crumbColor: Color = AppColor.lightred
    
    /// The private initializer.  This should not be called directly.
    private init() {
        createSettingsBundle()
    }
    
    /// Configure Settings Bundle and add observer for settings changes.
    func createSettingsBundle() {
        registerSettingsBundle()
        updateDisplayFromDefaults()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateDisplayFromDefaults),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }
    
    /// Respond to update events to the `UserDefaults` object (the settings of the app).
    @objc func updateDisplayFromDefaults() {
        let defaults = UserDefaults.standard
        
        mappingSubFolder = defaults.string(forKey: "mappingSubFolder") ?? ""
        adjustPhoneBodyOffset = defaults.bool(forKey: "adjustPhoneBodyOffset")
        automaticDirectionsWhenUserIsLost = defaults.bool(forKey: "automaticDirectionsWhenUserIsLost")
        visualizeStreetscapeData = defaults.bool(forKey: "visualizeStreetscapeData")
        if let colorAsString = defaults.string(forKey: "crumbColor"), let color = settingsToColor[colorAsString] {
            crumbColor = color
        }
    }
    
    /// Register settings bundle
    func registerSettingsBundle(){
        let appDefaults: [String: Any] = [
            "mappingSubFolder": "",
            "adjustPhoneBodyOffset": false,
            "automaticDirectionsWhenUserIsLost": false,
            "visualizeStreetscapeData": false,
            "crumbColor": "Red"
        ]
        UserDefaults.standard.register(defaults: appDefaults)
    }
}
