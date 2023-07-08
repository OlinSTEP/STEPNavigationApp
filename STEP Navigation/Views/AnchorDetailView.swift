//
//  AnchorDetailView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView<Destination: View>: View {
    @State var startAnchorDetails: LocationDataModel?
    @State var destinationAnchorDetails: LocationDataModel
    let buttonLabel: String
    let buttonDestination: Destination
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Anchor Details")
                FromToAnchorDetails(startAnchorDetails: $startAnchorDetails, destinationAnchorDetails: $destinationAnchorDetails)
                Spacer()
                VStack(spacing: 28) {
//                    SmallButton(action: {
//                        if startAnchorDetails != nil {
//                            self.startAnchorDetails! = self.destinationAnchorDetails
//                            self.destinationAnchorDetails = self.startAnchorDetails!
//                        }
//                    }, label: "Switch Anchors", invert: true)
                    SmallNavigationLink(destination: buttonDestination, label: buttonLabel)
                }
            }
        }
    }
}

struct FromToAnchorDetails: View {
    @Binding var startAnchorDetails: LocationDataModel?
    @Binding var destinationAnchorDetails: LocationDataModel
    
    var body: some View {
        ScrollView {
            HStack {
                Text("FROM")
                    .font(.title2)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 1)
                    .foregroundColor(AppColor.foreground)
                Spacer()
            }
            if let startDetails = startAnchorDetails {
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: startDetails.getLocationCoordinate())
                    AnchorDetailsText(anchorDetails: .init(get: { startDetails }, set: { newValue in
                                    startAnchorDetails = newValue
                    }), distanceAway: distance)
                }
            } else {
                HStack {
                    Text("Start Outside")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(AppColor.foreground)
                    Spacer()
                }
            }
            HStack {
                Text("TO")
                    .font(.title2)
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 1)
                    .foregroundColor(AppColor.foreground)
                
                Spacer()
            }
            if let currentLocation = PositioningModel.shared.currentLatLon {
                let distance = currentLocation.distance(from: destinationAnchorDetails.getLocationCoordinate())
                AnchorDetailsText(anchorDetails: $destinationAnchorDetails, distanceAway: distance)
            }
        }
    }
}
