//
//  NavigatingView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

//TODO: add a statement that checks if the user has arrived, and if so, take them to the arrived view. Need to pass in destinationAnchorDetails into the arrived view.

// TODO: ughh what to do about this global variable
var hideNavTimer: Timer?

struct NavigatingView: View {
    
    let startAnchorDetails: LocationDataModel?
    let destinationAnchorDetails: LocationDataModel
    @State var didLocalize = false
    @State var didPrepareToNavigate = false
    @State var navigationDirection: String = ""
    @ObservedObject var navigationManager = NavigationManager.shared
    @ObservedObject var routeNavigator = RouteNavigator.shared
    
    @AccessibilityFocusState var focusOnPopup
    
    var body: some View {
        ZStack {
            ARViewContainer()
            VStack {
                Spacer()
                VStack {
                    if !didLocalize {
                        InformationPopupComponent(popupType: .waitingToLocalize)
                    } else {
                        if RouteNavigator.shared.keypoints?.isEmpty == true {
                            InformationPopupComponent(popupType: .arrived)
                        } else if !navigationDirection.isEmpty {
                            InformationPopupComponent(popupType: .direction(directionText: navigationDirection))
                        }
                    }
                    Spacer()
                    if didLocalize && RouteNavigator.shared.keypoints?.isEmpty == false {
                        HStack {
                            Button(action: {
                                navigationManager.updateDirections()
                            }) {
                                Image(systemName: "repeat")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(AppColor.accent)
                            }.accessibilityLabel("Repeat Directions")
                            Button(action: {
                                print("pressed pause")
                            }) {
                                Image(systemName: "pause")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(AppColor.accent)
                            }.accessibilityLabel("Pause Directions")
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .background(AppColor.dark)
                    }
                }
                .padding(.vertical, 100)
            }.onAppear() {
                // start up the positioning
                didLocalize = false
                didPrepareToNavigate = false
                PositioningModel.shared.startPositioning()
                if !didLocalize {
                    AnnouncementManager.shared.announce(announcement: "Trying to align to your route. Scan your phone around to recognize your surroundings.")
                }
            }.onDisappear() {
                PositioningModel.shared.stopPositioning()
                NavigationManager.shared.stopNavigating()
            }
            
            if showHelp {
                HelpPopup(anchorDetailsStart: startAnchorDetails, anchorDetailsEnd: destinationAnchorDetails, showHelp: $showHelp)
                    .accessibilityFocused($focusOnPopup)
                    .accessibilityAddTraits(.isModal)
            }
            
            if showingConfirmation {
                ExitPopup(showingConfirmation: $showingConfirmation)
                    .accessibilityFocused($focusOnPopup)
                    .accessibilityAddTraits(.isModal)
            }
            
        }.onReceive(PositioningModel.shared.$resolvedCloudAnchors) { newValue in
            checkLocalization(cloudAnchorsToCheck: newValue)
        }.onReceive(PositioningModel.shared.$geoLocalizationAccuracy) { newValue in
            guard !didPrepareToNavigate else {
                return
            }
            // plan path
            if let startAnchorDetails = startAnchorDetails, newValue.isAtLeastAsGoodAs(other: .low) {
                didPrepareToNavigate = true
                PathPlanner.shared.prepareToNavigate(from: startAnchorDetails, to: destinationAnchorDetails) { wasSuccesful in
                    guard wasSuccesful else {
                        return
                    }
                    checkLocalization(cloudAnchorsToCheck: PositioningModel.shared.resolvedCloudAnchors)
                }
            } else if newValue.isAtLeastAsGoodAs(other: .high) {
                didLocalize = true
                if !didPrepareToNavigate {
                    didPrepareToNavigate = true
                    PathPlanner.shared.startNavigatingFromOutdoors(to: destinationAnchorDetails)
                }
            }
        }.onReceive(navigationManager.$navigationDirection) {
            newValue in
            hideNavTimer?.invalidate()
            navigationDirection = newValue ?? ""
            hideNavTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                navigationDirection = ""
            }
        }
        .background(AppColor.accent)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Help")
                    .bold()
                    .font(.title2)
                    .onTapGesture {
                        showHelp = true
                        focusOnPopup = true
                    }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Exit")
                    .bold()
                    .font(.title2)
                    .onTapGesture {
                        showingConfirmation = true
                        focusOnPopup = true
                    }
            }
        }
    }
    
    private func checkLocalization(cloudAnchorsToCheck: Set<String>) {
        if let startAnchorDetails = startAnchorDetails, let startCloudID = startAnchorDetails.getCloudAnchorID(), cloudAnchorsToCheck.contains(startCloudID), !didLocalize {
            didLocalize = true
            navigationManager.startNavigating()
        }
    }
    let popupEntry: String = "Testing Text"
    @State var showingConfirmation = false
    @State var showHelp = false
}

//struct InformationPopup: View {
//    let popupType: PopupType
//
//    var body: some View {
//        VStack {
//            HStack {
//                Text(popupType.messageText)
//                    .foregroundColor(AppColor.light)
//                    .bold()
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//            }
//            if case .arrived = popupType {
//                SmallButtonComponent_NavigationLink(destination: {
//                    MainView()
//                }, label: "Home")
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(AppColor.dark)
//    }
//
//    enum PopupType {
//        case waitingToLocalize
//        case arrived
//        case direction(directionText: String)
//
//        var messageText: String {
//            switch self {
//            case .arrived:
//                return "Arrived. You should be within one cane's length of your destination."
//            case . waitingToLocalize:
//                return "Trying to align to your route. Scan your phone around to recognize your surroundings."
//            case .direction(let directionText):
//                return directionText
//            }
//        }
//    }
//}
