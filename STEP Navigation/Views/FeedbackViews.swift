//
//  AnchorDetailView_ArrivedView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//


import SwiftUI
import CoreLocation
import Foundation

enum FeedbackStatus: String {
    case good = "good"
    case bad = "bad"
    case notDefined = "notDefined"
}

struct AnchorDetailView_NavigationArrived: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    
    let anchorDetails: LocationDataModel
        
    var body: some View {
        ScreenBackground {
            ScreenHeader()
            VStack {
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                    AnchorDetailsText(title: anchorDetails.getName(), distanceAway: distance)
                        .padding(.vertical)
                }
                Text("How was your experience with this navigation session?")
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(AppColor.foreground)
                
                ThumbsUpDown(thumbsUpAction: {
                    FeedbackModel().saveFeedback(
                        feedbackStatus: "good",
                        response: "",
                        isInstructionsSelected: false,
                        isObstacleSelected: false,
                        isLostSelected: false,
                        isLongerSelected: false,
                        isOtherSelected: false
                    )}, thumbsDownDestination: NavigationFeedbackView())
                Spacer()
                SmallNavigationLink(destination: HomeView(), label: "Home")
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct NavigationFeedbackView: View {
    @State var feedbackStatus: FeedbackStatus = .bad
    @State var response: String = ""
    @State var isInstructionsSelected: Bool = false
    @State var isObstacleSelected: Bool = false
    @State var isLostSelected: Bool = false
    @State var isLongerSelected: Bool = false
    @State var isOtherSelected: Bool = false
    
    func reset() {
        self.feedbackStatus = .notDefined
        self.response = ""
        self.isInstructionsSelected = false
        self.isObstacleSelected = false
        self.isLostSelected = false
        self.isLongerSelected = false
        self.isOtherSelected = false
    }
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader()
                ScrollView {
                    VStack {Spacer().frame(height: 30)
                        LeftLabel(text: "What was the issue?")
                            .frame(maxWidth: .infinity, alignment: .center)
                        Spacer().frame(height: 30)
                    }
                    
                    ChecklistItem(toggle: $isInstructionsSelected, label: "Incorrect or unclear instructions")
                    ChecklistItem(toggle: $isObstacleSelected, label: "Directed me into a wall")
                    ChecklistItem(toggle: $isLostSelected, label: "Got lost along the route")
                    ChecklistItem(toggle: $isLongerSelected, label: "Navigation took longer than expected")
                    ChecklistItem(toggle: $isOtherSelected, label: "Other")
                    
                    VStack {
                        LeftLabel(text: "Optional: Problem Description", textSize: .title3)
                            .padding(.top, 20)
                        CustomTextField(entry: $response, textBoxSize: .large)
                    }
                }
                .padding(.horizontal)

                
                SmallNavigationLink(destination: HomeView(), label: "Done") {
                    FeedbackModel().saveFeedback(
                        feedbackStatus: feedbackStatus.rawValue,
                        response: response,
                        isInstructionsSelected: isInstructionsSelected,
                        isObstacleSelected: isObstacleSelected,
                        isLostSelected: isLostSelected,
                        isLongerSelected: isLongerSelected,
                        isOtherSelected: isOtherSelected
                    )
                    reset()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}


struct AnchorDetailView_RecordingArrived: View {
    @ObservedObject var settingsManager = SettingsManager.shared
        
    let anchorDetails: LocationDataModel
        
    var body: some View {
        ScreenBackground {
            ScreenHeader()
            VStack {
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                    AnchorDetailsText(title: anchorDetails.getName(), distanceAway: distance)
                        .padding(.vertical)
                }
                Text("How was your experience with this recording session?")
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(AppColor.foreground)

                ThumbsUpDown(thumbsUpAction: {
                    RecordFeedbackDataModel().saveRecordFeedback(
                        recordFeedbackStatus: "good",
                        recordResponse: "",
                        isHoldAnchorSelected: false,
                        isRecordingInstructionSelected: false,
                        isRecordLongerSelected: false,
                        isRecordOtherSelected: false
                    )}, thumbsDownDestination: RecordingFeedbackView())
                Spacer()
                SmallNavigationLink(destination: HomeView(), label: "Home")
            }
        }
        .navigationBarBackButtonHidden()
    }
}


struct RecordingFeedbackView: View {
    @State var feedbackStatus: FeedbackStatus = .bad
    @State var response: String = ""
    @State var isHoldAnchorSelected: Bool = false
    @State var isInstructionSelected: Bool = false
    @State var isLongerSelected: Bool = false
    @State var isOtherSelected: Bool = false
    
    func reset() {
        self.feedbackStatus = .notDefined
        self.response = ""
        self.isHoldAnchorSelected = false
        self.isInstructionSelected = false
        self.isLongerSelected = false
        self.isOtherSelected = false
    }
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader()
                ScrollView {
                    Text("What was the issue?")
                        .font(.title)
                        .bold()
                        .foregroundColor(AppColor.foreground)
                        .padding(.vertical, 30)
                    
                    
                    ChecklistItem(toggle: $isHoldAnchorSelected, label: "Phone could not host anchor")
                    ChecklistItem(toggle: $isInstructionSelected, label: "Incorrect or unclear instructions")
                    ChecklistItem(toggle: $isLongerSelected, label: "Recording took longer than expected")
                    ChecklistItem(toggle: $isOtherSelected, label: "Other")
                    
                    
                    VStack {
                        LeftLabel(text: "Optional: Problem Description", textSize: .title3)
                        CustomTextField(entry: $response, textBoxSize: .large)
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal)

                SmallNavigationLink(destination: HomeView(), label: "Done") {
                    RecordFeedbackDataModel().saveRecordFeedback(
                        recordFeedbackStatus: feedbackStatus.rawValue,
                        recordResponse: response,
                        isHoldAnchorSelected: isHoldAnchorSelected,
                        isRecordingInstructionSelected: isInstructionSelected,
                        isRecordLongerSelected: isLongerSelected,
                        isRecordOtherSelected: isOtherSelected
                    )
                    reset()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

struct ThumbsUpDown<Destination: View>: View {
    let thumbsUpAction: () -> Void
    let thumbsDownDestination: Destination
    
    var body: some View {
        HStack(spacing: 60) {
            NavigationLink(destination: HomeView()
                .onAppear {
                thumbsUpAction()
            }) {
                Image(systemName: "hand.thumbsup")
                    .font(.title)
                    .padding(30)
                    .foregroundColor(AppColor.background)
                    .background(AppColor.foreground)
                    .cornerRadius(10)
            }
            NavigationLink(destination: thumbsDownDestination) {
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
}
