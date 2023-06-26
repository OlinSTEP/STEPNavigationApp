//
//  SettingsView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Settings")
                ScrollView {
                    VStack(spacing: 28) {
                        VStack {
                            HStack {
                                Text("Color")
                                    .bold()
                                    .font(.title2)
                                    .foregroundColor(AppColor.foreground)
                                Spacer()
                            }
                            .padding()
                            SmallButtonComponent_NavigationLink(destination: {
                                SettingsDetailView_ColorScheme()
                            }, label: "Color Scheme")
                            .padding(.bottom, 5)
                            SmallButtonComponent_NavigationLink(destination: {
                                SettingsDetailView_CrumbColor()
                            }, label: "Crumb Color")
                        }
                        
                        VStack {
                            HStack {
                                Text("Directions")
                                    .bold()
                                    .font(.title2)
                                    .foregroundColor(AppColor.foreground)
                                Spacer()
                            }
                            .padding()
                            SmallButtonComponent_NavigationLink(destination: {
                                SettingsDetailView_Units()
                            }, label: "Units")
                        }
                        
                        VStack {
                            HStack {
                                Text("Additional Features")
                                    .bold()
                                    .font(.title2)
                                    .foregroundColor(AppColor.foreground)
                                Spacer()
                            }
                            .padding()
                            SmallButtonComponent_NavigationLink(destination: {
                                SettingsDetailView_PhoneBodyOffset()
                            }, label: "Phone - Body Offset")
                        }
                        
                        //add settings to replay tutorial? Or have chapters they can look at. 
                    }
                }
            Spacer()
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
