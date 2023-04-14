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

struct CloudAnchorMetadata {
    let name: String
    let type: AnchorType
    
    func asDict()->[String: Any] {
        return ["name": name, "type": type.rawValue]
    }
}

struct CloudAnchorResolutionInfomation {
    let identifier: String
    let lastUpdateTime: Date
    let pose: simd_float4x4
}

class PositioningModel: NSObject, ObservableObject {
    // this would host and manage the ARSession
    let arView = ARView(frame: .zero)
    private let locationManager = CLLocationManager()
    private var garSession: GARSession?
    public static var shared = PositioningModel()
    private var manualAlignment: simd_float4x4?
    private let rendererHelper: RendererHelper
    private let cloudAnchorAligner = CloudAnchorAligner()

    @Published var geoLocalizationAccuracy: GeoLocationAccuracy = .none
    @Published var currentLatLon: CLLocationCoordinate2D?
    
    var cameraTransform: simd_float4x4? {
        return arView.session.currentFrame?.camera.transform
    }
    
    private override init() {
        rendererHelper = RendererHelper(arView: arView)
        super.init()
        locationManager.requestWhenInUseAuthorization()
        arView.session.delegate = self
        startGARSession()
        //setDefaultsForTesting()
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
    
    func removeRenderedContent() {
        
    }
    
    func hasAligned()->Bool {
        return manualAlignment != nil
    }
    
    func currentLocation(of transform: simd_float4x4)->simd_float4x4 {
        if let manualAlignment = manualAlignment {
            return manualAlignment * transform
        } else {
            return transform
        }
    }
    
    func resolveCloudAnchor(byID cloudAnchorID: String) {
        do {
            try garSession?.resolveCloudAnchor(cloudAnchorID)
        } catch {
            //AnnouncementManager.shared.announce(announcement: "Unable to resolve cloud anchor")
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
                // NOTE: Don't check in
                if cameraGeospatialTransform.horizontalAccuracy < 300.0 {
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
    
    func renderKeypoint(at location: simd_float4x4) {
        rendererHelper.renderKeypoint(at: location)
    }
    
    func addTerrainAnchor(at location: CLLocationCoordinate2D, withName name: String)->GARAnchor? {
        // TODO: fill in
        return nil
    }
    
    func setCloudAnchors(landmarks: [String: simd_float4x4]) {
        cloudAnchorAligner.cloudAnchorLandmarks = landmarks
        for cloudAnchorID in landmarks.keys {
            resolveCloudAnchor(byID: cloudAnchorID)
        }
    }
}

extension PositioningModel: GARSessionDelegate {
    // TODO: add function that are needed
}

class RendererHelper {
    let arView: ARView
    var anchorEntity: AnchorEntity?
    var keypointEntity: ModelEntity?
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    func renderKeypoint(at location: simd_float4x4) {
        let mesh = MeshResource.generateBox(size: 0.5)
        let material = SimpleMaterial(color: .green, isMetallic: false)
        keypointEntity?.removeFromParent()
        keypointEntity = ModelEntity(mesh: mesh, materials: [material])
        keypointEntity!.position = location.translation
        if anchorEntity == nil {
            anchorEntity = AnchorEntity()
            arView.scene.anchors.append(anchorEntity!)
        }
        anchorEntity!.addChild(keypointEntity!)
    }
    
    func removeRenderedContent() {
        anchorEntity?.removeFromParent()
        anchorEntity = nil
    }
    
    func render(path poses: [simd_float4x4]) {
        if anchorEntity == nil {
            anchorEntity = AnchorEntity()
            arView.scene.anchors.append(anchorEntity!)
        }
        let mesh = MeshResource.generateBox(size: 0.2)
        let material = SimpleMaterial(color: .red, isMetallic: false)
        for pose in poses {
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            modelEntity.position = pose.translation
            anchorEntity!.addChild(modelEntity)
        }
        arView.scene.anchors.append(anchorEntity!)
    }
}
