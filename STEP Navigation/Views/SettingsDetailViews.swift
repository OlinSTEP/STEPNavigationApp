//
//  SettingsDetailView_Buttons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/13/23.
//

import SwiftUI

struct SettingsDetailView_CrumbColor: View {
    var settingsManager = SettingsManager.shared
    @State var selectedCrumbColor: Color = StaticAppColor.black
    @State var customCrumbPopup: Bool = false
    @State var isCustomColorSelected: Bool = false
    
    var textColor: Color {
        if ContrastRatioCalculator.calculate(color1: selectedCrumbColor, color2: StaticAppColor.black) > 5.0 {
            return StaticAppColor.black
        } else {
            return StaticAppColor.white
        }
        }
    
    let crumbColorOptions = [
        CrumbColors(label: "Black", color: StaticAppColor.black),
        CrumbColors(label: "Yellow", color: StaticAppColor.yellow),
        CrumbColors(label: "Blue", color: StaticAppColor.blue)
    ]
    
    var body: some View {
        ScreenBackground {
            ZStack {
                VStack {
                    ScreenHeader(title: "Crumb Color", subtitle: "Set the color of the box-shaped crumb for navigating.")
                    
                    VStack(spacing: 20) {
                        ForEach(crumbColorOptions) { color in
                            SmallButton_Settings(action: {
                                selectedCrumbColor = color.color
                                settingsManager.saveCrumbColor(color: color.color)
                                isCustomColorSelected = false
                            }, label: color.label, selected: color.color == selectedCrumbColor, color1: SettingsManager.shared.loadCrumbColor(), color2: textColor)
                        }
                        
                        SmallButton_Settings(action: {
                            customCrumbPopup = true
                            isCustomColorSelected = true
                        }, label: "Custom", selected: isCustomColorSelected, color1: SettingsManager.shared.loadCrumbColor(), color2: textColor)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    Spacer()
                }
                
                if customCrumbPopup == true {
                    CustomCrumbColor(customCrumbPopup: $customCrumbPopup, selectedCrumbColor: $selectedCrumbColor)
                        .onDisappear() {
                            selectedCrumbColor = settingsManager.loadCrumbColor()
                            if crumbColorOptions.contains(where: {$0.color == selectedCrumbColor}) {
                                isCustomColorSelected = false
                            } else {
                                isCustomColorSelected = true
                            }
                        }
                }
            }
            .onAppear() {
                selectedCrumbColor = settingsManager.loadCrumbColor()
                if crumbColorOptions.contains(where: {$0.color == selectedCrumbColor}) {
                    isCustomColorSelected = false
                } else {
                    isCustomColorSelected = true
                }
            }
        }
    }
}

struct CrumbColors: Identifiable {
    var label: String
    var color: Color
    var id = UUID()
}

struct SettingsDetailView_ColorScheme: View {
    let settingsManager = SettingsManager.shared
    @State var selectedColorScheme: (Color, Color) = (StaticAppColor.white, StaticAppColor.black)
    @State var showPopup: Bool = false
    
    @State var customSchemePopup: Bool = false
    @State var isCustomSchemeSelected: Bool = false
    
    var body: some View {
        let colorSchemeOptions = [
            ColorSchemes(label: "Black and White", background: StaticAppColor.white, foreground: StaticAppColor.black),
            ColorSchemes(label: "Yellow and Black", background: StaticAppColor.black, foreground: StaticAppColor.yellow),
            ColorSchemes(label: "Yellow and Blue", background: StaticAppColor.blue, foreground: StaticAppColor.yellow)
        ]
        Group {
            ZStack {
                VStack {
                    ScreenHeader(title: "Color Scheme", subtitle: "Set the color scheme of the app.", backButtonHidden: selectedColorScheme != settingsManager.loadColorScheme())
                    VStack {
                        VStack(spacing: 20) {
                            ForEach(colorSchemeOptions) { scheme in
                                SmallButton_Settings(action: {
                                    selectedColorScheme = (scheme.background, scheme.foreground)
                                    isCustomSchemeSelected = false
                                }, label: scheme.label, selected: (scheme.background, scheme.foreground) == selectedColorScheme, color1: selectedColorScheme.0, color2: selectedColorScheme.1)
                            }
                        }
                        .padding(.top, 10)
                        
                        SmallButton_Settings(action: {
                            customSchemePopup = true
                            isCustomSchemeSelected = true
                        }, label: "Custom", selected: isCustomSchemeSelected, color1: selectedColorScheme.0, color2: selectedColorScheme.1)
                        .padding(.vertical, 10)
    
                        Spacer()
                        
                        if selectedColorScheme != settingsManager.loadColorScheme() {
                            SmallButton(action: {
                                let (color1, color2) = selectedColorScheme
                                settingsManager.saveColorScheme(color1: color1, color2: color2)
                                showPopup.toggle()
                            }, label: "Apply")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 48)
                
                if customSchemePopup == true {
                    CustomColorScheme(customSchemePopup: $customSchemePopup, selectedColorScheme: $selectedColorScheme)
                        .onDisappear() {
                            if !colorSchemeOptions.contains(where: { $0.background == selectedColorScheme.0 && $0.foreground == selectedColorScheme.1 }) {
                                isCustomSchemeSelected = true
                            } else {
                                isCustomSchemeSelected = false
                            }
                        }
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
                    .navigationBarBackButtonHidden()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .background(StaticAppColor.white)
                    .accessibilityAddTraits(.isModal)
                }
            }
            .onAppear() {
                updateColorScheme()
                if !colorSchemeOptions.contains(where: { $0.background == selectedColorScheme.0 && $0.foreground == selectedColorScheme.1 }) {
                    isCustomSchemeSelected = true
                } else {
                    isCustomSchemeSelected = false
                }
            }
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    private func updateColorScheme() {
            let (color1, color2) = settingsManager.loadColorScheme()
            selectedColorScheme = (color1, color2)
        }
}

struct ColorSchemes: Identifiable {
    var label: String
    var background: Color
    var foreground: Color
    var id = UUID()
}

struct SettingsDetailView_Units: View {
    @State private var selected: Bool = SettingsManager.shared.useMetricDistanceUnits
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Units", subtitle: "Which units would you like Clew to use?")
                
                VStack(spacing: 20) {
                    SmallButton_Settings(action: {
                        UserDefaults.standard.setValue(false, forKey: "units")
                        selected = false
                    }, label: "Imperial", selected: selected == false, color1: AppColor.foreground, color2: AppColor.background)
                    .accessibilityLabel(selected ? "Imperial" : "Imperial Selected ")
                    SmallButton_Settings(action: {
                        UserDefaults.standard.setValue(true, forKey: "units")
                        selected = true
                    }, label: "Metric", selected: selected == true, color1: AppColor.foreground, color2: AppColor.background)
                    .accessibilityLabel(selected ? "Metric Selected" : "Metric")
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}

struct SettingsDetailView_PhoneBodyOffset: View {
    @State private var selected: Bool = SettingsManager.shared.adjustPhoneBodyOffset
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Phone Body Offset", subtitle: "Enable phone body offset correction for the most accurate navigation.")
                VStack(spacing: 20) {
                    SmallButton_Settings(action: {
                        UserDefaults.standard.setValue(false, forKey: "adjustPhoneBodyOffset")
                        selected = false
                    }, label: "Off", selected: selected == false, color1: AppColor.foreground, color2: AppColor.background)
                    .accessibilityLabel(selected ? "Off" : "Off Selected ")
                    SmallButton_Settings(action: {
                        UserDefaults.standard.setValue(true, forKey: "adjustPhoneBodyOffset")
                        selected = true
                    }, label: "On", selected: selected == true, color1: AppColor.foreground, color2: AppColor.background)
                    .accessibilityLabel(selected ? "On Selected " : "On")
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}

struct CustomCrumbColor: View {
    var settingsManager = SettingsManager.shared
    @Binding var customCrumbPopup: Bool
    @Binding var selectedCrumbColor: Color
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Custom Crumb Color", subtitle: "Choose your own crumb color for use during navigation.", backButtonHidden: true)
                
                VStack {
                    ColorPicker("Crumb Color", selection: $selectedCrumbColor)
                        .foregroundColor(AppColor.foreground)
                        .bold()
                        .font(.title)
                    
                    Rectangle()
                        .frame(height: 100)
                        .foregroundColor(selectedCrumbColor)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    AppColor.foreground,
                                    lineWidth: 4
                                )
                        )
                }
                .padding()
                
                Spacer()
                
                SmallButton(action: {
                    settingsManager.saveCrumbColor(color: selectedCrumbColor)
                    customCrumbPopup = false
                }, label: "Apply")
            }
            .onAppear() {
                selectedCrumbColor = settingsManager.loadCrumbColor()
            }
        }
        .accessibilityAddTraits(.isModal)
    }
}

struct CustomColorScheme: View {
    var settingsManager = SettingsManager.shared
    @Binding var customSchemePopup: Bool
    @Binding var selectedColorScheme: (Color, Color)
    
    var contrastRatio: Double {
            ContrastRatioCalculator.calculate(color1: selectedColorScheme.0, color2: selectedColorScheme.1)
        }
    
    var body: some View {
        Group {
            VStack {
                ScreenHeader(title: "Custom Color Scheme", subtitle : "Choose your own foreground and background colors for the app.", backButtonHidden: true)
                
                let (color1, color2) = selectedColorScheme
                
                VStack {
                    ColorPicker("Foreground Color", selection: $selectedColorScheme.1)
                        .foregroundColor(AppColor.foreground)
                        .bold()
                        .font(.title)
                    
                    Rectangle()
                        .frame(height: 100)
                        .foregroundColor(color2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(AppColor.foreground,
                                              lineWidth: 4
                                             )
                        )
                        .cornerRadius(20)
                }
                .padding()
                
                VStack {
                    ColorPicker("Background Color", selection: $selectedColorScheme.0)
                        .foregroundColor(AppColor.foreground)
                        .bold()
                        .font(.title)
                    
                    Rectangle()
                        .frame(height: 100)
                        .foregroundColor(color1)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(
                                    AppColor.foreground,
                                    lineWidth: 4
                                )
                        )
                }
                .padding()
                                
                ZStack {
                    Rectangle()
                        .frame(height: 160)
                        .foregroundColor(color1)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(AppColor.foreground,
                                              lineWidth: 4)
                        )
                    VStack {
                        Text("Contrast Ratio")
                            .foregroundColor(color2)
                            .bold()
                            .font(.title)
                        Text("\(contrastRatio == 0 ? String(format: "%.0f", contrastRatio) : String(format: "%.1f", contrastRatio)):1")
                            .foregroundColor(color2)
                            .font(.title)
                    }
                }
                .padding()
                
                Spacer()
                
                SmallButton(action: {
                    customSchemePopup = false
                }, label: "Save")
            }
            .padding(.bottom, 48)
            .onAppear() {
                updateColorScheme()
            }
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityAddTraits(.isModal)
    }
    
    private func updateColorScheme() {
            let (color1, color2) = settingsManager.loadColorScheme()
            selectedColorScheme = (color1, color2)
        }
}

struct ContrastRatioCalculator {
    static func calculate(color1: Color, color2: Color) -> Double {
        guard let color1Components = UIColor(color1).cgColor.components,
              let color2Components = UIColor(color2).cgColor.components else {
            return 0.0
        }
        
        guard let color1Luma = calculateRelativeLuminance(components: color1Components),
              let color2Luma = calculateRelativeLuminance(components: color2Components) else {
            return 0.0
        }
        
        return calculateContrastRatio(color1Luma: color1Luma, color2Luma: color2Luma)
    }
    
    private static func calculateRelativeLuminance(components: [CGFloat]) -> CGFloat? {
        guard components.count >= 3 else {
            return nil
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        let r = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let g = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let b = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
    
    private static func calculateContrastRatio(color1Luma: CGFloat, color2Luma: CGFloat) -> Double {
        let luma1 = max(color1Luma, color2Luma)
        let luma2 = min(color1Luma, color2Luma)
        
        return (luma1 + 0.05) / (luma2 + 0.05)
    }
}
