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
            VStack {
                ScreenHeader()
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                    AnchorDetailsText(anchorDetails: anchorDetails)
                        .padding(.vertical)
                }
                Spacer(minLength: 160)
                Text("How was your experience with this navigation session?")
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(AppColor.foreground)
                    .fixedSize(horizontal: false, vertical: true)
                
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
                Spacer(minLength: 120)
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
        ScrollView {
            VStack {
                ScreenHeader()
                VStack {
                    Text("What was the issue?")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(AppColor.foreground)
                        .padding(.vertical, 30)
                }
                
                ChecklistItem(toggle: $isInstructionsSelected, label: "Incorrect or unclear instructions")
                ChecklistItem(toggle: $isObstacleSelected, label: "Directed me into a wall")
                ChecklistItem(toggle: $isLostSelected, label: "Got lost along the route")
                ChecklistItem(toggle: $isLongerSelected, label: "Navigation took longer than expected")
                ChecklistItem(toggle: $isOtherSelected, label: "Other")
                
                VStack {
                    LeftLabel(text: "Optional: Problem Description", textSize: .title2)
                        .padding(.top, 20)
                    CustomTextField(entry: $response, textBoxSize: .large)
                }
                                    
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
                .padding(.bottom, 48)
                .padding(.top)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
    }
}


struct AnchorDetailView_ConnectingArrived: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    let anchorDetails: LocationDataModel
        
    var body: some View {
        ScreenBackground {
            ScreenHeader()
            VStack {
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                    AnchorDetailsText(anchorDetails: anchorDetails)
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
                    )}, thumbsDownDestination: ConnectingFeedbackView())
                Spacer()
                SmallNavigationLink(destination: HomeView(), label: "Home")
            }
        }
        .navigationBarBackButtonHidden()
    }
}


struct ConnectingFeedbackView: View {
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
        ScrollView {
            VStack {
                ScreenHeader()
                Text("What was the issue?")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(AppColor.foreground)
                    .padding(.vertical, 30)
                
                
                ChecklistItem(toggle: $isHoldAnchorSelected, label: "Phone could not host anchor")
                ChecklistItem(toggle: $isInstructionSelected, label: "Incorrect or unclear instructions")
                ChecklistItem(toggle: $isLongerSelected, label: "Recording took longer than expected")
                ChecklistItem(toggle: $isOtherSelected, label: "Other")
                
                
                VStack {
                    LeftLabel(text: "Optional: Problem Description", textSize: .title2)
                    CustomTextField(entry: $response, textBoxSize: .large)
                }
                .padding(.top, 20)
                
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
                .padding(.bottom, 48)
                .padding(.top)
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
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
                    .accessibilityLabel("Thumbs Up")
            }
            NavigationLink(destination: thumbsDownDestination) {
                Image(systemName: "hand.thumbsdown")
                    .font(.title)
                    .padding(30)
                    .foregroundColor(AppColor.foreground)
                    .background(AppColor.background)
                    .cornerRadius(10)
                    .accessibilityLabel("Thumbs Down")
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColor.foreground, lineWidth: 2))
            }
        }
    }
}
