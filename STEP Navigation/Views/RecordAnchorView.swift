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
    
    
    var body: some View {
        ZStack {
            ARViewContainer()
            
            if showNextButton == false && showInstructions == false {
                InformationPopupComponent(popupType: .countdown(countdown: 4))
            }
            
            VStack {
                if showInstructions == true {
                    VStack {
                        RecordAnchorInstructionsView()
                        Spacer()
                        
                        Button {
                            PositioningModel.shared.createCloudAnchor(afterDelay: 5.0, withName: "New Anchor") { anchorID in
                                guard let anchorID = anchorID else {
                                    print("something went wrong with creating the cloud anchor")
                                    return
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showNextButton = true
                                    self.anchorID = anchorID
                                    print("anchor created successfully")
                                }
                            }
//                            showInstructions = false
                        } label: {
                            Text("Start Recording")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColor.dark)
                        }
                        .tint(AppColor.accent)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .padding(.horizontal)
                    }
                    .background(AppColor.light)
                }
                
                if showNextButton == true {
                    NavigationLink {
                        AnchorDetailEditView(anchorID: anchorID, buttonLabel: "Save Anchor") {
                            HomeView()
                        }
                    } label: {
                        Text("Next")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(AppColor.dark)
                    }
                    .tint(AppColor.accent)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .padding(.horizontal)
                }
            }
            .onAppear() {
                PositioningModel.shared.startPositioning()
            }
            .onReceive(PositioningModel.shared.$currentQuality) { newValue in
                currentQuality = newValue
            }
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
}

