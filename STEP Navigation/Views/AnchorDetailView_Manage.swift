//
//  AnchorDetailView_MultipleButtons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView_Manage: View {
    let anchorDetails: LocationDataModel
    
    var body: some View {
        VStack {
            if let currentLocation = PositioningModel.shared.currentLatLon {
                let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                let formattedDistance = String(format: "%.0f", distance)
                AnchorDetailsComponent(title: anchorDetails.getName(), distanceAway: formattedDistance)
                    .padding(.top)
            }
            Spacer()
            VStack(spacing: 10) {
                SmallButtonComponent_NavigationLink(destination: {
                    AnchorDetailEditView(buttonText: "Testing")
                }, label: "Edit")
                SmallButtonComponent_NavigationLink(destination: {
                    ConnectingView()
                }, label: "Connect")
//                SmallButtonComponent_Button(label: "Delete", popupTrigger: Binding<Bool>)
            }
        }
    }
}
