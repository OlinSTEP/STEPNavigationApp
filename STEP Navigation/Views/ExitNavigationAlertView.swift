//
//  ExitNavigationAlertView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/18/23.
//

import SwiftUI

struct ExitNavigationAlertView: View {
    var showingConfirmation: Binding<Bool>
    
    var body: some View {
        VStack {
            VStack {
                Text("Are you sure you want to exit?")
                    .bold()
                    .font(.title2)
                Text("This will end the navigation session.")
                    .font(.title3)
            }
            .padding()
            VStack {
                NavigationLink (destination: AnchorTypeListView(), label: {
                    Text("Exit")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: 300)
                        .foregroundColor(AppColor.black)
                })
                .padding(.bottom, 5)
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                
                Button(role: .cancel) {
                    showingConfirmation.wrappedValue = false
                } label: {
                    Text("Cancel")
                        .padding(.horizontal, 50)
                        .bold()
                        .font(.title2)
                        .frame(maxWidth: 300)
                        .foregroundColor(AppColor.black)
                }
                .tint(AppColor.grey)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
            .padding()
        }
        .frame(width: 360, height: 250)
        .background(AppColor.white)
        .cornerRadius(20)
    }
}

//struct ExitNavigationAlertView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExitNavigationAlertView(showingConfirmation: Binding<Bool>(true))
//    }
//}
