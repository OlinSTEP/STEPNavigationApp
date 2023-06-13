//
//  RecordAnchorView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/12/23.
//

import SwiftUI

struct RecordAnchorView: View {
    
    
    var body: some View {
        Text("Record Anchor View")
    }
}

//struct CreateAnchorView: View {
//    @State private var anchorName: String = ""
//    @State private var currentQuality: GARFeatureMapQuality?
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
//            TextField("Anchor Name", text: $anchorName)
//            Button("Save Anchor") {
//                PositioningModel.shared.createCloudAnchor(afterDelay: 30.0, withName: anchorName) { wasSuccessful in
//                    MainUIStateContainer.shared.currentScreen = .mainScreen
//                }
//            }
//        }
//        .onReceive(PositioningModel.shared.$currentQuality) { newValue in
//            currentQuality = newValue
//        }
//        .onAppear() {
//            PositioningModel.shared.startPositioning()
//        }
//    }
//}
