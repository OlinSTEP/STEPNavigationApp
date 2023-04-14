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
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        return PositioningModel.shared.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}
