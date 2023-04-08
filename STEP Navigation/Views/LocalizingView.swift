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
    
    let locationManger = CLLocationManager()
    
    init() {
        // Request location permission
        locationManger.requestWhenInUseAuthorization()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
            if granted {
                print("Camera access granted")
            } else {
                print("Camera access denied")
            }
        }
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct LocalizingView_Previews: PreviewProvider {
    static var previews: some View {
        LocalizingView()
    }
}
