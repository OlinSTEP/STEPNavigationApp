//
//  ExitNavigationAlertView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/18/23.
//

import SwiftUI

///This struct displays a confirmation  popup when a user attempts to exit the navigation session.
struct ExitPopup: View {
    /// Binding to a boolean value that indicates whether the confirmation popup is showing.
    @Binding var showingConfirmation: Bool
    
    var body: some View {
        VStack {
            VStack {
                Text("Are you sure you want to exit?")
                    .bold()
                    .font(.title2)
                Text("This will end the navigation session.")
                    .font(.title3)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            VStack {
                SmallButtonComponent_NavigationLink(destination: {
                                    MainView()
                                }, label: "Exit")
                .padding(.bottom, 2)
                SmallButtonComponent_Button(label: "Cancel", labelColor: AppColor.dark, backgroundColor: AppColor.grey, popupTrigger: $showingConfirmation, role: .cancel)
            }
            .padding()
        }
        .frame(width: 360, height: 250)
        .background(AppColor.light)
        .cornerRadius(20)
    }
}
