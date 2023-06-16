//
//  AppColor.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/6/23.
//

import Foundation
import SwiftUI

struct AppColor {
    static var light: Color {
            return SettingsManager.shared.colorScheme[0]
        }
        
    static var dark: Color {
        return SettingsManager.shared.colorScheme[1]
    }
        
    static var accent: Color {
        return SettingsManager.shared.colorScheme[2]
    }
    
//    static let dark: Color = Color(.sRGB,
//                                       red: 34/255,
//                                       green: 34/255,
//                                       blue: 34/255,
//                                       opacity: 1)
//    static let light: Color = Color(.sRGB,
//                                       red: 255/255,
//                                       green: 255/255,
//                                       blue: 255/255,
//                                       opacity: 1)
//    static let accent: Color = Color(.sRGB,
//                                       red: 171/255,
//                                       green: 236/255,
//                                       blue: 220/255,
//                                       opacity: 1)
}

struct StaticAppColor {
    static let black: Color = Color(.sRGB, red: 0/255, green: 0/255, blue: 0/255, opacity: 1)
    static let white: Color = Color(.sRGB, red: 255/255, green: 255/255, blue: 255/255, opacity: 1)
    static let yellow: Color = Color(.sRGB, red: 255/255, green: 255/255, blue: 0/255, opacity: 1)
    static let blue: Color = Color(.sRGB, red: 0/255, green: 0/255, blue: 255/255, opacity: 1)
    static let defaultAccent: Color = Color(.sRGB, red: 171/255, green: 236/255, blue: 220/255, opacity: 1)
    static let defaultBlack: Color = Color(.sRGB, red: 34/255, green: 34/255, blue: 34/255, opacity: 1)
    
    static let lightred: Color = Color(.sRGB,
                                       red: 242/255,
                                       green: 146/255,
                                       blue: 146/255,
                                       opacity: 1)
    static let lightyellow: Color = Color(.sRGB,
                                       red: 242/255,
                                       green: 201/255,
                                       blue: 76/255,
                                       opacity: 1)
    static let lightgreen: Color = Color(.sRGB,
                                       red: 111/255,
                                       green: 207/255,
                                       blue: 151/255,
                                       opacity: 1)
    static let lightblue: Color = Color(.sRGB,
                                        red: 111/255,
                                        green: 138/255,
                                        blue: 207/255,
                                        opacity: 1)
    static let darkred: Color = Color(.sRGB,
                                       red: 231/255,
                                       green: 35/255,
                                       blue: 35/255,
                                       opacity: 1)
    static let darkyellow: Color = Color(.sRGB,
                                       red: 148/255,
                                       green: 113/255,
                                       blue: 10/255,
                                       opacity: 1)
    static let darkgreen: Color = Color(.sRGB,
                                       red: 45/255,
                                       green: 134/255,
                                       blue: 82/255,
                                       opacity: 1)
    
}
