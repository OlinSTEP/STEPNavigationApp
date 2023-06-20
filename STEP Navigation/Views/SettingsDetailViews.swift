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
                            .foregroundColor(AppColor.foreground)
                    }
                    .tint(settingsManager.crumbColor == color.color ? color.color : AppColor.background)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(settingsManager.crumbColor != color.color ? AppColor.foreground : AppColor.background, lineWidth: 2)
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
    @State var showPopup: Bool = false
    
    init() {
            _selectedColorScheme = State<String?>(initialValue: settingsManager.getColorSchemeLabel(forColorScheme: settingsManager.colorScheme))
        }
    
    var body: some View {
        
        let colorSchemeOptions = [
            ColorSchemes(label: "defaultColorScheme", background: StaticAppColor.white, foreground: StaticAppColor.defaultBlack, accent: StaticAppColor.defaultAccent, text_on_accent: StaticAppColor.defaultBlack),
            ColorSchemes(label: "Black_White", background: StaticAppColor.white, foreground: StaticAppColor.black, accent: StaticAppColor.black, text_on_accent: StaticAppColor.white),
            ColorSchemes(label: "Yellow_Black", background: StaticAppColor.black, foreground: StaticAppColor.yellow, accent: StaticAppColor.yellow, text_on_accent: StaticAppColor.black),
            ColorSchemes(label: "Yellow_Blue", background: StaticAppColor.blue, foreground: StaticAppColor.yellow, accent: StaticAppColor.yellow, text_on_accent: StaticAppColor.blue),
        ]
        
        ZStack {
            VStack {
                ScreenTitleComponent(titleText: "Color Scheme", subtitleText: "Set the color scheme of the app.")
                    .padding(.top, 20)
                    .background(AppColor.accent)
                
                VStack(spacing: 10) {
                    ForEach(colorSchemeOptions) { scheme in
                        let selectedScheme: Bool = selectedColorScheme == scheme.label
                        
                        Button(action: {
                            selectedColorScheme = scheme.label
//                            print(selectedColorScheme)
                        }) {
                            Text(scheme.label)
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(selectedScheme ? scheme.text_on_accent : AppColor.foreground)
                            
                        }
                        .tint(selectedScheme ? scheme.accent : AppColor.background)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(selectedScheme ? scheme.background : AppColor.foreground, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    showPopup.toggle()
                    UserDefaults.standard.setValue(selectedColorScheme, forKey: "colorScheme")
                }) {
                    Text("Next")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(AppColor.text_on_accent)
                }
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .padding(.horizontal)
            }
            
            if showPopup {
                VStack {
                    Spacer()
                    HStack {
                        Text("Color scheme set. Please restart the app to apply the new color scheme.")
                            .foregroundColor(StaticAppColor.black)
                            .bold()
                            .font(.title)
                    }
                    .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .background(StaticAppColor.white)
                .cornerRadius(20)
                .accessibilityAddTraits(.isModal)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct ColorSchemes: Identifiable {
    var label: String
    var background: Color
    var foreground: Color
    var accent: Color
    var text_on_accent: Color
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
                    .foregroundColor(settingsManager.adjustPhoneBodyOffset == true ? AppColor.foreground : AppColor.text_on_accent)
            }
            .tint(settingsManager.adjustPhoneBodyOffset == true ? AppColor.background : AppColor.accent)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(settingsManager.adjustPhoneBodyOffset == true ? AppColor.foreground : AppColor.background, lineWidth: 2)
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
                    .foregroundColor(settingsManager.adjustPhoneBodyOffset == true ? AppColor.text_on_accent : AppColor.foreground)
            }
            .tint(settingsManager.adjustPhoneBodyOffset == true ? AppColor.accent : AppColor.background)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(settingsManager.adjustPhoneBodyOffset == true ? AppColor.background : AppColor.foreground, lineWidth: 2)
            )
            .padding(.horizontal)
            
            Spacer()
        }
    }
}
