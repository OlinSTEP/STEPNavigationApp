//
//  AppColor.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/6/23.
//

import Foundation
import SwiftUI

struct AppColor {
    static let settingsManager = SettingsManager.shared
    static var background: Color {
        settingsManager.loadColorScheme().0
    }
        
    static var foreground: Color {
        settingsManager.loadColorScheme().1
    }
    
    static var text_on_accent: Color {
        settingsManager.loadColorScheme().0
    }
        
    static var accent: Color {
        settingsManager.loadColorScheme().1
    }
}

struct StaticAppColor {
    static let black: Color = Color(.sRGB, red: 0/255, green: 0/255, blue: 0/255, opacity: 1)
    static let white: Color = Color(.sRGB, red: 255/255, green: 255/255, blue: 255/255, opacity: 1)
    static let yellow: Color = Color(.sRGB, red: 255/255, green: 255/255, blue: 0/255, opacity: 1)
    static let green: Color = Color(.sRGB, red: 0/255, green: 255/255, blue: 0/255, opacity: 1)
    static let red: Color = Color(.sRGB, red: 255/255, green: 0/255, blue: 0/255, opacity: 1)
    static let blue: Color = Color(.sRGB, red: 0/255, green: 0/255, blue: 255/255, opacity: 1)
}
