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
                .padding(.bottom, 40)
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
