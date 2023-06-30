//
//  SettingsView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Settings")
                ScrollView {
                    VStack(spacing: 28) {
                        VStack(spacing: 14) {
//                            HStack {
//                                Text("Color")
//                                    .bold()
//                                    .font(.title)
//                                    .foregroundColor(AppColor.foreground)
//                                Spacer()
//                            }
                            LeftLabel(text: "Color")
                            SmallNavigationLink(destination: SettingsDetailView_ColorScheme(), label: "Color Scheme")
                            SmallNavigationLink(destination: SettingsDetailView_CrumbColor(), label: "Crumb Color")
                        }
                        VStack(spacing: 14) {
                            LeftLabel(text: "Directions")
                            SmallNavigationLink(destination: SettingsDetailView_Units(), label: "Units")
                        }
                        VStack(spacing: 14) {
                            LeftLabel(text: "Miscellaneous")
                            SmallNavigationLink(destination: SettingsDetailView_PhoneBodyOffset(), label: "Phone - Body Offset")
                            SmallNavigationLink(destination: StartupPage3(), label: "Replay Tutorial")
                        }
                    }
                }
                .padding()
                Spacer()
            }
        }
    }
}
