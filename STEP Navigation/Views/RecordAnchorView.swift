//
//  RecordAnchorView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/12/23.
//

import SwiftUI
import ARCoreGeospatial
import ARCoreCloudAnchors

struct RecordAnchorView: View {
    @State private var currentQuality: GARFeatureMapQuality?
    @State var showNextButton: Bool = false
    @State var anchorID: String = ""
    @State var showInstructions = true
    
    @State private var timeRemaining = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    
    var body: some View {
        ZStack {
            ARViewContainer()
            
            if !showNextButton && !showInstructions {
                InformationPopupComponent(popupType: .countdown(countdown: timeRemaining))
                    .onReceive(timer) { time in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }
            }
            
            VStack {
                if showInstructions == true {
                    VStack {
                        RecordAnchorInstructionsView()
                        Spacer()
                        
                        Button {
                            PositioningModel.shared.createCloudAnchor(afterDelay: 30.0, withName: "New Anchor") { anchorID in
                                guard let anchorID = anchorID else {
                                    print("something went wrong with creating the cloud anchor")
                                    return
                                }
                                //delay is used to ensure that there is sufficient time to create the anchor in the firebase before presenting the next button. if there is not enough time there is a possibility of the user selecting next before the anchor has been properly stored, which will then prevent the anchor from creating properly
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showNextButton = true
                                    self.anchorID = anchorID
                                    print("anchor created successfully")
                                }
                            }
                            showInstructions = false
                            timeRemaining = 30
                        } label: {
                            Text("Start Recording")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColor.text_on_accent)
                        }
                        .tint(AppColor.accent)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .padding(.horizontal)
                    }
                    .background(AppColor.background)
                }
                
                if showNextButton == true {
                    VStack {
                        NavigationLink {
                            AnchorDetailEditView(anchorID: anchorID, buttonLabel: "Save Anchor") {
                                HomeView()
                            }
                        } label: {
                            Text("Next")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColor.accent)
                        }
                        .tint(AppColor.text_on_accent)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.accent)
                    .accessibilityAddTraits(.isModal)
                }
            }
            .onAppear() {
                PositioningModel.shared.startPositioning()
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
        }
        .background(AppColor.accent)
    }
}

