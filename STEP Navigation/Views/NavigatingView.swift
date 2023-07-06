//
//  NavigatingView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation
import Foundation
import ARKit

struct NavigatingView: View {
    @State var hideNavTimer: Timer?
    let startAnchorDetails: LocationDataModel?
    let destinationAnchorDetails: LocationDataModel
    @State var didLocalize = false
    @State var didPrepareToNavigate = false
    @State var navigationDirection: String = ""
    @ObservedObject var navigationManager = NavigationManager.shared
    @ObservedObject var routeNavigator = RouteNavigator.shared
    
    @State var showingConfirmation = false
    @State var showingHelp = false
    @AccessibilityFocusState var focusOnAnchorInfo
    @AccessibilityFocusState var focusOnExit

    var body: some View {
        Group {
            ZStack {
                ARViewContainer()
                VStack {
                    Spacer()
                    VStack {
                        if !didLocalize {
                            ARViewTextOverlay(text: "Trying to align to your route. Scan your phone around to recognize your surroundings.")
                        } else {
                            if RouteNavigator.shared.keypoints?.isEmpty == true {
                                ARViewTextOverlay(text: "Arrived. You should be within a cane's length of your destination.", navLabel: "Go to Destination Details", navDestination: AnchorDetailView_NavigationArrived(anchorDetails: destinationAnchorDetails))
                            } else if !navigationDirection.isEmpty {
                                ARViewTextOverlay(text: navigationDirection)
                            }
                        }
                        Spacer()
                        if didLocalize && RouteNavigator.shared.keypoints?.isEmpty == false {
                            HStack {
                                Spacer()
                                Button(action: {
                                    navigationManager.updateDirections()
                                }, label: {
                                    Image(systemName: "repeat")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(AppColor.background)
                                })
                                .accessibilityLabel("Repeat Directions")
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 140)
                            .background(AppColor.foreground)
                            Spacer()
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
                    AnchorInfoPopup(anchorDetailsStart: startAnchorDetails, anchorDetailsEnd: destinationAnchorDetails, showHelp: $showingHelp)
                        .accessibilityFocused($focusOnAnchorInfo)
                }
                
                if showingConfirmation {
                    ConfirmationPopup(showingConfirmation: $showingConfirmation, titleText: "Are you sure you want to exit?", subtitleText: "This will end the navigation session.", confirmButtonLabel: "Exit", confirmButtonDestination: NavigationFeedbackView())
                        .accessibilityFocused($focusOnExit)
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
            .background(AppColor.foreground)
            .navigationBarBackButtonHidden()
            .toolbar {
                HeaderButton(label: "Exit", placement: .navigationBarLeading) {
                    showingConfirmation = true
                    focusOnExit = true
                }
                HeaderButton(label: "Anchor Info", placement: .navigationBarTrailing) {
                    showingHelp = true
                    focusOnAnchorInfo = true
                }
            }
        }
        .padding(.bottom, 48)
        .background(AppColor.foreground)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func checkLocalization(cloudAnchorsToCheck: Set<String>) {
        if let startAnchorDetails = startAnchorDetails, let startCloudID = startAnchorDetails.getCloudAnchorID(), cloudAnchorsToCheck.contains(startCloudID), !didLocalize {
            didLocalize = true
            navigationManager.startNavigating()
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARSCNView {
        return PositioningModel.shared.arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
}


