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
    
    func reset() {
        self.feedbackStatus = ""
        self.response = ""
        self.isNavigationSelected = false
        self.isRouteRecordingSelected = false
        self.isLocationAnchorSelected = false
        self.isOtherSelected = false
    }
}


// AnchorDetailView_ArrivedView
struct AnchorDetailView_ArrivedView: View {
    @EnvironmentObject var feedback: Feedback
    @ObservedObject var settingsManager = SettingsManager.shared
    
    @State var colorschemedefault: Bool = false
    
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
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .foregroundColor(AppColor.foreground)
                Spacer()
                    .frame(height: 30)
                HStack {
                    NavigationLink(destination: HomeView().onAppear {
                        feedback.feedbackStatus = "Good"
                    }) {
                        Image(systemName: "hand.thumbsup")
                            .font(.title)
                            .padding(30)
                            .foregroundColor(.white)
//                            .background(Color.green)
                            .background(colorschemedefault ? Color.green : AppColor.foreground)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: MultipleChoice().environmentObject(feedback).onAppear {
                        feedback.feedbackStatus = "Bad"
                    }) {
                        Image(systemName: "hand.thumbsdown")
                            .font(.title)
                            .padding(30)
                            .foregroundColor(AppColor.foreground)
                            .background(AppColor.background)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColor.foreground, lineWidth: 2)
                            )
                    }
                }
                .padding()
                Spacer()
                    .frame(height: 200)
                SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Home")
                    .padding(.bottom, 40)
            }
            .background(AppColor.background)
            .edgesIgnoringSafeArea([.bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear() {
                if settingsManager.getColorSchemeLabel(forColorScheme: settingsManager.colorScheme) == "Default" {
                    colorschemedefault = true
                } else  {
                    colorschemedefault = false
                }
            }
        }
    }
}

// MultipleChoice after thumbs down
struct MultipleChoice: View {
    @EnvironmentObject var feedback: Feedback

    var body: some View {
        VStack {
            VStack {
                Text("What was the issue?").bold()
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .foregroundColor(AppColor.foreground)
                Spacer().frame(height: 50)
                Button(action: {
                    print("Navigation Problem")
                    feedback.isNavigationSelected.toggle()
                }) {
                    Text("Navigation").bold()
                        .font(.title)
                        .padding(10)
                    //            labelColor: AppColor.dark, backgroundColor: AppColor.lightred
                        .foregroundColor(StaticAppColor.black)
                        .background(feedback.isNavigationSelected ? StaticAppColor.lightgreen: StaticAppColor.lightyellow)
                        .cornerRadius(15)
                }
                if feedback.isNavigationSelected {
                    TextField("Problem Description", text: $feedback.response)
                        .foregroundColor(Color.black)
                        .padding(10)
                        .border(Color.black, width: 0.5)
                }
                Button(action: {
                    print("Route Recording")
                    feedback.isRouteRecordingSelected.toggle()
                }) {
                    Text("Route Recording").bold()
                        .font(.title)
                        .padding(10)
                        .foregroundColor(StaticAppColor.black)
                        .background(feedback.isRouteRecordingSelected ? StaticAppColor.lightgreen: StaticAppColor.lightyellow)
                        .cornerRadius(15)
                }
                if feedback.isRouteRecordingSelected {
                    TextField("Problem Description", text: $feedback.response)
                        .foregroundColor(Color.black)
                        .padding(10)
                        .border(Color.black, width: 0.5)
                }
                
                Button(action: {
                    print("Location Anchor Problem")
                    feedback.isLocationAnchorSelected.toggle()
                }) {
                    Text("Inaccurate Location Anchor").bold()
                        .font(.title)
                        .padding(10)
                        .foregroundColor(StaticAppColor.black)
                        .background(feedback.isLocationAnchorSelected ? StaticAppColor.lightgreen: StaticAppColor.lightyellow)
                        .cornerRadius(15)
                }
                if feedback.isLocationAnchorSelected {
                    TextField("Problem Description", text: $feedback.response)
                        .foregroundColor(Color.black)
                        .padding(10)
                        .border(Color.black, width: 0.5)
                }
                
                Button(action: {
                    print("Others")
                    feedback.isOtherSelected.toggle()
                }) {
                    Text("Others").bold()
                        .font(.title)
                        .padding(10)
                        .foregroundColor(StaticAppColor.black)
                        .background(feedback.isOtherSelected ? StaticAppColor.lightgreen: StaticAppColor.lightyellow)
                        .cornerRadius(15)
                }
                if feedback.isOtherSelected {
                    TextField("Problem Description", text: $feedback.response)
                        .foregroundColor(Color.black)
                        .padding(10)
                        .border(Color.black, width: 0.5)
                }
                
            }
            NavigationLink(destination: HomeView().onAppear {
                let feedbackModel = FeedbackModel()
                feedbackModel.saveFeedback(
                    feedbackStatus: feedback.feedbackStatus,
                    response: feedback.response,
                    isNavigationSelected: feedback.isNavigationSelected,
                    isRouteRecordingSelected: feedback.isRouteRecordingSelected,
                    isLocationAnchorSelected: feedback.isLocationAnchorSelected,
                    isOtherSelected: feedback.isOtherSelected
                )
                feedback.reset()
            }) {
                Text("Done").bold()
                    .font(.title)
                    .padding(.horizontal, 80)
                    .padding(15)
                    .foregroundColor(StaticAppColor.black)
                    .background(AppColor.accent)
                    .cornerRadius(15)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
}
}

