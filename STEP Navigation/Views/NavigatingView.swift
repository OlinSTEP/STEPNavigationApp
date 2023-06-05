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
    
    @State var showingConfirmation = false
    @State var showingHelp = false
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
                        HStack(spacing: 100) {
                            ActionBarButtonComponent(action: {
                                print("pressed pause")
                            }, iconSystemName: "pause.circle.fill", accessibilityLabel: "Pause Navigation")
                            
                            ActionBarButtonComponent(action: {
                                navigationManager.updateDirections()
                            }, iconSystemName: "repeat", accessibilityLabel: "Repeat Directions")
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
            
            if showingHelp {
                HelpPopup(anchorDetailsStart: startAnchorDetails, anchorDetailsEnd: destinationAnchorDetails, showHelp: $showingHelp)
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
            CustomHeaderButtonComponent(label: "Exit", placement: .navigationBarLeading) {
                showingConfirmation = true
                focusOnPopup = true
            }
            CustomHeaderButtonComponent(label: "Help", placement: .navigationBarTrailing) {
                showingHelp = true
                focusOnPopup = true
            }
        }
    }
    
    private func checkLocalization(cloudAnchorsToCheck: Set<String>) {
        if let startAnchorDetails = startAnchorDetails, let startCloudID = startAnchorDetails.getCloudAnchorID(), cloudAnchorsToCheck.contains(startCloudID), !didLocalize {
            didLocalize = true
            navigationManager.startNavigating()
        }
    }
}
