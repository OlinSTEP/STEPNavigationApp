//
//  SettingsDetailView_Buttons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/13/23.
//

import SwiftUI

struct SettingsDetailView_CrumbColor: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @State var selectedCrumbColor: Color?
    
    init(selectedCrumbColor: Color? = AppColor.accent) {
        self.selectedCrumbColor = selectedCrumbColor
    }
    
    var body: some View {
        
        let crumbColorOptions = [
            CrumbColors(label: "Default", color: AppColor.accent),
            CrumbColors(label: "Green", color: AppColor.lightgreen),
            CrumbColors(label: "Red", color: AppColor.lightred),
            CrumbColors(label: "Blue", color: AppColor.lightblue)
        ]
        
        VStack {
            ScreenTitleComponent(titleText: "Crumb Color", subtitleText: "Set the color of the box-shaped crumb for navigating.")
            
            VStack(spacing: 10) {
                ForEach(crumbColorOptions) { color in
                    SmallButtonComponent_Button(label: "\(color.label)", action: {
                        UserDefaults.standard.setValue("\(color.label)", forKey: "crumbColor")
                    }, labelColor: AppColor.dark, backgroundColor: settingsManager.crumbColor == color.color ? color.color : AppColor.grey)
                }
            }
            .padding(.top, 20)
            Spacer()
        }
    }
}

struct CrumbColors: Identifiable {
    var label: String
    var color: Color
    var id = UUID()
}

struct SettingsDetailView_ColorScheme: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @State var selectedColorScheme: String?
    
    init(selectedColorScheme: String? = "defaultColorScheme") {
        self.selectedColorScheme = selectedColorScheme
    }
    
    var body: some View {
        
        let colorSchemeOptions = [
            ColorSchemes(label: "defaultColorScheme", backgroundColor: AppColor.white, foregroundColor: AppColor.defaultBlack, accentColor: AppColor.defaultAccent),
            ColorSchemes(label: "Black_White", backgroundColor: AppColor.white, foregroundColor: AppColor.black, accentColor: AppColor.black),
            ColorSchemes(label: "Yellow_Black", backgroundColor: AppColor.black, foregroundColor: AppColor.yellow, accentColor: AppColor.yellow),
            ColorSchemes(label: "Yellow_Blue", backgroundColor: AppColor.blue, foregroundColor: AppColor.yellow, accentColor: AppColor.yellow)
        ]
        
        VStack {
            ScreenTitleComponent(titleText: "Color Scheme", subtitleText: "Set the color scheme of the app.")
            
            VStack(spacing: 10) {
                ForEach(colorSchemeOptions) { scheme in
                    Button(action: {
                        UserDefaults.standard.setValue("\(scheme.label)", forKey: "colorScheme")
                    }) {
                        Text(scheme.label)
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(scheme.foregroundColor)
//                            .foregroundColor(settingsManager.colorScheme == scheme.label ? scheme.backgroundColor : scheme.foregroundColor)
                    }
//                    .tint(settingsManager.colorScheme == scheme.label ? scheme.foregroundColor : scheme.backgroundColor)
                    .tint(.white)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .padding(.horizontal)
                    .border(scheme.accentColor, width: 2)
                }
            }
            .padding(.top, 20)
            
            Text("ForegroundColor: ")
            Text("BackgroundColor: ")
            Text("AccentColor: ")
            
            Spacer()
        }
    }
}

struct ColorSchemes: Identifiable {
    var label: String
    var backgroundColor: Color
    var foregroundColor: Color
    var accentColor: Color
    var id = UUID()
}
