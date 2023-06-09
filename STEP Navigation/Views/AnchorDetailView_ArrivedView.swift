//
//  AnchorDetailView_ArrivedView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView_ArrivedView: View {
    let anchorDetails = LocationDataModel(anchorType: .frontdesk, coordinates: CLLocationCoordinate2D(latitude: 42.0, longitude: -71.0), name: "Sample Destination", id: UUID().uuidString)
    
    var body: some View {
        VStack {
            if let currentLocation = PositioningModel.shared.currentLatLon {
                let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                let formattedDistance = String(format: "%.0f", distance)
                AnchorDetailsComponent(title: anchorDetails.getName(), distanceAway: formattedDistance)
                    .padding(.top)
            }
            Spacer()
            SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Home")
        }
    }
}
