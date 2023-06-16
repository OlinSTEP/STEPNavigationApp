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
    
    private var crumbColorStringToColor: [String: Color] = ["defaultCrumbColor": AppColor.accent, "Green": AppColor.lightgreen, "Red": AppColor.lightred, "Blue": AppColor.lightblue]
    
    private var colorSchemeStringToColor: [String: [Color]] = ["defaultColorScheme": [AppColor.white, AppColor.defaultBlack, AppColor.defaultAccent], "Black_White": [AppColor.white, AppColor.black, AppColor.black], "Yellow_Black": [AppColor.black, AppColor.yellow, AppColor.yellow], "Yellow_Blue": [AppColor.blue, AppColor.yellow, AppColor.yellow]]
    
    /// if non-empty, put all mapping content in a subfolder
    @Published var mappingSubFolder = ""
    
    /// true if we should adjust navigation based on phone / body offset
    @Published var adjustPhoneBodyOffset = false
    
    /// true if we should provide the user with guidance when they appear to be lost
    @Published var automaticDirectionsWhenUserIsLost = false
    
    /// true if we should visualize streetscape data (requires resetting the app for the setting to take effect)
    @Published var visualizeStreetscapeData = false
    
    @Published var crumbColor: Color = AppColor.accent
    @Published var colorScheme: [Color] = [AppColor.white, AppColor.defaultBlack, AppColor.defaultAccent]

    
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
