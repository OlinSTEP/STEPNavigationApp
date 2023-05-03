//
//  SettingsManager.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/6/23.
//

import Foundation

class SettingsManager: ObservableObject {
    public static var shared = SettingsManager()
    
    /// if non-empty, put all mapping content in a subfolder
    var mappingSubFolder = ""
    
    private init() {
        createSettingsBundle()
    }
    
    /// Configure Settings Bundle
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
    }
    
    /// Register settings bundle
    func registerSettingsBundle(){
        let appDefaults = ["mappingSubFolder": ""] as [String : Any]
        UserDefaults.standard.register(defaults: appDefaults)
    }
}
