//
//  AnchorDetailViewDouble.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/1/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView2PopUp: View {
    let anchorDetailsStart: LocationDataModel
    let anchorDetailsEnd: LocationDataModel
    
    @Binding var showHelp: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("FROM")
                    .font(.title2)
                    .padding(.horizontal)
                    .padding(.top)
                Spacer()
            }
            
            if let currentLocation = PositioningModel.shared.currentLatLon {
                let distance = currentLocation.distance(from: anchorDetailsStart.getLocationCoordinate())
                let formattedDistance = String(format: "%.0f", distance)
                AnchorDetailsComponent(title: anchorDetailsStart.getName(), distanceAway: formattedDistance)
//                    .padding(.bottom, 5)
            }
            
            HStack {
                Text("TO")
                    .font(.title2)
                    .padding(.horizontal)
                    .padding(.top)
                Spacer()
            }
                
            if let currentLocation = PositioningModel.shared.currentLatLon {
                let distance = currentLocation.distance(from: anchorDetailsEnd.getLocationCoordinate())
                let formattedDistance = String(format: "%.0f", distance)
                AnchorDetailsComponent(title: anchorDetailsEnd.getName(), distanceAway: formattedDistance)
                    .padding(.bottom, 5)
            }
            
            Spacer()
            SmallButtonComponent_Button(label: "Dismiss", popupTrigger: $showHelp)
        }
        .padding(.horizontal)
        .background(AppColor.light)
    }
}

