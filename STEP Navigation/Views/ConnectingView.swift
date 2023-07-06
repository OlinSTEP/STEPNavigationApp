//
//  ConnectingView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import ARCoreGeospatial
import ARCoreCloudAnchors

struct ConnectingInstructions: View {
    var body: some View {
        let instructionsListItems = [
            "Stand in the location of the first anchor and begin the connecting process by pressing 'Find First Anchor.' button at the bottom of this page.",
            "Move your phone around until you resolve the first anchor.",
            "Hold your phone steady at chest level with the camera pointed parallel to the ground and walk to the second anchor. You do not need to wave the phone around as you walk, just hold it steady facing out in front of you.",
            "The second anchor may resolve as you approach it. If it doesn't, stand in the location of the second anchor and move your phone around until it resolves.",
            "Your anchors are connected!"
        ]
        
        LeftLabel(text: "Connecting Two Anchors")
        OrderedList(listItems: instructionsListItems)
        Text("Note: After connecting two anchors, you may be prompted to improve the accuracy of the connection by walking back from the second anchor to the first. This is not a required step, but doing so will improve the quality of the navigation.")
        
    }
}

struct ConnectingView: View {
    @ObservedObject var positioningModel = PositioningModel.shared
    @State var anchorID1: String
    @State var anchorID2: String
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    @State var currentQuality: GARFeatureMapQuality?
    
    @State var showInstructions: Bool = true
    @State var forwardAndBackwardConnected: Bool = false
    
    @State var saved: Bool = false
    @AccessibilityFocusState var focusOnImprovePopup
    
    @State var startAnchor: String = ""
    @State var stopAnchor: String = ""
    
    var body: some View {
        Group {
            ZStack {
                if !showInstructions {
                    ARViewContainer()
                }
                VStack {
                    Spacer()
                    
                    if !positioningModel.resolvedCloudAnchors.contains(startAnchor) && !showInstructions {
                        let text = "Stand at \(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) and scan your phone around to resolve the anchor."
                        ARViewTextOverlay(text: text, announce: text)
                    }
                    
                    if positioningModel.resolvedCloudAnchors.contains(startAnchor) && !positioningModel.resolvedCloudAnchors.contains(stopAnchor) {
                        let text = "\(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!) anchor successfully resolved. You can now walk to \(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!)."
                        ARViewTextOverlay(text: text, announce: text)
                    }
                    
                    if positioningModel.resolvedCloudAnchors.contains(startAnchor) && positioningModel.resolvedCloudAnchors.contains(stopAnchor) && !saved {
                        let text = "\(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!) anchor successfully resolved. Connection created."
                        ARViewTextOverlay(text: text, announce: text, onAppear: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                saved = true
                            }
                        })
                    }
                    
                    if saved {
                        if FirebaseManager.shared.mapGraph.isDirectlyConnected(from: anchorID2, to: anchorID1) {
                            ARViewTextOverlay(text: "Anchors Fully Connected.", navLabel: "Home", navDestination: HomeView())
                        } else {
                            VStack {
                                ARViewTextOverlay(text: "The connection will automatically work in both directions, but you can improve the path by recording from \(FirebaseManager.shared.getCloudAnchorName(byID: stopAnchor)!) to \(FirebaseManager.shared.getCloudAnchorName(byID: startAnchor)!).", navLabel: "Home", navDestination: HomeView(), buttonLabel: "Improve Connection", buttonAction: {
                                    PositioningModel.shared.startPositioning()
                                    PositioningModel.shared.resolveCloudAnchor(byID: anchorID1)
                                    PositioningModel.shared.resolveCloudAnchor(byID: anchorID2)
                                    PathRecorder.shared.startAnchorID = anchorID2
                                    startAnchor = anchorID2
                                    PathRecorder.shared.stopAnchorID = anchorID1
                                    stopAnchor = anchorID1
                                    saved = false
                                }, onAppear: {
                                    PathRecorder.shared.stopRecordingPath()
                                    PathRecorder.shared.toFirebase()
                                    focusOnImprovePopup = true
                                })
                            }
                        }
                    }
                    Spacer()
                }
                
                if showInstructions {
                    VStack {
                        ConnectingInstructions()
                        .padding()
                        
                        Spacer()
                        
                        SmallButton(action: {
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
                        }, label: "Find First Anchor")
                        .padding(.bottom, 20)
                    }
                    .background(AppColor.background)
                }
                
                VStack {
                    ScreenHeader()
                    Spacer() 
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                HeaderNavigationLink(label: "Cancel", placement: .navigationBarLeading, destination: RecordingFeedbackView())
            }
            .onReceive(PositioningModel.shared.$currentQuality) { newQuality in
                currentQuality = newQuality
            }
            .onAppear() {
                PositioningModel.shared.startPositioning()
                PathLogger.shared.startLoggingData()
            }
            .onDisappear() {
                PositioningModel.shared.stopPositioning()
                //TODO: double check is correctly stopping the positioning, any announcements, etc
                PathLogger.shared.stopLoggingData()
                PathLogger.shared.uploadLog(logFilePath: "anchor_connection/\(anchorID1)_\(anchorID2)_\(UUID().uuidString)")
            }
        }
        .padding(.bottom, 48)
        .background(AppColor.foreground)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
