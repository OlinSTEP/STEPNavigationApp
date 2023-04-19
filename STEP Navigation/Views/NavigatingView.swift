//
//  NavigatingView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct NavigatingView: View {
    let startAnchorDetails: LocationDataModel?
    let destinationAnchorDetails: LocationDataModel
    @State var didLocalize = false
    @State var didPrepareToNavigate = false
    @ObservedObject var positioningModel = PositioningModel.shared
    @ObservedObject var navigationManager = NavigationManager.shared
    
    var body: some View {
        ZStack {
            ARViewContainer()
            VStack {
                Spacer()
                VStack {
                    if !didLocalize {
                        InformationPopup(popupEntry: "7", popupType: .waitingToLocalize, units: .none)
                    } else {
                        if RouteNavigator.shared.keypoints?.isEmpty == true {
                            InformationPopup(popupEntry: "7", popupType: .arrived, units: .none)
                        } else {
                            InformationPopup(popupEntry: "\(Int(round(RouteNavigator.shared.getRemainingRouteDistance()*100/2.54/12))) ft", popupType: .distanceAway, units: .none)
                        }
                    }
                    Spacer()
                    HStack {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(AppColor.black)
                }
                .padding(.vertical, 100)
            }.onAppear() {
                // plan path
                didLocalize = false
                if let startAnchorDetails = startAnchorDetails {
                    PathPlanner.shared.prepareToNavigate(from: startAnchorDetails, to: destinationAnchorDetails)
                    didPrepareToNavigate = true
                    checkLocalization(cloudAnchorsToCheck: positioningModel.resolvedCloudAnchors)
                } else {
                    PathPlanner.shared.navigate(to: destinationAnchorDetails)
                }
            }.onDisappear() {
                NavigationManager.shared.stopNavigating()
            }
        }.onReceive(positioningModel.$resolvedCloudAnchors) { newValue in
            checkLocalization(cloudAnchorsToCheck: newValue)
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
}

struct InformationPopup: View {
    let popupEntry: String
    let popupType: PopupType
    let units: Units

    var body: some View {
        VStack {
//            HStack {
//                Text("\(popupType.rawValue)")
//                    .foregroundColor(AppColor.white)
//                    .bold()
//                    .font(.title2)
//                    .multilineTextAlignment(.leading)
//                Spacer()
//            }
            
            switch popupType {
            case .waitingToLocalize:
                HStack {
                    Text("Waiting to localize")
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
    }
    
    enum Units: String, CaseIterable {
        case meters = "meters"
        case feet = "feet"
        case none = ""
    }
}

struct NavigatingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: LocationDataModel(anchorType: .busStop, coordinates: CLLocationCoordinate2D(latitude: 37, longitude: -71), name: "Bus Stop 1"))
    }
}
