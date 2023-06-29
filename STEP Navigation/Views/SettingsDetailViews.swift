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
    
    
    let crumbColorOptions = [
        CrumbColors(label: "Black", color: StaticAppColor.black),
        CrumbColors(label: "White", color: StaticAppColor.white),
        CrumbColors(label: "Yellow", color: StaticAppColor.yellow),
        CrumbColors(label: "Blue", color: StaticAppColor.blue)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                ScreenTitleComponent(titleText: "Crumb Color", subtitleText: "Set the color of the box-shaped crumb for navigating.")
                
                VStack(spacing: 10) {
                    ForEach(crumbColorOptions) { color in
                        Button(action: {
                            settingsManager.saveCrumbColor(color: color.color)
                            isCustomColorSelected = false
                            selectedCrumbColor = color.color
                        }) {
                            Text(color.label)
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(selectedCrumbColor == color.color ? StaticAppColor.black : AppColor.foreground)
                        }
                        .tint(selectedCrumbColor == color.color ? color.color : AppColor.background)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(selectedCrumbColor == color.color ? AppColor.background : AppColor.foreground, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    }
                    
                    Button(action: {
                        customCrumbPopup = true
                        isCustomColorSelected = true
                    }) {
                        Text("Custom")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(isCustomColorSelected ? StaticAppColor.black : AppColor.foreground)
                    }
                    .tint(isCustomColorSelected ? settingsManager.loadCrumbColor() : AppColor.background)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(isCustomColorSelected ? AppColor.background : AppColor.foreground, lineWidth: 2)
                    )
                    .padding(.horizontal)
                }
            .padding(.top, 20)
            Spacer()
        }
            .onAppear() {
                selectedCrumbColor = settingsManager.loadCrumbColor()
                print(selectedCrumbColor)
                
                if crumbColorOptions.contains(where: {$0.color == selectedCrumbColor}) {
                    isCustomColorSelected = false
                } else {
                    isCustomColorSelected = true
                }
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
        
        ZStack {
            VStack {
                if selectedColorScheme != settingsManager.loadColorScheme() {
                    ScreenTitleComponent(titleText: "Color Scheme", subtitleText: "Set the color scheme of the app.")
                        .padding(.top, 20)
                        .background(AppColor.accent)
                } else {
                    ScreenTitleComponent(titleText: "Color Scheme", subtitleText: "Set the color scheme of the app.")
                }
                
                VStack(spacing: 10) {
                    ForEach(colorSchemeOptions) { scheme in
                        let selectedScheme: Bool = (scheme.background, scheme.foreground) == selectedColorScheme
                        
                        Button(action: {
                            selectedColorScheme = (scheme.background, scheme.foreground)
                            isCustomSchemeSelected = false
                        }) {
                            Text(scheme.label)
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(selectedScheme ? scheme.background : AppColor.foreground)
                        }
                        .tint(selectedScheme ? scheme.foreground : AppColor.background)
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
                
                Button(action: {
                    customSchemePopup = true
                    isCustomSchemeSelected = true
                }) {
                    Text("Custom")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(isCustomSchemeSelected ? selectedColorScheme.0 : AppColor.foreground)
                }
                .tint(isCustomSchemeSelected ? selectedColorScheme.1 : AppColor.background)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(isCustomSchemeSelected ? AppColor.background : AppColor.foreground, lineWidth: 2)
                )
                .padding(.horizontal)
                
                Spacer()
                
                if selectedColorScheme != settingsManager.loadColorScheme() {
                    Button(action: {
                        let (color1, color2) = selectedColorScheme
                        settingsManager.saveColorScheme(color1: color1, color2: color2)
                        showPopup.toggle()
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
            .navigationBarBackButtonHidden(selectedColorScheme != settingsManager.loadColorScheme())

            if customSchemePopup == true {
                CustomColorScheme(customSchemePopup: $customSchemePopup, selectedColorScheme: $selectedColorScheme)
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
            print(selectedColorScheme)
            if !colorSchemeOptions.contains(where: { $0.background == selectedColorScheme.0 && $0.foreground == selectedColorScheme.1 }) {
                           isCustomSchemeSelected = true
                       }
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
<<<<<<< HEAD

=======
>>>>>>> frontend-refactor-2-electric-boogaloo
    private func updateColorScheme() {
            let (color1, color2) = settingsManager.loadColorScheme()
            selectedColorScheme = (color1, color2)
        }
<<<<<<< HEAD

=======
>>>>>>> frontend-refactor-2-electric-boogaloo
}

struct ColorSchemes: Identifiable {
    var label: String
    var background: Color
    var foreground: Color
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
<<<<<<< HEAD
=======

>>>>>>> frontend-refactor-2-electric-boogaloo
struct CustomCrumbColor: View {
    var settingsManager = SettingsManager.shared
    @Binding var customCrumbPopup: Bool
    @Binding var selectedCrumbColor: Color
    
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Custom Crumb Color", subtitleText: "Choose your own crumb color for use during navigation.")
                .padding(.top, 20)
                .background(AppColor.accent)
            
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
            
            SmallButtonComponent_Button(label: "Apply") {
                settingsManager.saveCrumbColor(color: selectedCrumbColor)
                customCrumbPopup = false
            }
            .padding(.bottom, 40)
        }
        .onAppear() {
            selectedCrumbColor = settingsManager.loadCrumbColor()
        }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
}

struct CustomColorScheme: View {
    var settingsManager = SettingsManager.shared
    @Binding var customSchemePopup: Bool
    @Binding var selectedColorScheme: (Color, Color)
    
    var contrastRatio: Double {
        guard let color1Components = UIColor(selectedColorScheme.0).cgColor.components,
              let color2Components = UIColor(selectedColorScheme.1).cgColor.components else {
            return 0.0
        }
        
        guard let color1Luma = calculateRelativeLuminance(components: color1Components),
              let color2Luma = calculateRelativeLuminance(components: color2Components) else {
            return 0.0
        }
        
        return calculateContrastRatio(color1Luma: color1Luma, color2Luma: color2Luma)
    }
    
    private func calculateRelativeLuminance(components: [CGFloat]) -> CGFloat? {
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
    
    private func calculateContrastRatio(color1Luma: CGFloat, color2Luma: CGFloat) -> Double {
        let luma1 = max(color1Luma, color2Luma)
        let luma2 = min(color1Luma, color2Luma)
        
        return (luma1 + 0.05) / (luma2 + 0.05)
    }
    
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Custom Color Scheme", subtitleText: "Choose your own foreground and background colors for the app.")
                .padding(.top, 20)
                .background(AppColor.accent)
            
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
            
            Spacer()
            
            ZStack {
                    Rectangle()
                        .frame(height: 160)
                        .foregroundColor(color1)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(AppColor.foreground,
                                              lineWidth: 4
                                             )
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
            
            SmallButtonComponent_Button(label: "Save") {
                customSchemePopup = false
            }
            .padding(.bottom, 40)
        }
        .onAppear() {
            updateColorScheme()
        }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
    }
    
    private func updateColorScheme() {
            let (color1, color2) = settingsManager.loadColorScheme()
            selectedColorScheme = (color1, color2)
        }
}
