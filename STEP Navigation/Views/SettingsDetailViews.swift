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
    
    init(selectedCrumbColor: Color? = StaticAppColor.defaultAccent) {
        self.selectedCrumbColor = selectedCrumbColor
    }
    
    var body: some View {
        
        let crumbColorOptions = [
            CrumbColors(label: "Default", color: StaticAppColor.defaultAccent),
            CrumbColors(label: "Green", color: StaticAppColor.lightgreen),
            CrumbColors(label: "Red", color: StaticAppColor.lightred),
            CrumbColors(label: "Blue", color: StaticAppColor.lightblue)
        ]
        
        VStack {
            ScreenTitleComponent(titleText: "Crumb Color", subtitleText: "Set the color of the box-shaped crumb for navigating.")
            
            VStack(spacing: 10) {
                ForEach(crumbColorOptions) { color in
                    Button(action: {UserDefaults.standard.setValue("\(color.label)", forKey: "crumbColor")}) {
                        Text(color.label)
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(AppColor.dark)
                    }
                    .tint(settingsManager.crumbColor == color.color ? color.color : AppColor.light)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(settingsManager.crumbColor != color.color ? AppColor.dark : AppColor.light, lineWidth: 2)
                    )
                    .padding(.horizontal)
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
            ColorSchemes(label: "defaultColorScheme", backgroundColor: StaticAppColor.white, foregroundColor: StaticAppColor.defaultBlack, accentColor: StaticAppColor.defaultAccent),
            ColorSchemes(label: "Black_White", backgroundColor: StaticAppColor.white, foregroundColor: StaticAppColor.black, accentColor: StaticAppColor.black),
            ColorSchemes(label: "Yellow_Black", backgroundColor: StaticAppColor.black, foregroundColor: StaticAppColor.yellow, accentColor: StaticAppColor.yellow),
            ColorSchemes(label: "Yellow_Blue", backgroundColor: StaticAppColor.blue, foregroundColor: StaticAppColor.yellow, accentColor: StaticAppColor.yellow)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(scheme.accentColor, lineWidth: 2)
                    )
                    .padding(.horizontal)
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

struct SettingsDetailView_Units: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @State var selectedUnit: String?
    
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Units", subtitleText: "Which units would you like Clew to use?")
            Spacer()
        }
    }
}

struct SettingsDetailView_PhoneBodyOffset: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @State var offsetOn: Bool?
    
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Phone Body Offset", subtitleText: "Enable phone body offset correction for the most accurate navigation.")
            
            Button {
                UserDefaults.standard.setValue(false, forKey: "adjustPhoneBodyOffset")
            } label: {
                Text("Off")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(settingsManager.adjustPhoneBodyOffset == true ? AppColor.dark : AppColor.light)
            }
            .tint(settingsManager.adjustPhoneBodyOffset == false ? AppColor.accent : AppColor.light)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(settingsManager.adjustPhoneBodyOffset == true ? AppColor.dark : AppColor.light, lineWidth: 2)
            )
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 5)

            
            Button {
                UserDefaults.standard.setValue(true, forKey: "adjustPhoneBodyOffset")
            } label: {
                Text("On")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(settingsManager.adjustPhoneBodyOffset == false ? AppColor.dark : AppColor.light)
            }
            .tint(settingsManager.adjustPhoneBodyOffset == true ? AppColor.accent : AppColor.light)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(settingsManager.adjustPhoneBodyOffset == false ? AppColor.dark : AppColor.light, lineWidth: 2)
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
