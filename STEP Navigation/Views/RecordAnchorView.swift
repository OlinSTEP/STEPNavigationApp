//
//  RecordAnchorView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/12/23.
//

import SwiftUI
import Combine
import ARCoreGeospatial
import ARCoreCloudAnchors

struct RecordAnchorView: View {
    @State private var currentQuality: GARFeatureMapQuality?
    @State var showNextButton: Bool = false
    @State var anchorID: String = ""
    @State var showInstructions = true
    @StateObject private var timerManager = TimerManager()
    
    var body: some View {
        ZStack {
            ARViewContainer()
            if !showNextButton && !showInstructions {
                VStack {
                    if timerManager.timeRemaining > 0 {
                        Text(String(timerManager.timeRemaining))
                            .foregroundColor(AppColor.background)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .bold()
                    } else {
                        Text("Trying to Host Anchor")
                            .foregroundColor(AppColor.background)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColor.foreground)
            }
            
            VStack {
                if showInstructions == true {
                    VStack {
                        RecordAnchorInstructionsView()
                        Spacer()
                        
                        SmallButton(action: {
                            PositioningModel.shared.createCloudAnchor(afterDelay: 30.0, withName: "New Anchor") { anchorID in
                                guard let anchorID = anchorID else {
                                    print("something went wrong with creating the cloud anchor")
                                    return
                                }
                                //delay is used to ensure that there is sufficient time to create the anchor in the firebase before presenting the next button. if there is not enough time there is a possibility of the user selecting next before the anchor has been properly stored, which will then prevent the anchor from creating properly
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showNextButton = true
                                    self.anchorID = anchorID
                                }
                            }
                            showInstructions = false
                            timerManager.startTimer(duration: 30)
                        }, label: "Start Recording")
                    }
                    .background(AppColor.background)
                }
                
                if showNextButton == true {
                    let anchorDetails = DataModelManager.shared.getLocationDataModel(byID: anchorID)
                    ARViewTextOverlay(text: "Cloud Anchor Created ", navLabel: "Next", navDestination: AnchorDetailEditView(anchorDetails: anchorDetails!, buttonLabel: "Save Anchor", hideBackButton: true) {HomeView()}) //TODO: remove force unwrap here
                }
            }
            
            VStack {
                ScreenHeader()
                Spacer()
            }
        }
        .onAppear() {
            PositioningModel.shared.startPositioning()
            PathLogger.shared.startLoggingData()
        }
        .onDisappear() {
            PositioningModel.shared.stopPositioning() //TODO: this doesn't seem to be properly stopping the anchor creation
            PathLogger.shared.stopLoggingData()
            PathLogger.shared.uploadLog(logFilePath: "anchor_creation/\(anchorID)")
            timerManager.stopTimer()
        }
        .onReceive(PositioningModel.shared.$currentQuality) { newValue in
            currentQuality = newValue
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            HeaderNavigationLink(label: "Cancel", placement: .navigationBarLeading, destination: HomeView())
        }
        .background(AppColor.foreground)
    }
}

class TimerManager: ObservableObject {
    @Published var timeRemaining = 0
    private var timer: Timer?
    
    init() {}
    
    func startTimer(duration: Int) {
        guard timer == nil else { return }
        
        timeRemaining = duration
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


struct RecordAnchorInstructionsView: View {
    var body: some View {
        let instructionListItems = [
            "Hold your phone vertically at chest height, such that the camera is facing straight out in front of you.",
            "Move your phone left to right in a wide arc.",
            "Turn around 180 degrees and move your phone left to right in a wide arc.",
            "Tilt your phone very slightly upwards.",
            "Repeat steps 2 and 3.",
            "Tilt your phone very slightly downwards.",
            "Repeat steps 2 and 3.",
            "Take a few steps back and repeat steps 1 through 7.",
            "If there is still time remaining, continue to move your phone around to capture the anchor from as many angles as possible."
        ]
        
        let tipListItems = [
            "Anchors take 30 seconds to record.",
            "A countdown timer is present on the recording screen and a chime will sound when the anchor has been successfully created.",
            "Try to stand facing a fixed landmark, such as a particular door, sign, table, etc."
        ]
        
        VStack {
            ScrollView {
                VStack {
                    LeftLabel(text: "Quick Reminders", textSize: .title2)
                    OrderedList(listItems: tipListItems)
                    
                    LeftLabel(text: "Instructions", textSize: .title2)
                    Text("Stand in the anchor destination with the rear camera pointing away from you. Move your phone slowly and steadily as you complete the following motions.")
                    OrderedList(listItems: instructionListItems)
                }
                .foregroundColor(AppColor.foreground)
                .padding()
            }
            Spacer()
        }
        .frame(width: .infinity, height: .infinity)
        .background(AppColor.background)
    }
}
