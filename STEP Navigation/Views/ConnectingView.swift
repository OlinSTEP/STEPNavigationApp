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

    @State var anchorID1 = FirebaseManager.shared.firstCloudAnchor ?? ""
    @State var anchorID2 = FirebaseManager.shared.firstCloudAnchor ?? ""
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    @State var currentQuality: GARFeatureMapQuality?
    
    @State var showInstructions: Bool = true
    
    @State var savePressed: Bool = false

    
    var body: some View {
        ZStack {
            ARViewContainer()
                if positioningModel.resolvedCloudAnchors.contains(anchorID1) {
                    HStack {
                        Text("Anchor successfully resolved. You can now walk to \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID2)!).")
                        .foregroundColor(AppColor.light)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.dark)
                    
                    if positioningModel.resolvedCloudAnchors.contains(anchorID2) {
                        
                        VStack {
                            HStack {
                                Text("\(FirebaseManager.shared.getCloudAnchorName(byID: anchorID2)!) anchor successfully resolved. Connection created.")
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
                            

//                            Button("Save") {
//                                PathRecorder.shared.toFirebase()
//                            }
//                            .foregroundColor(AppColor.light)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.dark)
                    } else {
                        HStack {
                            Text("Walk to \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID2)!).")
                            .foregroundColor(AppColor.light)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.dark)
                    }
                    
                } else {
                    
                    HStack {
                        Text("Stand at \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID1)!) and scan your phone around to resolve the anchor.")
                        .foregroundColor(AppColor.light)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.center)
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
                        PathRecorder.shared.stopAnchorID = anchorID2
                        showInstructions = false
                    } label: {
                        Text("Find First Anchor")
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
