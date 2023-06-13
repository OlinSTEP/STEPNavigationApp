//
//  SettingsDetailView_Buttons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/13/23.
//

import SwiftUI

struct SettingsDetailView_CrumbColor: View {
    @State var crumbColor: Color = AppColor.accent
    
    var body: some View {
        VStack {
            SmallButtonComponent_Button(label: "Default") {
                crumbColor = AppColor.accent
            }
            SmallButtonComponent_Button(label: "Red") {
                crumbColor = AppColor.lightred
            }
            SmallButtonComponent_Button(label: "Green") {
                crumbColor = AppColor.lightgreen
            }
            SmallButtonComponent_Button(label: "Blue") {
                crumbColor = AppColor.lightblue
            }
        }
    }
}
