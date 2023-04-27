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
    @ObservedObject var positioningModel = PositioningModel.shared
    @ObservedObject var navigationManager = NavigationManager.shared
    
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
                                Image(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.green)
                            }.accessibilityLabel("Get directions")
                            //                        Image(systemName: "pause.circle.fill")
                            //                            .resizable()
                            //                            .frame(width: 100, height: 100)
                            //                            .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                        .background(AppColor.black)
                    }
                }
                .padding(.vertical, 100)
            }.onAppear() {
                // plan path
                if let startAnchorDetails = startAnchorDetails {
                    didLocalize = false
                    PathPlanner.shared.prepareToNavigate(from: startAnchorDetails, to: destinationAnchorDetails)
                    didPrepareToNavigate = true
                    checkLocalization(cloudAnchorsToCheck: positioningModel.resolvedCloudAnchors)
                } else {
                    // TODO: need something more subtle here based on quality of outdoor localization
                    didLocalize = true
                    PathPlanner.shared.prepareToNavigateFromOutdoors(to: destinationAnchorDetails)
                    navigationManager.startNavigating()
                }
                if !didLocalize {
                    AnnouncementManager.shared.announce(announcement: "Trying to align to your route. Scan your phone around to recognize your surroundings.")
                }
            }.onDisappear() {
                NavigationManager.shared.stopNavigating()
            }
        }.onReceive(positioningModel.$resolvedCloudAnchors) { newValue in
            checkLocalization(cloudAnchorsToCheck: newValue)
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
                    }
            }
        }
        
        if showingConfirmation {
            ExitNavigationAlertView(showingConfirmation: $showingConfirmation)
        }
    }
    
    private func checkLocalization(cloudAnchorsToCheck: Set<String>) {
        if let startAnchorDetails = startAnchorDetails, let startCloudID = startAnchorDetails.getCloudAnchorID(), cloudAnchorsToCheck.contains(startCloudID), !didLocalize {
            if !didPrepareToNavigate {
                PathPlanner.shared.prepareToNavigate(from: startAnchorDetails, to: destinationAnchorDetails)
                didPrepareToNavigate = true
            }
            didLocalize = true
            PathPlanner.shared.navigate(from: startAnchorDetails, to: destinationAnchorDetails)
        }
    }
    let popupEntry: String = "Testing Text"
    @State var showingConfirmation = false
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
                HStack {
                    Text("Arrived. You should be within one cane's length of your destination.")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.leading)
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

struct NavigatingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: LocationDataModel(anchorType: .busStop, associatedOutdoorFeature: nil, coordinates: CLLocationCoordinate2D(latitude: 37, longitude: -71), name: "Bus Stop 1"))
    }
}
