//
//  AnchorDetailViewDouble.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/1/23.
//

import SwiftUI
import CoreLocation

///  This struct manages a help popup that displays the details of the user's start locations, end locations and their distances.
struct HelpPopup: View {
    let anchorDetailsStart: LocationDataModel?
    let anchorDetailsEnd: LocationDataModel
    @ObservedObject var positioningModel = PositioningModel.shared
    
    @Binding var showHelp: Bool
    
    var body: some View {
        VStack {
                HStack {
                    Text("FROM")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 1)
                    Spacer()
                }
            if let anchorDetailsStart = anchorDetailsStart {
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetailsStart.getLocationCoordinate())
                    let formattedDistance = String(format: "%.0f", distance)
                    AnchorDetailsComponent(title: anchorDetailsStart.getName(), distanceAway: formattedDistance)
                }
            } else {
                HStack {
                    Text("Started Outside")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
            }
                
                HStack {
                    Text("TO")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 1)
                    Spacer()
                }
                                
                if let currentLocation = positioningModel.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetailsEnd.getLocationCoordinate())
                    let formattedDistance = String(format: "%.0f", distance)
                    AnchorDetailsComponent(title: anchorDetailsEnd.getName(), distanceAway: formattedDistance)
                }
            
                Spacer()
                SmallButtonComponent_Button(label: "Dismiss", popupTrigger: $showHelp)
            }
            .background(AppColor.light)
    }
}

