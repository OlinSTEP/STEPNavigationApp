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

/// This is a coarse metric of how well we have localized the user with respect to their latitude and longitude.
/// Currently, there is no defined standard for these values (they are determined on a View by View basis)
enum GeoLocationAccuracy: Int {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    
    func isAtLeastAsGoodAs(other: GeoLocationAccuracy)->Bool {
        return self.rawValue >= other.rawValue
    }
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
    private var latestGARAnchors: [GARAnchor]? = nil
    public static var shared = PositioningModel()
    private var manualAlignment: simd_float4x4? {
        didSet {
            if let newValue = manualAlignment {
                DispatchQueue.main.async {
                    if RouteNavigator.shared.nextKeypoint?.mode != .latLonBased {
                        self.rendererHelper.anchorEntity?.setTransformMatrix(newValue, relativeTo: nil)
                    }
                }
            }
        }
    }
    private let rendererHelper: RendererHelper
    private var cloudAnchorAligner = CloudAnchorAligner()
    @Published var resolvedCloudAnchors = Set<String>()

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
        rendererHelper.removeRenderedContent()
    }
    
    func resetAlignment() {
        manualAlignment = nil
        cloudAnchorAligner = CloudAnchorAligner()
    }
    
    func hasAligned()->Bool {
        if let nextKeypoint = RouteNavigator.shared.nextKeypoint,
           nextKeypoint.mode == .latLonBased,
           let currentPosition = currentLocation(of: nextKeypoint) {
            return !simd_almost_equal_elements(currentPosition, matrix_identity_float4x4, 0.001)
        }
        return manualAlignment != nil
    }
    
    func currentLocation(of transform: simd_float4x4)->simd_float4x4 {
        if let manualAlignment = manualAlignment {
            return manualAlignment * transform
        } else {
            return transform
        }
    }
    
    func currentLocation(of keypoint: KeypointInfo)->simd_float4x4? {
        switch keypoint.mode {
        case .cloudAnchorBased:
            return currentLocation(of: keypoint.location)
        case .latLonBased:
            return currentLocation(ofGARAnchor: keypoint.id)
        }
    }
    
    func currentLocation(ofGARAnchor id: UUID)->simd_float4x4? {
        guard let latestGARAnchors = latestGARAnchors else {
            return nil
        }
        for anchor in latestGARAnchors {
            if anchor.identifier == id {
                return anchor.transform
            }
        }
        return nil
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
        PathLogger.shared.logPose(frame.camera.transform, timestamp: frame.timestamp)
        if frame.camera.trackingState == .normal && garSession == nil {
            startGARSession()
        }
        do {
            if let garFrame = try garSession?.update(frame) {
                latestGARAnchors = garFrame.anchors
                if let nextKeypoint = RouteNavigator.shared.nextKeypoint,
                   nextKeypoint.mode == .latLonBased {
                    for anchor in latestGARAnchors ?? [] {
                        if anchor.identifier == nextKeypoint.id {
                            rendererHelper.anchorEntity?.setTransformMatrix(anchor.transform, relativeTo: nil)
                        }
                    }
                }
                var shouldDoCloudAnchorAlignment = false
                for anchor in garFrame.updatedAnchors {
                    guard let cloudIdentifier = anchor.cloudIdentifier else {
                        continue
                    }
                    shouldDoCloudAnchorAlignment = true
                    cloudAnchorAligner.cloudAnchorDidUpdate(withCloudID: cloudIdentifier, withIdentifier: anchor.identifier.uuidString, withPose: anchor.transform, timestamp: frame.timestamp)
                }
                if shouldDoCloudAnchorAlignment {
                    manualAlignment = cloudAnchorAligner.adjust(currentAlignment: manualAlignment)
                }
                if let cameraGeospatialTransform = garFrame.earth?.cameraGeospatialTransform {
                    currentLatLon = cameraGeospatialTransform.coordinate
                    if cameraGeospatialTransform.horizontalAccuracy < 3.0 {
                        geoLocalizationAccuracy = .high
                    } else if cameraGeospatialTransform.horizontalAccuracy < 8.0 {
                        geoLocalizationAccuracy = .medium
                    } else {
                        geoLocalizationAccuracy = .low
                    }
                }
            }
        } catch {
            print("Unable to update frame")
        }
    }
    
    func renderKeypoint(_ keypoint: KeypointInfo) {
        // if we are using a lat / lon based keypoint, we don't want to use manualAlignment
        let initialAlignment = keypoint.mode == .cloudAnchorBased ? manualAlignment : matrix_identity_float4x4
        rendererHelper.renderKeypoint(at: keypoint.location, withInitialAlignment: initialAlignment)
    }
    
    func addTerrainAnchor(at location: CLLocationCoordinate2D, withName name: String)->GARAnchor? {
        guard let garSession = garSession else {
            return nil
        }
        do {
            let newAnchor = try garSession.createAnchorOnTerrain(coordinate: location, altitudeAboveTerrain: 1.0, eastUpSouthQAnchor: simd_quatf())
            return newAnchor
        } catch {
            
        }
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
    func session(_ session: GARSession, didResolve anchor:GARAnchor) {
        if let cloudIdentifier = anchor.cloudIdentifier {
            cloudAnchorAligner.cloudAnchorDidUpdate(withCloudID: cloudIdentifier, withIdentifier: anchor.identifier.uuidString, withPose: anchor.transform, timestamp: arView.session.currentFrame?.timestamp ?? 0.0)
            resolvedCloudAnchors.insert(cloudIdentifier)
            manualAlignment = cloudAnchorAligner.adjust(currentAlignment: manualAlignment)
        }
    }
}

class RendererHelper {
    let arView: ARView
    var anchorEntity: AnchorEntity?
    var keypointEntity: ModelEntity?
    var pollEntity: ModelEntity?
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    func renderKeypoint(at location: simd_float4x4, withInitialAlignment alignment: simd_float4x4?) {
        let mesh = MeshResource.generateBox(size: 0.5)
        let material = SimpleMaterial(color: .green, isMetallic: false)
        keypointEntity?.removeFromParent()
        keypointEntity = ModelEntity(mesh: mesh, materials: [material])
        keypointEntity!.position = location.translation
        if anchorEntity == nil {
            anchorEntity = AnchorEntity()
            arView.scene.anchors.append(anchorEntity!)
        }
        let initialTransform = alignment ?? matrix_identity_float4x4
        anchorEntity?.setTransformMatrix(initialTransform, relativeTo: nil)
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
