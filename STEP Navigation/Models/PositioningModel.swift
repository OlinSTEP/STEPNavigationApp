//
//  PositioningModel.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import ARKit
import RealityKit
import ARCoreGeospatial
import ARCoreCloudAnchors

enum GeoLocationAccuracy {
    case none
    case low
    case medium
    case high
}

class PositioningModel: NSObject, ObservableObject {
    // this would host and manage the ARSession
    let arView = ARView(frame: .zero)
    private let locationManager = CLLocationManager()
    private var garSession: GARSession?
    public static var shared = PositioningModel()
    @Published var geoLocalizationAccuracy: GeoLocationAccuracy = .none
    @Published var currentLatLon: CLLocationCoordinate2D?
    private override init() {
        super.init()
        locationManager.requestWhenInUseAuthorization()
        arView.session.delegate = self
        startGARSession()
        // setDefaultsForTesting()
    }
    
    private func setDefaultsForTesting() {
        DispatchQueue.main.async {
            self.geoLocalizationAccuracy = .high
            self.currentLatLon = CLLocationCoordinate2D(latitude: 42.2, longitude: -71.0)
        }
    }
    
    private func startGARSession() {
        do {
            garSession = try GARSession(apiKey: garAPIKey, bundleIdentifier: nil)
            var error: NSError?
            let configuration = GARSessionConfiguration()
            configuration.cloudAnchorMode = .enabled
            configuration.geospatialMode = .enabled
            garSession?.setConfiguration(configuration, error: &error)
            garSession?.delegate = self
            print("gar set configuration error \(error)")
        } catch {
            print("failed to create GARSession")
        }
    }
}

extension PositioningModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        do {
            let garFrame = try garSession?.update(frame)
            if let cameraGeospatialTransform = garFrame?.earth?.cameraGeospatialTransform {
                print("horizontalAccuracy \(cameraGeospatialTransform.horizontalAccuracy)")
                currentLatLon = cameraGeospatialTransform.coordinate
                if cameraGeospatialTransform.horizontalAccuracy < 3.0 {
                    geoLocalizationAccuracy = .high
                } else if cameraGeospatialTransform.horizontalAccuracy < 8.0 {
                    geoLocalizationAccuracy = .medium
                } else {
                    geoLocalizationAccuracy = .low
                }
            }
        } catch {
            print("Unable to update frame")
        }
    }
}

extension PositioningModel: GARSessionDelegate {
    // TODO: add function that are needed
}
