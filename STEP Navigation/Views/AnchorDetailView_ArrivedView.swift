//
//  AnchorDetailView_ArrivedView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//


import SwiftUI
import CoreLocation
import Foundation

// Feedback Model
class Feedback: ObservableObject {
    @Published var feedbackStatus: String = ""
    @Published var response: String = ""
    @Published var isNavigationSelected: Bool = false
    @Published var isRouteRecordingSelected: Bool = false
    @Published var isLocationAnchorSelected: Bool = false
    @Published var isOtherSelected: Bool = false
}

// AnchorDetailView_ArrivedView
struct AnchorDetailView_ArrivedView: View {
    @EnvironmentObject var feedback: Feedback
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
                    NavigationLink(destination: HomeView().onAppear {
                        feedback.feedbackStatus = "Good"
                    }) {
                        Image(systemName: "hand.thumbsup")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: MultipleChoice().environmentObject(feedback).onAppear {
                        feedback.feedbackStatus = "Bad"
                    }) {
                        Image(systemName: "hand.thumbsdown")
                            .font(.title)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
                Spacer()
                SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Home")
            }
            .onDisappear {
                MultipleChoiceModel.saveFeedback(feedbackStatus: feedback.feedbackStatus,
                                                 response: feedback.response,
                                                 isNavigationSelected: feedback.isNavigationSelected,
                                                 isRouteRecordingSelected: feedback.isRouteRecordingSelected,
                                                 isLocationAnchorSelected: feedback.isLocationAnchorSelected,
                                                 isOtherSelected: feedback.isOtherSelected)
            }
        }
    }
}

// MultipleChoice after thumbs down
struct MultipleChoice: View {
    @EnvironmentObject var feedback: Feedback

    var body: some View {
        VStack {
            Text("What was the problem?")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.top)

            Button(action: {
                print("Navigation Problem")
                feedback.isNavigationSelected.toggle()
            }) {
                Text("Navigation")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(feedback.isNavigationSelected ? Color.yellow : Color.red)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Route Recording")
                feedback.isRouteRecordingSelected.toggle()
            }) {
                Text("Route Recording")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(feedback.isRouteRecordingSelected ? Color.yellow : Color.red)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Location Anchor Problem")
                feedback.isLocationAnchorSelected.toggle()
            }) {
                Text("Inaccurate Location Anchor")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(feedback.isLocationAnchorSelected ? Color.yellow : Color.red)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Others")
                feedback.isOtherSelected.toggle()
            }) {
                VStack{
                    Text("Others")
                        .font(.body)
                        .padding(5)
                        .foregroundColor(.white)
                    .background(feedback.isOtherSelected ? Color.yellow : Color.red)
                    .cornerRadius(10)

                    TextField("Problem Description", text: $feedback.response)
                }
            }
        }
        ; SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Done")
    }
}
