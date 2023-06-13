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
    @State var showPopup: Bool = false
    @State var anchorID: String = ""
    
    
    var body: some View {
        ZStack {
            ARViewContainer()
            VStack {
//                if let currentQuality = currentQuality {
//                    if currentQuality == .insufficient {
//                        Text("Quality is low. Make sure to move your phone around and capture the anchor location from multiple angles.")
//                    }
//                }
                Button("Start Recording Anchor") {
                    PositioningModel.shared.createCloudAnchor(afterDelay: 30.0, withName: "New Anchor") { anchorID in
                        guard let anchorID = anchorID else {
                            print("somethign went wrong")
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showPopup = true
                            self.anchorID = anchorID
                            print("anchor created successfully")
                        }
                    }
                }
                if showPopup == true {
                    NavigationLink {
                        AnchorDetailEditView(anchorID: anchorID, buttonLabel: "Save Anchor") {
                            HomeView()
                        }
                    } label: {
                        Text("Next")
                    }
                }
            }
            .onAppear() {
                PositioningModel.shared.startPositioning()
            }
            .onReceive(PositioningModel.shared.$currentQuality) { newValue in
                currentQuality = newValue
            }
        }
    }
}

