//
//  ManageAnchorsListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import CoreLocation

struct ManageAnchorsListView: View {
    @ObservedObject var positionModel = PositioningModel.shared
    @State var anchors: [LocationDataModel] = []
    @State var lastQueryLocation: CLLocationCoordinate2D?
    
    var body: some View {
        ScreenTitleComponent(titleText: "Anchors", subtitleText: "At *organization name*")
        
        ScrollView {
            SmallButtonComponent_NavigationLink(destination: {
                RecordAnchorView()
            }, label: "Create New Anchor")
            .padding(.top, 20)
            
            MappingAnchorListComponent(anchors: anchors)
            Spacer()
        }
        .onReceive(positionModel.$currentLatLon) { latLon in
        guard let latLon = latLon else {
            return
        }
        guard lastQueryLocation == nil || lastQueryLocation!.distance(from: latLon) > 5.0 else {
            return
        }
        lastQueryLocation = latLon
        anchors = Array(
            DataModelManager.shared.getNearbyIndoorLocations(
                location: latLon,
                maxDistance: CLLocationDistance(Double.infinity),
                withBuffer: 0.0
            )
        )
        .sorted(by: {
            $0.getName() < $1.getName()         // sort in alphabetical order (could also do by distance as we have done in another branch)
        })
        
        }
    }
}
