//
//  ThumbsDownMultiplechoice.swift
//  STEP Navigation
//
//  Created by Muya Guoji on 6/12/23.
//

//import SwiftUI
//import CoreLocation
//import Foundation
//
//// Feedback Model
//class RecordFeedback: ObservableObject {
//    @Published var feedbackStatus: String = ""
//    @Published var response: String = ""
//    @Published var isNavigationSelected: Bool = false
//    @Published var isRouteRecordingSelected: Bool = false
//    @Published var isLocationAnchorSelected: Bool = false
//    @Published var isOtherSelected: Bool = false
//
//    func reset() {
//        self.feedbackStatus = ""
//        self.response = ""
//        self.isNavigationSelected = false
//        self.isRouteRecordingSelected = false
//        self.isLocationAnchorSelected = false
//        self.isOtherSelected = false
//    }
//}
//
//struct RecordMultipleChoice: View {
//    @EnvironmentObject var feedback: Feedback
//
//    var body: some View {
//        VStack {
//            VStack {
//                Text("What was the issue?").bold()
//                    .font(.largeTitle)
//                    .multilineTextAlignment(.center)
//                    .padding(.top)
//                    .foregroundColor(AppColor.foreground)
//                Spacer().frame(height: 40)
//                Button(action: {
//                    print("Phone could not host the anchor")
//                    feedback.isNavigationSelected.toggle()
//                }) {
//                    HStack {
//                        Text("Phone could not host the anchor").bold()
//                            .font(.title)
//                            .padding(10)
//                            .foregroundColor(AppColor.foreground)
//                        if feedback.isNavigationSelected {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 30))
//                                .fontWeight(.heavy)
//                                .foregroundColor(AppColor.foreground)
//                        }
//                    }
//                }
//
//                Button(action: {
//                    print("Unclear Instructions")
//                    feedback.isRouteRecordingSelected.toggle()
//                }) {
//                    HStack {
//                        Text("Unclear Instructions").bold()
//                            .font(.title)
//                            .padding(10)
//                            .foregroundColor(AppColor.foreground)
//                        if feedback.isRouteRecordingSelected {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 30))
//                                .fontWeight(.heavy)
//                                .foregroundColor(AppColor.foreground)
//                        }
//                    }
//                }
//
//                Button(action: {
//                    print("Took longer than expected")
//                    feedback.isLocationAnchorSelected.toggle()
//                }) {
//                    HStack {
//                        Text("Took longer than expected").bold()
//                            .font(.title)
//                            .padding(10)
//                            .foregroundColor(AppColor.foreground)
//                        if feedback.isLocationAnchorSelected {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 30))
//                                .fontWeight(.heavy)
//                                .foregroundColor(AppColor.foreground)
//                        }
//                    }
//                }
//
//                Button(action: {
//                    print("Other")
//                    feedback.isOtherSelected.toggle()
//                }) {
//                    HStack {
//                        Text("Other").bold()
//                            .font(.title)
//                            .padding(10)
//                            .foregroundColor(AppColor.foreground)
//                        if feedback.isOtherSelected {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 30))
//                                .fontWeight(.heavy)
//                                .foregroundColor(AppColor.foreground)
//                        }
//                    }
//                }
//
//                TextField("Optional: Problem Description", text: $feedback.response)
//                    .foregroundColor(AppColor.foreground)
//                    .padding(30)
//                    .border(AppColor.foreground, width: 1)
//                    .textFieldStyle(PlainTextFieldStyle())
//            }
//            Spacer().frame(height: 50)
//            NavigationLink(destination: HomeView().onAppear {
//                let feedbackModel = FeedbackModel()
//                feedbackModel.saveFeedback(
//                    feedbackStatus: feedback.feedbackStatus,
//                    response: feedback.response,
//                    isNavigationSelected: feedback.isNavigationSelected,
//                    isRouteRecordingSelected: feedback.isRouteRecordingSelected,
//                    isLocationAnchorSelected: feedback.isLocationAnchorSelected,
//                    isOtherSelected: feedback.isOtherSelected
//                )
//                feedback.reset()
//            }) {
//                Text("Done").bold()
//                    .font(.title)
//                    .padding(.horizontal, 80)
//                    .padding(15)
//                    .foregroundColor(StaticAppColor.black)
//                    .background(AppColor.accent)
//                    .cornerRadius(15)
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(AppColor.background)
//        .edgesIgnoringSafeArea([.bottom])
//
//    }
//}
//
