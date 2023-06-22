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
    @Published var isInstructionsSelected: Bool = false
    @Published var isObstacleSelected: Bool = false
    @Published var isLostSelected: Bool = false
    @Published var isLongerSelected: Bool = false
    @Published var isOtherSelected: Bool = false
    
    func reset() {
        self.feedbackStatus = ""
        self.response = ""
        self.isInstructionsSelected = false
        self.isObstacleSelected = false
        self.isLostSelected = false
        self.isLongerSelected = false
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
                            .foregroundColor(colorschemedefault ? Color.white : AppColor.background)
//                            .background(Color.green)
                            .background(colorschemedefault ? Color.green : AppColor.foreground)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: MultipleChoice().environmentObject(feedback).onAppear {
                                        feedback.feedbackStatus = "Bad"
                                    }) {
                                        if colorschemedefault {
                                            Image(systemName: "hand.thumbsdown")
                                                .font(.title)
                                                .padding(30)
                                                .foregroundColor(Color.white)
                                                .background(Color.red)
                                                .cornerRadius(10)
                                                
                                        } else {
                                            Image(systemName: "hand.thumbsdown")
                                                .font(.title)
                                                .padding(30)
                                                .foregroundColor(AppColor.foreground)
                                                .background(AppColor.background)
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(AppColor.foreground, lineWidth: 2))
                                        }
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
                Spacer().frame(height: 40)
                Button(action: {
                    print("Incorrect or unclear instructions")
                    feedback.isInstructionsSelected.toggle()
                }) {
                    HStack {
                        Text("Incorrect or unclear instructions").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if feedback.isInstructionsSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                Button(action: {
                    print("The route led me into a large obstacle")
                    feedback.isObstacleSelected.toggle()
                }) {
                    HStack {
                        Text("The route led me into a large obstacle").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if feedback.isObstacleSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                Button(action: {
                    print("I got lost along the route")
                    feedback.isLostSelected.toggle()
                }) {
                    HStack {
                        Text("I got lost along the route").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if feedback.isLostSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                Button(action: {
                    print("The navigation took longer than expected")
                    feedback.isLongerSelected.toggle()
                }) {
                    HStack {
                        Text("The navigation took longer than expected").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if feedback.isLongerSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                
                Button(action: {
                    print("Other")
                    feedback.isOtherSelected.toggle()
                }) {
                    HStack {
                        Text("Other").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if feedback.isOtherSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                TextField("Optional: Problem Description", text: $feedback.response)
                    .foregroundColor(AppColor.foreground)
                    .padding(30)
                    .border(AppColor.foreground, width: 1)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            Spacer().frame(height: 50)
            NavigationLink(destination: HomeView().onAppear {
                let feedbackModel = FeedbackModel()
                feedbackModel.saveFeedback(
                    feedbackStatus: feedback.feedbackStatus,
                    response: feedback.response,
                    isInstructionsSelected: feedback.isInstructionsSelected,
                    isObstacleSelected: feedback.isObstacleSelected,
                    isLostSelected: feedback.isLostSelected,
                    isLongerSelected: feedback.isLongerSelected,
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
