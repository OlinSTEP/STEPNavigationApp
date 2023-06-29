//
//  OverlaysAndPopups.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct ARViewTextOverlay<Destination: View>: View {
    let text: String
    let buttonLabel: String
    let buttonDestination: Destination?
    let announce: String
    
    init(text: String = "", buttonLabel: String = "", buttonDestination: Destination? = nil, announce: String = "") {
        self.text = text
        self.buttonLabel = buttonLabel
        self.buttonDestination = buttonDestination
        self.announce = announce
    }
    
    var body: some View {
        VStack {
            if !text.isEmpty {
                Text(text)
                    .foregroundColor(AppColor.background)
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            if !buttonLabel.isEmpty && buttonDestination != nil {
                SmallNavigationLink(destination: buttonDestination, label: buttonLabel, foregroundColor: AppColor.background, backgroundColor: AppColor.foreground)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.foreground)
        .onAppear() {
            if !announce.isEmpty {
                AnnouncementManager.shared.announce(announcement: announce)
            }
        }
    }
}

struct ConfirmationPopup2<Destination: View>: View {
    @Binding var showingConfirmation: Bool
    let titleText: String
    let subtitleText: String
    let confirmButtonLabel: String
    let confirmButtonDestination: Destination
    let secondaryAction: () -> Void
        
    init(showingConfirmation: Binding<Bool>, titleText: String, subtitleText: String = "", confirmButtonLabel: String, confirmButtonDestination: Destination, secondaryAction: @escaping () -> Void = {}) {
        self._showingConfirmation = showingConfirmation
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.confirmButtonLabel = confirmButtonLabel
        self.confirmButtonDestination = confirmButtonDestination
        self.secondaryAction = secondaryAction
    }
    
    var body: some View {
        VStack {
            VStack {
                Text(titleText)
                    .bold()
                    .font(.title2)
                    .foregroundColor(AppColor.background)
                if !subtitleText.isEmpty {
                    Text(subtitleText)
                        .font(.title3)
                        .foregroundColor(AppColor.background)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            VStack {
                SmallNavigationLink(destination: confirmButtonDestination, label: confirmButtonLabel, foregroundColor: AppColor.background, backgroundColor: AppColor.foreground, secondaryAction: secondaryAction)
                
                SmallButton(action: {
                    showingConfirmation = false
                }, label: "Cancel", foregroundColor: AppColor.background, backgroundColor: AppColor.foreground, invert: true)
            }
            .padding()
        }
        .frame(width: 360, height: 250)
        .background(AppColor.foreground)
        .cornerRadius(20)
    }
    
}
