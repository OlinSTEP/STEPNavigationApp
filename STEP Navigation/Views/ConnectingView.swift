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
    @StateObject var recordFeedback = RecordFeedback()

    @State var anchorID1: String
    @State var anchorID2: String
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    @State var currentQuality: GARFeatureMapQuality?
    
    @State var showInstructions: Bool = true
    @State var forwardAndBackwardConnected: Bool = false
    
    @State var savePressed: Bool = false
    @AccessibilityFocusState var focusOnImprovePopup
    
    @State var startAnchor: String = ""
    @State var stopAnchor: String = ""
    
    var body: some View {
        ZStack {
            ARViewContainer()
            VStack {
                Spacer()
                
                if !positioningModel.resolvedCloudAnchors.contains(startAnchor) && showInstructions == false {
                    HStack {
                        Text("Stand at \(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) and scan your phone around to resolve the anchor.")
                            .foregroundColor(AppColor.text_on_accent)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.accent)
                    .onAppear {
                        AnnouncementManager.shared.announce(announcement: "Stand at \(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) and scan your phone around to resolve the anchor.")
                    }
                }
                
                if positioningModel.resolvedCloudAnchors.contains(startAnchor) && !positioningModel.resolvedCloudAnchors.contains(stopAnchor) {
                    HStack {
                        Text("\(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) anchor successfully resolved. You can now walk to \(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!).")
                            .foregroundColor(AppColor.text_on_accent)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }.onAppear() {
                        PathRecorder.shared.startRecording()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.accent)
                    .onAppear {
                        AnnouncementManager.shared.announce(announcement: "\(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) anchor successfully resolved. You can now walk to \(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!).")
                    }
                }
                
                if positioningModel.resolvedCloudAnchors.contains(startAnchor) && positioningModel.resolvedCloudAnchors.contains(stopAnchor) && !savePressed {
                    VStack {
                        HStack {
                            Text("\(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!) anchor successfully resolved. Connection created.")
                                .foregroundColor(AppColor.text_on_accent)
                                .bold()
                                .font(.title2)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.accent)
                    .onAppear {
                        AnnouncementManager.shared.announce(announcement: "\(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!) anchor successfully resolved. Connection created.")
                }
                
                Spacer()
            }
            
            if showInstructions == true {
                VStack {
                    HStack {
                        //Insert instructions here Lisan
                        Text("Instructions here. Go to your first anchor. Etc etc.")
                            .foregroundColor(AppColor.foreground)
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
        }
        .background(AppColor.accent)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: RecordMultipleChoice(recordfeedback: self.recordFeedback), label: {
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
        .onDisappear() {
            PositioningModel.shared.stopPositioning()
        }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}
