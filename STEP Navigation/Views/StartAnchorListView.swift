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
//    @State var chosenStart: LocationDataModel?
//    @State var outdoorsSelectedAsStart = false
    @ObservedObject var positionModel = PositioningModel.shared
    @State var anchors: [LocationDataModel] = []
        
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Choose Start Anchor")
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

