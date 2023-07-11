//
//  OverlaysAndPopups.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct ARViewTextOverlay<Destination: View>: View {
    let text: String
    let navLabel: String
    let navDestination: Destination
    let announce: String
    
    let buttonLabel: String
    let buttonAction: (() -> ())?
    let onAppear: (() -> ())?
    
    init(text: String = "", navLabel: String = "", navDestination: Destination = HomeView(), announce: String = "", buttonLabel: String = "", buttonAction: (() -> ())? = nil, onAppear: (() -> ())? = nil) {
        self.text = text
        self.navLabel = navLabel
        self.navDestination = navDestination
        self.announce = announce
        self.buttonLabel = buttonLabel
        self.buttonAction = buttonAction
        self.onAppear = onAppear
    }
    
    var body: some View {
        VStack {
            if !text.isEmpty {
                Text(text)
                    .foregroundColor(AppColor.background)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .bold()
            }
            if !buttonLabel.isEmpty, let buttonAction = buttonAction {
                SmallButton(action: {
                    buttonAction()
                }, label: buttonLabel, foregroundColor: AppColor.background, backgroundColor: AppColor.foreground, invert: true)
            }
            if !navLabel.isEmpty {
                SmallNavigationLink(destination: navDestination, label: navLabel, foregroundColor: AppColor.background, backgroundColor: AppColor.foreground)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.foreground)
        .onAppear {
            if !announce.isEmpty {
                AnnouncementManager.shared.announce(announcement: announce)
            }
            if let onAppear = onAppear {
                onAppear()
            }
        }
    }
}

struct ConfirmationPopup<Destination: View>: View {
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
                    .multilineTextAlignment(.center)
                if !subtitleText.isEmpty {
                    Text(subtitleText)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                }
            }
            .foregroundColor(AppColor.background)
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            
            VStack(spacing: 12) {
                SmallNavigationLink(destination: confirmButtonDestination, label: confirmButtonLabel, foregroundColor: AppColor.background, backgroundColor: AppColor.foreground, secondaryAction: secondaryAction)
                
                SmallButton(action: {
                    showingConfirmation = false
                }, label: "Cancel", foregroundColor: AppColor.background, backgroundColor: AppColor.foreground, invert: true)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .accessibilityAddTraits(.isModal)
        .frame(width: 360, height: 250)
        .background(AppColor.foreground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColor.background, style: StrokeStyle(lineWidth: 3))
        )
    }
    
}

struct LoadingPopup: View {
    @State private var isAnimating = false
    let text: String
    
    var body: some View {
        VStack {
            HStack {
                Text(text)
                    .foregroundColor(AppColor.foreground)
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(.horizontal)
            
            ZStack {
                Circle()
                    .stroke(AppColor.foreground, lineWidth: 5)
                    .frame(width: 100, height: 100)
                    .opacity(0.25)
                Circle()
                    .trim(from: 0.25, to: 1)
                    .stroke(AppColor.foreground, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            self.isAnimating = true
                        }
                    }
            }
            .accessibilityHidden(true)
            .frame(height: 100)
            .padding()
            .drawingGroup()
        }
        .accessibilityAddTraits(.isModal)
        .padding(.top, 20)
    }
}

///  This struct manages a help popup that displays the details of the user's start locations, end locations and their distances.
struct AnchorInfoPopup: View {
    @State var anchorDetailsStart: LocationDataModel?
    @State var anchorDetailsEnd: LocationDataModel
    @ObservedObject var positioningModel = PositioningModel.shared
    
    @Binding var showHelp: Bool

    var body: some View {
        VStack {
            ScreenHeader()
            FromToAnchorDetails(startAnchorDetails: $anchorDetailsStart, destinationAnchorDetails: $anchorDetailsEnd)
            Spacer()
            SmallButton(action: {
                showHelp.toggle()
            }, label: "Dismiss")
            .padding(.bottom, 40)
        }
        .accessibilityAddTraits(.isModal)
        .background(AppColor.background)
    }
}
