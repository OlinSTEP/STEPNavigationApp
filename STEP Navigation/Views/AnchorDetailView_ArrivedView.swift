//
//  AnchorDetailView_ArrivedView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import CoreLocation


struct AnchorDetailView_ArrivedView: View {
    let anchorDetails: LocationDataModel
   
    
    var body: some View {
        NavigationView {
            VStack {
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                    let formattedDistance = String(format: "%.0f", distance)
                    AnchorDetailsComponent(title: anchorDetails.getName(), distanceAway: formattedDistance)
                        .padding(.top)
                }
                Text("How was your experience with this navigation session?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                HStack {
                    NavigationLink(destination: HomeView()) {
                        Button(action: {
                            print("Thumbs Up tapped")
                        }) {
                            Image(systemName: "hand.thumbsup")
                                .font(.title)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    NavigationLink(destination: MultipleChoice()) {
                        Button(action: {
                            print("Thumbs down tapped")
                        }) {
                            Image(systemName: "hand.thumbsdown")
                                .font(.title)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                Spacer()
                SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Home")
            }
        }
    }
}



