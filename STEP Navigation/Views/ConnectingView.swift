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
    @State var anchorID1 = FirebaseManager.shared.firstCloudAnchor ?? ""
    @State var anchorID2 = FirebaseManager.shared.firstCloudAnchor ?? ""
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    @State var currentQuality: GARFeatureMapQuality?
    
    @State var showInstructions: Bool = true
    
    var body: some View {
        ZStack {
            ARViewContainer()
            
            if showInstructions == true {
                VStack {
                    HStack {
                        Text("Instructions here")
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
                    }
                }
                .background(AppColor.light)
            }
            
        
        
            
        }
        .onReceive(PositioningModel.shared.$currentQuality) { newQuality in
            currentQuality = newQuality
        }
        .onAppear() {
            PositioningModel.shared.startPositioning()
        }
    }
    
    enum connectingPopupText: String {
        case findFirstAnchor, walkToSecondAnchor, resolvedSecondAnchor
    }
}

//struct ConnectAnchorView: View {
//    @State var anchorID1 = FirebaseManager.shared.firstCloudAnchor ?? ""
//    @State var anchorID2 = FirebaseManager.shared.firstCloudAnchor ?? ""
//    @ObservedObject var firebaseManager = FirebaseManager.shared
//    @State var currentQuality: GARFeatureMapQuality?
//
//    var body: some View {
//        VStack {
//            if let currentQuality = currentQuality {
//                switch currentQuality {
//                case .insufficient:
//                    Text("Anchor quality insufficient")
//                case .sufficient:
//                    Text("Anchor quality sufficient")
//                case .good:
//                    Text("Anchor quality good")
//                @unknown default:
//                    Text("Anchor quality is unknown")
//                }
//            }
//            Picker("Anchor 1", selection: $anchorID1) {
//                ForEach(FirebaseManager.shared.mapAnchors.sorted(by: { $0.0 > $1.0 }), id: \.key) { cloudAnchorID, mapAnchorMetadata in
//                    Text(mapAnchorMetadata.name)
//                }
//            }
//            .pickerStyle(WheelPickerStyle())
//
//            Picker("Anchor 2", selection: $anchorID2) {
//                ForEach(FirebaseManager.shared.mapAnchors.sorted(by: { $0.0 > $1.0 }), id: \.key) { cloudAnchorID, mapAnchorMetadata in
//                    Text(mapAnchorMetadata.name)
//                }
//            }
//            .pickerStyle(WheelPickerStyle())
//
//            Button("Connect Cloud Anchors") {
//                guard anchorID1 != anchorID2 else {
//                    AnnouncementManager.shared.announce(announcement: "Navigating two and from the same point of interest is not currently supported")
//                    return
//                }
//                PositioningModel.shared.resolveCloudAnchor(byID: anchorID1)
//                PositioningModel.shared.resolveCloudAnchor(byID: anchorID2)
//                PathRecorder.shared.startAnchorID = anchorID1
//                PathRecorder.shared.stopAnchorID = anchorID2
//                MainUIStateContainer.shared.currentScreen = .findFirstAnchorToFormConnection(anchorID1: anchorID1, anchorID2: anchorID2)
//            }
//
//        }
//        .background(Color.orange)
//        .padding()
//        .onReceive(PositioningModel.shared.$currentQuality) { newQuality in
//            currentQuality = newQuality
//        }
//        .onAppear() {
//            PositioningModel.shared.startPositioning()
//        }
//    }
//}

//struct FindFirstAnchor: View {
//    @ObservedObject var positioningModel = PositioningModel.shared
//    let anchorID1: String
//    let anchorID2: String
//
//    var body: some View {
//        VStack {
//            if positioningModel.resolvedCloudAnchors.contains(anchorID1) {
//                Text("Resolved first anchor")
//                Button("Next Step") {
//                    MainUIStateContainer.shared.currentScreen = .walkToSecondAnchor(anchorID1: anchorID1, anchorID2: anchorID2)
//                }
//            } else {
//                Text("Find Anchor by scanning your phone around \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID1)!)")
//            }
//        }
//        .background(Color.orange)
//        .padding()
//    }
//}

//struct WalkToSecondAnchor: View {
//    let anchorID1: String
//    let anchorID2: String
//    @ObservedObject var positioningModel = PositioningModel.shared
//
//    var body: some View {
//        HStack{
//            VStack {
//                if let currentQuality = PositioningModel.shared.currentQuality {
//                    switch currentQuality {
//                    case .insufficient:
//                        Text("Anchor quality insufficient")
//                    case .sufficient:
//                        Text("Anchor quality sufficient")
//                    case .good:
//                        Text("Anchor quality good")
//                    @unknown default:
//                        Text("Anchor quality is unknown")
//                    }
//                }
//                Text("Walk to the second anchor")
//                Button("Next step") {
//                    PathRecorder.shared.stopRecordingPath()
//                    MainUIStateContainer.shared.currentScreen = .findSecondAnchorToFormConnection(anchorID1: anchorID1, anchorID2: anchorID2)
//                }
//            }
//        }.onAppear() {
//            PathRecorder.shared.startRecording()
//        }
//    }
//}
//

//struct FindSecondAnchor: View {
//    @ObservedObject var positioningModel = PositioningModel.shared
//    let anchorID1: String
//    let anchorID2: String
//    @State var showingPopover = false
//
//    var body: some View {
//        VStack {
//            Button("Show Recorded Path") {
//                showingPopover.toggle()
//            }
//            if positioningModel.resolvedCloudAnchors.contains(anchorID2) {
//                Text("Resolved second anchor")
//                Button("Done") {
//                    PathRecorder.shared.toFirebase()
//                    MainUIStateContainer.shared.currentScreen = .createAnchor
//                }
//            } else {
//                Text("Find Anchor by scanning your phone around \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID2)!)")
//            }
//        }
//        .popover(isPresented: $showingPopover) {
//            let keypoints = PathRecorder.shared.breadCrumbs.map({ KeypointInfo(id: UUID(), mode: .cloudAnchorBased, location: $0)})
//            let currentPose = PositioningModel.shared.cameraTransform
//            PathPlot(points: keypoints, currentTransform: currentPose)
//        }
//        .background(Color.orange)
//        .padding()
//    }
//}
