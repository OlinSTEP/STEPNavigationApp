//
//  AnchorDetailView-CloudAnchors.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/24/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView-CloudAnchors: View {
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
            
            CapsuleButton()

        }
        .navigationBarItems(
            trailing:
                Button(action: {
                    print("pressed settings")
                }) {
                    Image(systemName: "gearshape.fill")
                        .scaleEffect(1.5)
                        .foregroundColor(AppColor.black)
                }
        )
    }
}

struct AnchorDetailView_Previews: PreviewProvider {
    @State static var anchorDetails = LocationDataModel(anchorType: .externalDoor, coordinates: CLLocationCoordinate2D(latitude: 42, longitude: -71), name: "Test Door")

    
    static var previews: some View {
        AnchorDetailView(anchorDetails: anchorDetails)
    }
}
