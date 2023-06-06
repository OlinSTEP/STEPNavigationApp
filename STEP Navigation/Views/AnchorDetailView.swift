//
//  AnchorDetailView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView<Destination: View>: View {
    let anchorDetails: LocationDataModel
    let buttonLabel: String
    let buttonDestination: () -> Destination
    
    var body: some View {
        VStack {
            if let currentLocation = PositioningModel.shared.currentLatLon {
                let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                let formattedDistance = String(format: "%.0f", distance)
                AnchorDetailsComponent(title: anchorDetails.getName(), distanceAway: formattedDistance)
                    .padding(.top)
            }
            Spacer()
            SmallButtonComponent_NavigationLink(destination: buttonDestination, label: buttonLabel)
            
//            if anchorDetails.getAnchorType().isIndoors {
//                SmallButtonComponent_NavigationLink(destination: {
//                    StartAnchorListView(destinationAnchorDetails: anchorDetails)
//                                }, label: "Find Start Anchor")
//            } else {
//                SmallButtonComponent_NavigationLink(destination: {
//                    NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: anchorDetails)
//                                }, label: "Navigate")
//
//                SmallButtonComponent_NavigationLink(destination: {
//                    NavigatingView(startAnchorDetails: chosenStart, destinationAnchorDetails: destinationAnchorDetails!)
//                                }, label: "Navigate")
//
//            }
        }
    }
}
