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

class RecordFeedback: ObservableObject{
    @Published var recordFeedbackStatus: String = ""
    @Published var recordResponse: String = ""
    @Published var isHoldAnchorSelected: Bool = false
    @Published var isRecordingInstructionSelected: Bool = false
    @Published var isRecordLongerSelected: Bool = false
    @Published var isRecordOtherSelected: Bool = false
    
    func reset() {
        self.recordFeedbackStatus = ""
        self.recordResponse = ""
        self.isHoldAnchorSelected = false
        self.isRecordingInstructionSelected = false
        self.isRecordLongerSelected = false
        self.isRecordOtherSelected = false
    }
}

struct RecordThumbsView: View {
    @EnvironmentObject var recordfeedback: RecordFeedback
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
                            recordfeedback.recordFeedbackStatus = "Good"
                        }) {
                        Image(systemName: "hand.thumbsup")
                            .font(.title)
                            .padding(30)
                            .foregroundColor(colorschemedefault ? Color.white : AppColor.background)
//                            .background(Color.green)
                            .background(colorschemedefault ? Color.green : AppColor.foreground)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: RecordMultipleChoice().environmentObject(recordfeedback).onAppear {
                            recordfeedback.recordFeedbackStatus = "Bad"
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
//                if settingsManager.getColorSchemeLabel(forColorScheme: settingsManager.colorScheme) == "Default" {
//                    colorschemedefault = true
//                } else  {
//                    colorschemedefault = false
//                }
                colorschemedefault = false
            }
        }
    }
}


struct RecordMultipleChoice: View {
    @EnvironmentObject var recordfeedback: RecordFeedback

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
                    print("Phone could not host the anchor")
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
                    print("Unclear Instructions")
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
                    print("Took longer than expected")
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
                    print("Other")
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
//                    let RecordFeedbackModel = RecordFeedbackDataModel()
//                RecordFeedbackModel.saveRecordFeedback(
//                        recordFeedbackStatus: recordfeedback.recordFeedbackStatus,
//                        recordResponse: recordfeedback.recordResponse,
//                        isHoldAnchorSelected: recordfeedback.isHoldAnchorSelected,
//                        isRecordingInstructionSelected: recordfeedback.isRecordingInstructionSelected,
//                        isRecordLongerSelected: recordfeedback.isRecordLongerSelected,
//                        isRecordOtherSelected: recordfeedback.isRecordOtherSelected
//                    )
//                    recordfeedback.reset()
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
}

