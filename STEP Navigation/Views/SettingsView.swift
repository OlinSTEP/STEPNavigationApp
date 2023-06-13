//
//  SettingsView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScreenTitleComponent(titleText: "Settings")
        VStack(spacing: 20) {
            VStack {
                Text("Color")
                SmallButtonComponent_NavigationLink(destination: {
                    SettingsDetailView_CrumbColor()
                }, label: "Color Scheme")
                SmallButtonComponent_NavigationLink(destination: {
                    SettingsDetailView_CrumbColor()
                }, label: "Crumb Color")
            }
        }
        Spacer()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
