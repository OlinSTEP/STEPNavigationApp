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
    let buttonDestination: Destination
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader()
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                    AnchorDetailsText(anchorDetails: anchorDetails)
                        .padding(.top)
                }
                Spacer()
                SmallNavigationLink(destination: buttonDestination, label: buttonLabel)
            }
        }
    }
}
