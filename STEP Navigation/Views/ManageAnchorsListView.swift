//
//  ManageAnchorsListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import CoreLocation

struct ManageAnchorsListView: View {
    @State var selectedOrganization: String = ""
    @State var showFilterPopup: Bool = false
    
    var body: some View {
        ScreenBackground {
            VStack {
                if showFilterPopup == false {
                    //Custom Header Component for Select Organization Picker integration
                    VStack {
                        HStack {
                            Text("Anchors")
                                .font(.largeTitle)
                                .bold()
                                .padding(.horizontal)
                                .foregroundColor(AppColor.background)
                            Spacer()
                        }
                        .padding(.bottom, 0.5)
                        HStack {
                            Text("At")
                                .font(.title2)
                                .padding(.leading)
                                .foregroundColor(AppColor.background)
                            OrganizationPicker(selectedOrganization: $selectedOrganization)
                            Spacer()
                        }
                        .padding(.bottom, 20)
                    }
                    .background(AppColor.foreground)
                }
                AnchorListViewWithFiltering(showFilterPopup: $showFilterPopup, selectedOrganization: $selectedOrganization)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            if showFilterPopup == false {
                CustomBackButton(destination: HomeView())
                HeaderButton(label: "Filter", placement: .navigationBarTrailing) {
                        showFilterPopup = true
                    }
                }
        }
    }
}
