//
//  ArrivedView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/24/23.
//
//
//import SwiftUI
//
//struct ArrivedView: View {
//    let destinationAnchorDetails: LocationDataModel //need to pass in destination details so we can display them
//    
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                VStack {
//                    HStack {
//                        Text(destinationAnchorDetails.getName())
//                            .font(.largeTitle)
//                            .bold()
//                            .padding(.horizontal)
//                        Spacer()
//                    }
//                    
//                    HStack {
//                        if let currentLocation = PositioningModel.shared.currentLatLon {
//                            let distance = currentLocation.distance(from: destinationAnchorDetails.getLocationCoordinate())
//                            let formattedDistance = String(format: "%.0f", distance)
//                            Text("\(formattedDistance) meters away")
//                                .font(.title)
//                                .padding(.horizontal)
//                        }
//                        Spacer()
//                    }
//                    VStack {
//                        HStack {
//                            Text("Location Notes")
//                                .font(.title2)
//                                .bold()
//                                .multilineTextAlignment(.leading)
//                            Spacer()
//                        }
//                        .padding(.top, 1)
//                        .padding(.bottom, 0.5)
//                        
//                        HStack {
//                            if let notes = destinationAnchorDetails.getNotes(), notes != "" {
//                                Text("\(notes)")
//                            }
//                            else {
//                                Text("No notes available for this location.")
//                            }
//                            Spacer()
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                                
//                Spacer()
//                
//                NavigationLink (destination: GPSLocalizationView(), label: {
//                    Text("Home")
//                        .font(.title)
//                        .bold()
//                        .frame(maxWidth: 300)
//                        .foregroundColor(AppColor.dark)
//                })
//                .padding(.bottom, 20)
//                .tint(AppColor.accent)
//                .buttonStyle(.borderedProminent)
//                .buttonBorderShape(.capsule)
//                .controlSize(.large)
//            }
//            .navigationTitle("Arrived")
//        }
//    }
//}
