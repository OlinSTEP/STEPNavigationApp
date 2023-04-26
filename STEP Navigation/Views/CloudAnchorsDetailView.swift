//
//  CloudAnchorsDetailView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/24/23.
//

import SwiftUI
import CoreLocation

struct CloudAnchorsDetailView: View {
    //can we make it so that there is just one anchor detail view file that can show both? maybe use if statements? need more info about how we pass lat/long anchors through the local anchor list view
    let startAnchorDetails: LocationDataModel
    let destinationAnchorDetails: LocationDataModel
    
    
    var body: some View {
            ZStack {
                VStack {
                    VStack {
                        HStack {
                            Text("FROM")
                                .font(.title3)
                                .fontWeight(.regular)
                                .padding(.horizontal)
                            Spacer()
                        }
                        
                        HStack {
                            Text(startAnchorDetails.getName())
                                .font(.largeTitle)
                                .bold()
                                .padding(.horizontal)
                            Spacer()
                        }
                        
                        HStack {
                            if let currentLocation = PositioningModel.shared.currentLatLon {
                                let distance = currentLocation.distance(from: startAnchorDetails.getLocationCoordinate())
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
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.top, 1)
                            .padding(.bottom, 0.5)
                            
                            HStack {
                                if let notes = startAnchorDetails.getNotes(), notes != "" {
                                    Text("\(notes)")
                                }
                                else {
                                    Text("No notes available for this location.")
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 80)
                    .padding(.top, 10)

                    
                    VStack {
                        HStack {
                            Text("TO")
                                .font(.title3)
                                .fontWeight(.regular)
                                .padding(.horizontal)
                            Spacer()
                        }
                        
                        HStack {
                            Text(destinationAnchorDetails.getName())
                                .font(.largeTitle)
                                .bold()
                                .padding(.horizontal)
                            Spacer()
                        }
                        
                        HStack {
                            if let currentLocation = PositioningModel.shared.currentLatLon {
                                let distance = currentLocation.distance(from: destinationAnchorDetails.getLocationCoordinate())
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
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.top, 1)
                            .padding(.bottom, 0.5)
                            
                            HStack {
                                if let notes = destinationAnchorDetails.getNotes(), notes != "" {
                                    Text("\(notes)")
                                }
                                else {
                                    Text("No notes available for this location.")
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)

                    
                    Spacer()
                    NavigationLink (destination: NavigatingView(startAnchorDetails: startAnchorDetails, destinationAnchorDetails: destinationAnchorDetails), label: {
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

struct CloudAnchorsDetailView_Previews: PreviewProvider {
    @State static var anchorDetails = LocationDataModel(anchorType: .externalDoor, anchorCategory: "", coordinates: CLLocationCoordinate2D(latitude: 42, longitude: -71), associatedOutdoorFeature: nil, name: "Test Door")

    
    static var previews: some View {
        AnchorDetailView(anchorDetails: anchorDetails)
    }
}
