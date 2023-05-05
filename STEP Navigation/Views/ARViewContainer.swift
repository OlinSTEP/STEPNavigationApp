//
//  ARViewContainer.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/13/23.
//
//  Wrap a ARView (UIKit) with a SwiftUI View struct
//

import Foundation
import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARSCNView {
        return PositioningModel.shared.arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
}
