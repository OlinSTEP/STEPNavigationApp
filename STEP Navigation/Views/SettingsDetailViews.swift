//
//  SettingsDetailView_Buttons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/13/23.
//

import SwiftUI

struct SettingsDetailView_CrumbColor: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @State var selectedCrumbColor: String?
    
    @State var showColorPicker: Bool = false
    @State var selectedCustomColor: Color = AppColor.accent
    
    init() {
            _selectedCrumbColor = State<String?>(initialValue: settingsManager.getCrumbColorLabel(forCrumbColor: settingsManager.crumbColor))
        }
    
    var body: some View {
        
        let crumbColorOptions = [
            CrumbColors(label: "Mint Green", color: StaticAppColor.defaultAccent),
            CrumbColors(label: "Yellow", color: StaticAppColor.yellow),
            CrumbColors(label: "Blue", color: StaticAppColor.blue)
        ]
        
        VStack {
            ScreenTitleComponent(titleText: "Crumb Color", subtitleText: "Set the color of the box-shaped crumb for navigating.")
            
            ZStack {
                VStack(spacing: 10) {
                    ForEach(crumbColorOptions) { color in
                        var selectedCrumb: Bool = selectedCrumbColor == color.label
                        
                        Button(action: {
                            UserDefaults.standard.setValue("\(color.label)", forKey: "crumbColor")
                            selectedCrumbColor = color.label
                        }) {
                            Text(color.label)
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(selectedCrumb ? StaticAppColor.black : AppColor.foreground)
                        }
                        .tint(selectedCrumb ? color.color : AppColor.background)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(selectedCrumb ? AppColor.background : AppColor.foreground, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                    
//                    Button(action: {
//                        showColorPicker = true
//                    }) {
//                        Text("Custom")
//                            .font(.title2)
//                            .bold()
//                            .frame(maxWidth: .infinity)
//                            .foregroundColor(AppColor.background)
//                    }
//                    .tint(AppColor.foreground)
//                    .buttonStyle(.borderedProminent)
//                    .buttonBorderShape(.capsule)
//                    .controlSize(.large)
//                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            Spacer()
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            ColorSchemes(label: "Default", background: StaticAppColor.white, foreground: StaticAppColor.defaultBlack, accent: StaticAppColor.defaultAccent, text_on_accent: StaticAppColor.defaultBlack),
            ColorSchemes(label: "Black and White", background: StaticAppColor.white, foreground: StaticAppColor.black, accent: StaticAppColor.black, text_on_accent: StaticAppColor.white),
            ColorSchemes(label: "Yellow and Black", background: StaticAppColor.black, foreground: StaticAppColor.yellow, accent: StaticAppColor.yellow, text_on_accent: StaticAppColor.black),
            ColorSchemes(label: "Yellow and Blue", background: StaticAppColor.blue, foreground: StaticAppColor.yellow, accent: StaticAppColor.yellow, text_on_accent: StaticAppColor.blue),
        ]
        
        ZStack {
            VStack {
                if selectedColorScheme != settingsManager.getColorSchemeLabel(forColorScheme: settingsManager.colorScheme) {
                    ScreenTitleComponent(titleText: "Color Scheme", subtitleText: "Set the color scheme of the app.")
                        .padding(.top, 20)
                        .background(AppColor.accent)
                } else {
                    ScreenTitleComponent(titleText: "Color Scheme", subtitleText: "Set the color scheme of the app.")
                }
                
                VStack(spacing: 10) {
                    ForEach(colorSchemeOptions) { scheme in
                        var selectedScheme: Bool = selectedColorScheme == scheme.label
                        
                        Button(action: {
                            selectedColorScheme = scheme.label
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
                                .stroke(selectedScheme ? AppColor.background : AppColor.foreground, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                if selectedColorScheme != settingsManager.getColorSchemeLabel(forColorScheme: settingsManager.colorScheme) {
                    Button(action: {
                        showPopup.toggle()
                        UserDefaults.standard.setValue(selectedColorScheme, forKey: "colorScheme")
                    }) {
                        Text("Apply")
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
                    .padding(.bottom, 40)
                }
            }
            .navigationBarBackButtonHidden(selectedColorScheme != settingsManager.getColorSchemeLabel(forColorScheme: settingsManager.colorScheme))

            
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
                .navigationBarBackButtonHidden()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .background(StaticAppColor.white)
                .accessibilityAddTraits(.isModal)
            }
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Units", subtitleText: "Which units would you like Clew to use?")
            
            Button {
                UserDefaults.standard.setValue(false, forKey: "units")
            } label: {
                Text("Imperial")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(settingsManager.units == true ? AppColor.foreground : AppColor.text_on_accent)
            }
            .tint(settingsManager.units == true ? AppColor.background : AppColor.accent)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(settingsManager.units == true ? AppColor.foreground : AppColor.background, lineWidth: 2)
            )
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 5)

            Button {
                UserDefaults.standard.setValue(true, forKey: "units")
            } label: {
                Text("Metric")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(settingsManager.units == true ? AppColor.text_on_accent : AppColor.foreground)
            }
            .tint(settingsManager.units == true ? AppColor.accent : AppColor.background)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(settingsManager.units == true ? AppColor.background : AppColor.foreground, lineWidth: 2)
            )
            .padding(.horizontal)
            
            Spacer()
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsDetailView_PhoneBodyOffset: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    
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
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsDetailView_ColorPicker: View {
    @Binding var customColor: Color
    let pickerLabel: String
    
    var body: some View {
        
        VStack {
            
            ColorPicker(pickerLabel, selection: $customColor)
                        .padding(.horizontal)
                        .foregroundColor(AppColor.foreground)
        }
    }
}
