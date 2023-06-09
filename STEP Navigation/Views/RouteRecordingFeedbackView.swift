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
// recording feedback Model

import SwiftUI
import CoreLocation
import Foundation

enum RecordFeedbackStatus: String {
    case good
    case bad
    case notDefined
}

class RecordingFeedback: ObservableObject{
    var recordFeedbackStatus: RecordFeedbackStatus = .notDefined
    var recordResponse: String = ""
    var isHoldAnchorSelected: Bool = false
    var isRecordingInstructionSelected: Bool = false
    var isRecordLongerSelected: Bool = false
    var isRecordOtherSelected: Bool = false
    
    func reset() {
        self.recordFeedbackStatus = .notDefined
        self.recordResponse = ""
        self.isHoldAnchorSelected = false
        self.isRecordingInstructionSelected = false
        self.isRecordLongerSelected = false
        self.isRecordOtherSelected = false
    }
}

struct RecordingFeedback: View {
    @StateObject var recordfeedback: RecordingFeedback
    @ObservedObject var settingsManager = SettingsManager.shared
    
    @State var colorschemedefault: Bool = false
    
    let anchorDetails: LocationDataModel
        
    var body: some View {
        NavigationView {
            VStack {
                Text("How was your experience with this recording session?")
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .foregroundColor(AppColor.foreground)
                Spacer()
                    .frame(height: 30)
                HStack {
                    NavigationLink(destination: HomeView().onAppear {
                        recordfeedback.recordFeedbackStatus = .good
                        }) {
                        Image(systemName: "hand.thumbsup")
                            .font(.title)
                            .padding(30)
                            .foregroundColor(colorschemedefault ? Color.white : AppColor.background)
                            .background(colorschemedefault ? Color.green : AppColor.foreground)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: RecordMultipleChoice(recordfeedback: recordfeedback).onAppear {
                        recordfeedback.recordFeedbackStatus = .bad
                    })
 {
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
                SmallNavigationLink(destination: HomeView(), label: "Home")
            }
            .background(AppColor.background)
            .edgesIgnoringSafeArea([.bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear() {
                colorschemedefault = false
            }
        }
    }
}


struct RecordingFeedback: View {
    @StateObject var recordfeedback: RecordingFeedback

    var body: some View { ScrollView{
        VStack {
            VStack {
                Text("What was the issue?").bold()
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .foregroundColor(AppColor.foreground)
                Spacer().frame(height: 40)
                Button(action: {
                    recordfeedback.isHoldAnchorSelected.toggle()
                }) {
                    HStack {
                        Text("Phone could not host the anchor").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if recordfeedback.isHoldAnchorSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                Button(action: {
                    recordfeedback.isRecordingInstructionSelected.toggle()
                }) {
                    HStack {
                        Text("Unclear Instructions").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if recordfeedback.isRecordingInstructionSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                Button(action: {
                    recordfeedback.isRecordLongerSelected.toggle()
                }) {
                    HStack {
                        Text("Took longer than expected").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if recordfeedback.isRecordLongerSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                Button(action: {
                    recordfeedback.isRecordOtherSelected.toggle()
                }) {
                    HStack {
                        Text("Other").bold()
                            .font(.title)
                            .padding(10)
                            .foregroundColor(AppColor.foreground)
                        if recordfeedback.isRecordOtherSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30))
                                .fontWeight(.heavy)
                                .foregroundColor(AppColor.foreground)
                        }
                    }
                }
                
                TextField("Optional: Problem Description", text: $recordfeedback.recordResponse)
                    .foregroundColor(AppColor.foreground)
                    .padding(30)
                    .border(AppColor.foreground, width: 1)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            Spacer().frame(height: 50)
            NavigationLink(destination: HomeView().onAppear {
                let RecordFeedbackModel = RecordFeedbackDataModel()
                RecordFeedbackModel.saveRecordFeedback(
                    recordFeedbackStatus: recordfeedback.recordFeedbackStatus.rawValue,
                    recordResponse: recordfeedback.recordResponse,
                    isHoldAnchorSelected: recordfeedback.isHoldAnchorSelected,
                    isRecordingInstructionSelected: recordfeedback.isRecordingInstructionSelected,
                    isRecordLongerSelected: recordfeedback.isRecordLongerSelected,
                    isRecordOtherSelected: recordfeedback.isRecordOtherSelected
                )
                recordfeedback.reset()
            }) {
                Text("Done").bold()
                    .font(.title)
                    .padding(.horizontal, 80)
                    .padding(15)
                    .foregroundColor(AppColor.background)
                    .background(AppColor.foreground)
                    .cornerRadius(15)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
    }
    .background(AppColor.background)
    }
}



