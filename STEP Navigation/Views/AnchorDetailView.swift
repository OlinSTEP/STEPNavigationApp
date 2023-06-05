//
//  AnchorDetailView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView: View {
    let anchorDetails: LocationDataModel
    
    var body: some View {
        VStack {
            if let currentLocation = PositioningModel.shared.currentLatLon {
                let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                let formattedDistance = String(format: "%.0f", distance)
                AnchorDetailsComponent(title: anchorDetails.getName(), distanceAway: formattedDistance)
            }
            Spacer()
            if anchorDetails.getAnchorType().isIndoors {
                SmallButtonComponent_NavigationLink(destination: {
                    ChooseStartAnchorView(destinationAnchorDetails: anchorDetails)
                                }, label: "Find Start Anchor")
            } else {
                SmallButtonComponent_NavigationLink(destination: {
                    NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: anchorDetails)
                                }, label: "Navigate")
            }
        }
    }
}
