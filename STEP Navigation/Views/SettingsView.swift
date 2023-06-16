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
            VStack(spacing: 20) {
                VStack {
                    Text("Color")
                    SmallButtonComponent_NavigationLink(destination: {
                        SettingsDetailView_ColorScheme()
                    }, label: "Color Scheme")
                    SmallButtonComponent_NavigationLink(destination: {
                        SettingsDetailView_CrumbColor()
                    }, label: "Crumb Color")
                }
            }
            Spacer()
        }
//        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                NavigationLink(destination: HomeView(), label: {
//                    Text("Home")
//                        .bold()
//                        .font(.title2)
//                })
//            }
//        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
