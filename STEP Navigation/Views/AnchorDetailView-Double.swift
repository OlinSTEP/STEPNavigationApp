//
//  AnchorDetailView-Double.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/1/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailViewDouble: View {
    let anchorDetails: LocationDataModel
    
    var body: some View {
        ZStack {
            VStack {
                //need to add in 20 units of spacing colored spacing here
                HStack {
                    Text(anchorDetails.getName())
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 2)
                    Spacer()
                }
                
                HStack {
                    if let currentLocation = PositioningModel.shared.currentLatLon {
                        let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                        let formattedDistance = String(format: "%.0f", distance)
                        Text("\(formattedDistance) meters away")
                            .font(.title)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Location Notes")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    HStack {
                        if let notes = anchorDetails.getNotes(), notes != "" {
                            Text("\(notes)")
                        }
                        else {
                            Text("No notes available for this location.")
                        }
                        Spacer()
                    }
                }
                .padding()
                                
                Spacer()
                if anchorDetails.getAnchorType().isIndoors {
                    NavigationLink (destination: ChooseStartAnchorView(destinationAnchorDetails: anchorDetails), label: {
                        Text("Find Start Anchor")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: 300)
                            .foregroundColor(AppColor.black)
                    })
                    .padding(.bottom, 20)
                    .tint(AppColor.accent)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                } else {
                    NavigationLink (destination: NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: anchorDetails), label: {
                        Text("Navigate")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: 300)
                            .foregroundColor(AppColor.black)
                    })
                    .padding(.bottom, 20)
                    .tint(AppColor.accent)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                }
            }
        }
    }
}
