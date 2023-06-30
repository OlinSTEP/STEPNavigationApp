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
                    ARViewTextOverlay(text: "Cloud Anchor Created ", navLabel: "Next", navDestination: AnchorDetailEditView(anchorID: anchorID, buttonLabel: "Save Anchor") {HomeView()})
                }
            }
            
            VStack {
                ScreenHeader()
                Spacer()
            }
        }
        .onAppear() {
            PositioningModel.shared.startPositioning()
        }
        .onDisappear() {
            PositioningModel.shared.stopPositioning()
            timerManager.stopTimer()
        }
        .onReceive(PositioningModel.shared.$currentQuality) { newValue in
            currentQuality = newValue
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: HomeView(), label: {
                    Text("Cancel")
                        .bold()
                        .font(.title2)
                })
            }
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
