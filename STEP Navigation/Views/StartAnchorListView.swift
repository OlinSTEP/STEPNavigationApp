//
//  StartAnchorListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/28/23.
//

import SwiftUI
import CoreLocation

struct StartAnchorListView: View {
    @State var destinationAnchorDetails: LocationDataModel?
    @State var nearbyDistance: Double = 300.0
    @State var chosenStart: LocationDataModel?
    @State var outdoorsSelectedAsStart = false
    @ObservedObject var positionModel = PositioningModel.shared
    @State var anchors: [LocationDataModel] = []
        
    var body: some View {
        ScreenTitleComponent(titleText:"Choose Start Anchor")
        VStack {
            NavigateAnchorListComponent(anchorSelectionType: .indoorStartingPoint(selectedDestination: destinationAnchorDetails!),
                                      anchors: anchors)
            Spacer()
        }
        .onChange(of: chosenStart) { newValue in
            print("HERE WE ARE")
        }
        .onReceive(positionModel.$currentLatLon) { latLon in
            guard let latLon = latLon else {
                return
            }
            anchors = Array(
                DataModelManager.shared.getNearbyIndoorLocations(
                    location: latLon,
                    maxDistance: CLLocationDistance(nearbyDistance),
                    withBuffer: DestinationAnchorListView.getBufferDistance(positionModel.geoLocalizationAccuracy)
                )
            )
            .sorted(by: {
                $0.getName() < $1.getName()         // sort in alphabetical order (could also do by distance as we have done in another branch)
            })
        }
    }
}
