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
                        InformationPopup(popupEntry: "", popupType: .waitingToLocalize, units: .none) //what is this? why do we still have units and stuff?
                    } else {
                        if RouteNavigator.shared.keypoints?.isEmpty == true {
                            InformationPopup(popupEntry: "", popupType: .arrived, units: .none)
                        } else if !navigationDirection.isEmpty {
                            InformationPopup(popupEntry: navigationDirection, popupType: .direction, units: .none)
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
                        .background(AppColor.black)
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
                //note: I am currently force unwrapping these. this is probably a bad idea??
                AnchorDetailView2PopUp(anchorDetailsStart: startAnchorDetails!, anchorDetailsEnd: destinationAnchorDetails, showHelp: $showHelp)
                    .accessibilityFocused($focusOnPopup)
                    .accessibilityAddTraits(.isModal)
            }
            
            if showingConfirmation {
                ExitNavigationAlertView(showingConfirmation: $showingConfirmation)
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
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Exit")
                    .bold()
                    .font(.title2)
                    .onTapGesture {
                        showingConfirmation = true
                        focusOnPopup = true
                    }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("Help")
                    .bold()
                    .font(.title2)
                    .onTapGesture {
                        showHelp = true
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

struct InformationPopup: View {
    let popupEntry: String
    let popupType: PopupType
    let units: Units
    
    var body: some View {
        VStack {
            switch popupType {
            case .waitingToLocalize:
                HStack {
                    Text("Trying to align to your route. Scan your phone around to recognize your surroundings.")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            case .userNote:
                HStack {
                    Text("User Note")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    Text(popupEntry)
                        .foregroundColor(AppColor.white)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            case .distanceAway:
                HStack {
                    Text("\(popupEntry) \(units.rawValue) away")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            case .direction:
                HStack {
                    Text("\(popupEntry)")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            case .arrived:
                VStack {
                    HStack {
                        Text("Arrived. You should be within one cane's length of your destination.")
                            .foregroundColor(AppColor.white)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.leading)
                    }
                    NavigationLink (destination: MainView(), label: {
                        Text("Home")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: 300)
                            .foregroundColor(AppColor.black)
                    })
                    .padding(.bottom, 20)
                    .padding(.top, 10)
                    .tint(AppColor.accent)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.black)
    }
    
    enum PopupType: CaseIterable {
        case waitingToLocalize
        case userNote
        case distanceAway
        case arrived
        case direction
    }
    
    enum Units: String, CaseIterable {
        case meters = "meters"
        case feet = "feet"
        case none = ""
    }
}
