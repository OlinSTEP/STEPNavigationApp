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
    
    private var crumbColorStringToColor: [String: Color] = ["defaultCrumbColor": StaticAppColor.defaultAccent, "Green": StaticAppColor.lightgreen, "Red": StaticAppColor.lightred, "Blue": StaticAppColor.lightblue]
    
    private var colorSchemeStringToColor: [String: [Color]] = ["defaultColorScheme": [StaticAppColor.white, StaticAppColor.defaultBlack, StaticAppColor.defaultAccent, StaticAppColor.defaultBlack], "Black_White": [StaticAppColor.white, StaticAppColor.black, StaticAppColor.black, StaticAppColor.white], "Yellow_Black": [StaticAppColor.black, StaticAppColor.yellow, StaticAppColor.yellow, StaticAppColor.black], "Yellow_Blue": [StaticAppColor.blue, StaticAppColor.yellow, StaticAppColor.yellow, StaticAppColor.blue]]
    
    /// if non-empty, put all mapping content in a subfolder
    @Published var mappingSubFolder = ""
    
    /// true if we should adjust navigation based on phone / body offset
    @Published var adjustPhoneBodyOffset = false
    
    /// true if we should provide the user with guidance when they appear to be lost
    @Published var automaticDirectionsWhenUserIsLost = false
    
    /// true if we should visualize streetscape data (requires resetting the app for the setting to take effect)
    @Published var visualizeStreetscapeData = false
    
    @Published var crumbColor: Color = StaticAppColor.defaultAccent
    @Published var colorScheme: [Color] = [StaticAppColor.white, StaticAppColor.defaultBlack, StaticAppColor.defaultAccent]

    
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
        if let crumbColorAsString = defaults.string(forKey: "crumbColor"), let color = crumbColorStringToColor[crumbColorAsString] {
            crumbColor = color
        }
        if let colorSchemeAsString = defaults.string(forKey: "colorScheme"), let color = colorSchemeStringToColor[colorSchemeAsString] {
            colorScheme = color
        }
    }
    
    /// Register settings bundle
    func registerSettingsBundle(){
        let appDefaults: [String: Any] = [
            "mappingSubFolder": "",
            "adjustPhoneBodyOffset": false,
            "automaticDirectionsWhenUserIsLost": false,
            "visualizeStreetscapeData": false,
            "crumbColor": "defaultCrumbColor",
            "colorScheme": "defaultColorScheme"
        ]
        UserDefaults.standard.register(defaults: appDefaults)
    }
}
