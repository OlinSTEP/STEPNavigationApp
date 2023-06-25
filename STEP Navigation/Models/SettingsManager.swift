//
//  SettingsManager.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/6/23.
//

import Foundation
import Combine
import SwiftUI

/// This class manages the settings of the app
class SettingsManager: ObservableObject {
    /// The shared handle to the singleton instance of this class
    public static var shared = SettingsManager()
    
    /// if non-empty, put all mapping content in a subfolder
    @Published var mappingSubFolder = ""
    
    /// true if we should adjust navigation based on phone / body offset
    @Published var adjustPhoneBodyOffset = false
    
    /// boolean to toggle the units between imperial and metric. false for imperial units, true for metric units
    @Published var units = false
    
    /// true if we should provide the user with guidance when they appear to be lost
    @Published var automaticDirectionsWhenUserIsLost = false
    
    /// true if we should visualize streetscape data (requires resetting the app for the setting to take effect)
    @Published var visualizeStreetscapeData = false
    
//    @Published var crumbColor: Color = StaticAppColor.defaultAccent
//    @Published var colorScheme: [Color] = [StaticAppColor.white, StaticAppColor.defaultBlack, StaticAppColor.defaultAccent, StaticAppColor.defaultBlack]

    
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
        units = defaults.bool(forKey: "units")

    }
    
    /// Register settings bundle
    func registerSettingsBundle(){
        let appDefaults: [String: Any] = [
            "mappingSubFolder": "",
            "adjustPhoneBodyOffset": false,
            "automaticDirectionsWhenUserIsLost": false,
            "visualizeStreetscapeData": false,
            "units": false
        ]
        UserDefaults.standard.register(defaults: appDefaults)
    }
}

class UserSettings: ObservableObject {
    private var crumbColorKey = "crumbColor2"
    private var colorSchemeKey = "colorScheme2"
    private let userDefaults = UserDefaults.standard
    
    func saveCrumbColor(color: Color) {
        let color = UIColor(color).cgColor
        if let components = color.components {
            userDefaults.set(components, forKey: crumbColorKey)
            print("crumb color saved: \(components)")
        }
    }
    
    func saveColorScheme(color1: Color, color2: Color) {
            let cgColor1 = UIColor(color1).cgColor
            let cgColor2 = UIColor(color2).cgColor
            
            if let components1 = cgColor1.components,
               let components2 = cgColor2.components {
                let colorsArray = [components1, components2]
                userDefaults.set(colorsArray, forKey: colorSchemeKey)
                print("Color scheme saved: \(colorsArray)")
            }
        }
    
    func loadCrumbColor() -> Color {
        guard let array = UserDefaults.standard.object(forKey: crumbColorKey) as? [CGFloat] else { return StaticAppColor.black}
        
        let color = Color(.sRGB,
                          red: array[0],
                          green: array[1],
                          blue: array[2],
                          opacity: array[3])
        print("Color loaded: \(color)")
        return color
    }
    
    func loadColorScheme() -> (Color, Color) {
            guard let colorsArray = UserDefaults.standard.object(forKey: colorSchemeKey) as? [[CGFloat]],
                  colorsArray.count >= 2 else {
                return (StaticAppColor.white, StaticAppColor.black)
            }
            
            let color1 = Color(.sRGB,
                               red: colorsArray[0][0],
                               green: colorsArray[0][1],
                               blue: colorsArray[0][2],
                               opacity: colorsArray[0][3])
            
            let color2 = Color(.sRGB,
                               red: colorsArray[1][0],
                               green: colorsArray[1][1],
                               blue: colorsArray[1][2],
                               opacity: colorsArray[1][3])
            
            print("Color scheme loaded: \(color1), \(color2)")
            return (color1, color2)
        }
}
