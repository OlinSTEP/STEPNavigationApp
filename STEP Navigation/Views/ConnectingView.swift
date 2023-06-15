//
//  ConnectingView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import ARCoreGeospatial
import ARCoreCloudAnchors

struct ConnectingView: View {
    @ObservedObject var positioningModel = PositioningModel.shared

    @State var anchorID1: String
    @State var anchorID2: String
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    @State var currentQuality: GARFeatureMapQuality?
    
    @State var showInstructions: Bool = true
    
    @State var savePressed: Bool = false
    
    @State var startAnchor: String = ""
    @State var stopAnchor: String = ""
    
    var body: some View {
        ZStack {
            ARViewContainer()
            
            VStack {
                if startAnchor != "" && stopAnchor != "" {
                    Text("START ANCHOR: \(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!)")
                    Text("STOP ANCHOR: \(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!)")
                }
                
                if !positioningModel.resolvedCloudAnchors.contains(startAnchor) && showInstructions == false {
                    HStack {
                        Text("Stand at \(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) and scan your phone around to resolve the anchor.")
                            .foregroundColor(AppColor.light)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.dark)
                }
                
                if positioningModel.resolvedCloudAnchors.contains(startAnchor) && !positioningModel.resolvedCloudAnchors.contains(stopAnchor) {
                    HStack {
                        Text("\(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) anchor successfully resolved. You can now walk to \(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!).")
                            .foregroundColor(AppColor.light)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.dark)
                    
                }
                
                if positioningModel.resolvedCloudAnchors.contains(startAnchor) && positioningModel.resolvedCloudAnchors.contains(stopAnchor) {
                    VStack {
                        HStack {
                            Text("\(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!) anchor successfully resolved. Connection created.")
                                .foregroundColor(AppColor.light)
                                .bold()
                                .font(.title2)
                                .multilineTextAlignment(.center)
                        }
                        NavigationLink(destination: HomeView(), isActive: $savePressed, label: {
                            Text("Save")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColor.dark)
                        })
                        .onChange(of: savePressed) {
                            newValue in
                            if newValue {
                                PathRecorder.shared.toFirebase()
                            }
                        }
                        .tint(AppColor.accent)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .padding(.horizontal)
                        
                        // add statement to check if the two aren't already backwards connected, and if so, display:
                        HStack {
                            Text("The conection will automatically work in both directions, but you can improve the path by walking from \(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!) to \(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!). Would you like to improve the connection now?")
                                .foregroundColor(AppColor.light)
                                .bold()
                                .font(.title2)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            PositioningModel.shared.startPositioning()
                            PositioningModel.shared.resolveCloudAnchor(byID: anchorID1)
                            PositioningModel.shared.resolveCloudAnchor(byID: anchorID2)
                            PathRecorder.shared.startAnchorID = anchorID2
                            startAnchor = anchorID2
                            PathRecorder.shared.stopAnchorID = anchorID1
                            stopAnchor = anchorID1
                        } label: {
                            Text("Improve connection")
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.dark)
                }
                
                if showInstructions == true {
                    VStack {
                        HStack {
                            Text("Instructions here. Go to your first anchor. Etc etc.")
                            Spacer()
                        }
                        Spacer()
                        Button {
                            guard anchorID1 != anchorID2 else {
                                AnnouncementManager.shared.announce(announcement: "Navigating too and from the same point of interest is not currently supported")
                                return
                            }
                            PositioningModel.shared.resolveCloudAnchor(byID: anchorID1)
                            PositioningModel.shared.resolveCloudAnchor(byID: anchorID2)
                            PathRecorder.shared.startAnchorID = anchorID1
                            startAnchor = anchorID1
                            PathRecorder.shared.stopAnchorID = anchorID2
                            stopAnchor = anchorID2
                            showInstructions = false
                        } label: {
                            Text("Find First anchor")
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
            }
        }
        .background(AppColor.accent)
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
        .onReceive(PositioningModel.shared.$currentQuality) { newQuality in
            currentQuality = newQuality
        }
        .onAppear() {
            PositioningModel.shared.startPositioning()
        }
    }
}
