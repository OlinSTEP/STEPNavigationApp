//
//  SettingsDetailView_Buttons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/13/23.
//

import SwiftUI

struct SettingsDetailView_CrumbColor: View {
    @State var selectedCrumbColor: Color?
    var backgroundColor: Color?
    
    
    var body: some View {
        
        let crumbColorOptions = [
            CrumbColors(label: "Default", color: AppColor.accent),
            CrumbColors(label: "Red", color: AppColor.lightred),
            CrumbColors(label: "Blue", color: AppColor.lightblue),
        ]
        
        VStack {
            ForEach(crumbColorOptions) { item in
                SmallButtonComponent_Button(label: item.label) {
                    selectedCrumbColor = item.color
//                    backgroundColor = item.color
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
