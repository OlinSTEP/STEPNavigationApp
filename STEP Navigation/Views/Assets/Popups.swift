//
//  Popups.swift
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

///This struct displays a confirmation  popup when a user attempts to exit the navigation session.
struct ExitPopup: View {
    /// Binding to a boolean value that indicates whether the confirmation popup is showing.
    @Binding var showingConfirmation: Bool
    
    var body: some View {
        VStack {
            VStack {
                Text("Are you sure you want to exit?")
                    .bold()
                    .font(.title2)
                Text("This will end the navigation session.")
                    .font(.title3)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            
            VStack {
                SmallButtonComponent_NavigationLink(destination: {
                                    HomeView()
                                }, label: "Exit")
                .padding(.bottom, 2)
                SmallButtonComponent_Button(label: "Cancel", labelColor: AppColor.dark, backgroundColor: AppColor.grey, popupTrigger: $showingConfirmation, role: .cancel)
            }
            .padding()
        }
        .frame(width: 360, height: 250)
        .background(AppColor.light)
        .cornerRadius(20)
    }
}

struct GPSLocalizationPopup: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Finding Destinations Near You")
                    .foregroundColor(AppColor.dark)
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(.horizontal)
            
            ZStack {
                Circle()
                    .stroke(AppColor.dark, lineWidth: 5)
                    .frame(width: 100, height: 100)
                    .opacity(0.25)
                Circle()
                    .trim(from: 0.25, to: 1)
                    .stroke(AppColor.dark, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .onAppear {
                        withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                            self.isAnimating = true
                        }
                    }
                }
                .frame(height: 100)
                .padding()
                .drawingGroup()
            }
            .padding(.top, 20)
        }
    }
