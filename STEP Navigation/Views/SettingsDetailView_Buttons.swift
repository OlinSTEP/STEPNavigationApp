//
//  SettingsDetailView_Buttons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/13/23.
//

import SwiftUI

struct SettingsDetailView_CrumbColor: View {
    @State var selectedCrumbColor: Color?
//    @EnvironmentObject var selectedCrumbColor: Color
    var backgroundColor: Color?
    
    init(selectedCrumbColor: Color? = AppColor.accent, backgroundColor: Color? = nil) {
        self.selectedCrumbColor = selectedCrumbColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        
        let crumbColorOptions = [
            CrumbColors(label: "Default", color: AppColor.accent),
            CrumbColors(label: "Red", color: AppColor.lightred),
            CrumbColors(label: "Blue", color: AppColor.lightblue),
            CrumbColors(label: "Green", color: AppColor.lightgreen)
        ]
        
        VStack {
            ScreenTitleComponent(titleText: "Crumb Color", subtitleText: "Set the color of the box-shaped crumb for navigating.")
            VStack {
                ForEach(crumbColorOptions) { item in
                    SmallButtonComponent_Button(label: item.label, action: {
                        selectedCrumbColor = item.color
                    }, backgroundColor: selectedCrumbColor == item.color ? item.color : AppColor.grey)
                }
                .padding(.vertical, 2)
            }
            .padding(.top, 20)

            Spacer()
            
            SmallButtonComponent_NavigationLink(destination: {
                SettingsView()
            }, label: "Save")
        }
        .navigationBarBackButtonHidden()
    }
}


struct CrumbColors: Identifiable {
    var label: String
    var color: Color
    var id = UUID()
}
