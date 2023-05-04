//
//  ChooseStartAnchorView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/28/23.
//

import SwiftUI
import CoreLocation

struct ChooseStartAnchorView: View {
    @State var destinationAnchorDetails: LocationDataModel?
    @State var nearbyDistance: Double = 300.0
    @State var chosenStart: LocationDataModel?
    @State var outdoorsSelectedAsStart = false
    @ObservedObject var positionModel = PositioningModel.shared
    @State var anchors: [LocationDataModel] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("Choose Start Anchor")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, 20)
            
            NearbyDistanceThresholdView(nearbyDistance: $nearbyDistance)
        }
        .background(AppColor.accent)
        
        VStack {
            ChooseAnchorComponentView(anchorSelectionType: .startOfIndoorRoute,
                                      anchors: $anchors,
                                      allAnchors: $anchors,
                                      chosenAnchor: $chosenStart, outdoorsSelected: $outdoorsSelectedAsStart,
                                      otherAnchor: $destinationAnchorDetails)
            Spacer()
            if chosenStart != nil || outdoorsSelectedAsStart {
                NavigationLink (destination: NavigatingView(startAnchorDetails: chosenStart, destinationAnchorDetails: destinationAnchorDetails!), label: {
                    Text("Navigate")
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
        }.onReceive(positionModel.$currentLatLon) { latLon in
            guard let latLon = latLon else {
                return
            }
            anchors = Array(
                DataModelManager.shared.getNearbyLocations(
                    for: .indoorDestination,
                    location: latLon,
                    maxDistance: CLLocationDistance(nearbyDistance),
                    withBuffer: LocalAnchorListView.getBufferDistance(positionModel.geoLocalizationAccuracy)
                )
            )
            .sorted(by: {
                $0.getName() < $1.getName()         // sort in alphabetical order (could also do by distance as we have done in another branch)
            })
        }
    }
}
