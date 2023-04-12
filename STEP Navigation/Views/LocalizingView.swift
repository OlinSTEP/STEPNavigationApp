//
//  LocalizingView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import AVFoundation
import CoreLocation

struct LocalizingView: View {
    @ObservedObject var positionModel = PositioningModel.shared
    let locationManager = CLLocationManager()
    let anchorType: AnchorType
    
    init(anchorType: AnchorType) {
        // Request location permission
        self.anchorType = anchorType
        locationManager.requestWhenInUseAuthorization()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if granted {
                print("Camera access granted")
            } else {
                print("Camera access denied")
            }
        }
    }
    
    var body: some View {
        switch positionModel.geoLocalizationAccuracy {
        case .none:
            Text("No Location")
        case .low:
            Text("low accuracy")
        case .medium:
            Text("medium accuracy")
        case .high:
            Text("localized")
//            Button("Start Navigation") {
//                NavigationView()
//            }
            if let currentLatLon = positionModel.currentLatLon {
                NavigationLink(destination: LocalAnchorListView(anchorType: anchorType, location: currentLatLon), label: {
                    Text("My nearby locations")
                })
            } else {
                Text("Inconsistent State.  Contact your developer")
            }
        }
        
    }
}

struct LocalizingView_Previews: PreviewProvider {
    static var previews: some View {
        LocalizingView(anchorType: .externalDoor)
    }
}
