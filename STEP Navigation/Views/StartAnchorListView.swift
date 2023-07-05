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
    @ObservedObject var positionModel = PositioningModel.shared
    @State var anchors: [LocationDataModel] = []
        
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Choose Start Anchor") //TODO: text "back" on back button doesn't display; back arrow displays and takes you back, but text isn't there
                ScrollView {
                    ListOfAnchors(anchors: anchors, anchorSelectionType: .indoorStartingPoint(selectedDestination: destinationAnchorDetails!))
                    Spacer()
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
                        $0.getName() < $1.getName()
                    })
                }
            }
        }
    }
}

