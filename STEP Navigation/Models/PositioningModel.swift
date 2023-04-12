//
//  PositioningModel.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import ARKit
import RealityKit

enum GeoLocationAccuracy {
    case none
    case low
    case medium
    case high
}

class PositioningModel: ObservableObject {
    // this would host and manage the ARSession
    let arView = ARView(frame: .zero)
    public static var shared = PositioningModel()
    @Published var geoLocalizationAccuracy: GeoLocationAccuracy = .none
    @Published var currentLatLon: CLLocationCoordinate2D?
    private init() {
        setDefaultsForTesting()
    }
    
    private func setDefaultsForTesting() {
        DispatchQueue.main.async {
            self.geoLocalizationAccuracy = .high
            self.currentLatLon = CLLocationCoordinate2D(latitude: 42.2, longitude: -71.0)
        }
    }
}
