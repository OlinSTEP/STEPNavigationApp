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
import SwiftUI

/// This is a coarse metric of how well we have localized the user with respect to their latitude and longitude.
/// Currently, there is no defined standard for these values (they are determined on a View by View basis)
enum GeoLocationAccuracy: Int {
    case none = 0
    case coarse = 1
    case low = 2
    case medium = 3
    case high = 4
    
    func isAtLeastAsGoodAs(other: GeoLocationAccuracy)->Bool {
        return self.rawValue >= other.rawValue
    }
}

struct CloudAnchorMetadata {
    let name: String
    let type: AnchorType
    let associatedOutdoorFeature: String
    let geospatialTransform: GeospatialData
    
    func asDict()->[String: Any] {
        return ["name": name,
                "type": type.rawValue,
                "category": type.rawValue,
                "associatedOutdoorFeature": associatedOutdoorFeature,
                "geospatialTransform": geospatialTransform.asDict()]
    }
}

struct CloudAnchorResolutionInfomation {
    let identifier: String
    let lastUpdateTime: Date
    let pose: simd_float4x4
}

class PositioningModel: NSObject, ObservableObject {
    public static var shared = PositioningModel()

    // this would host and manage the ARSession
    let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
    private let locationManager = CLLocationManager()
    private var garSession: GARSession?
    private var latestGARAnchors: [GARAnchor]? = nil
    var qualityChecker: Timer?
    @Published var currentQuality: GARFeatureMapQuality?
    @Published var resolvedCloudAnchors = Set<String>()
    @Published var geoLocalizationAccuracy: GeoLocationAccuracy = .none
    @Published var currentLatLon: CLLocationCoordinate2D?
    
    private var pendingCloudAnchorMetadata: [UUID: CloudAnchorMetadata] = [:]
    
    private var poseBuffer: [simd_float4x4] = []
    static let poseBufferMaxLength = 30
    static let poseBufferLookbackForCloudAnchorAssessment = 15
    
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

    var cameraTransform: simd_float4x4? {
        return arView.session.currentFrame?.camera.transform
    }
    var cameraGeoSpatialTransform: GARGeospatialTransform? {
        return garSession?.currentFramePair?.garFrame.earth?.cameraGeospatialTransform
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
    
    func startPositioning() {
        stopPositioning()
        let configuration = ARWorldTrackingConfiguration()
        configuration.isAutoFocusEnabled = false
        arView.session.run(configuration)
    }
    
    func startCoarsePositioning() {
        locationManager.delegate = self
        // in case we have already positioned, use it here
        if let location = locationManager.location, -location.timestamp.timeIntervalSinceNow < 120.0 {
            currentLatLon = location.coordinate
            geoLocalizationAccuracy = .coarse
        }
        locationManager.startUpdatingLocation()
    }
    
    func stopPositioning() {
        garSession = nil
        arView.session.pause()
        resetAlignment()
    }

    func removeRenderedContent() {
        rendererHelper.removeRenderedContent()
    }
    
    func resetAlignment() {
        manualAlignment = nil
        currentQuality = nil
        currentLatLon = nil
        geoLocalizationAccuracy = .none
        resolvedCloudAnchors = []
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
    
    func currentLocation(ofCloudAnchor id: String)->simd_float4x4? {
        guard let latestGARAnchors = latestGARAnchors else {
            return nil
        }
        for anchor in latestGARAnchors {
            if anchor.cloudIdentifier == id {
                return anchor.transform
            }
        }
        return nil
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
            print("error \(error.localizedDescription)")
        }
    }
    
    func estimateFeatureMapQualityForHosting(pose: simd_float4x4) {
        do {
            currentQuality = try garSession?.estimateFeatureMapQualityForHosting(pose)
        } catch {
        }
    }
}

extension PositioningModel: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        PathLogger.shared.logPose(frame.camera.transform, timestamp: frame.timestamp)
        if frame.camera.trackingState == .normal && garSession == nil {
            startGARSession()
            monitorQuality()
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
    
    func createCloudAnchor(afterDelay delay: Double, withName name: String) {
        guard !name.isEmpty else {
            AnnouncementManager.shared.announce(announcement: "Please enter an anchor name")
            return
        }
        AnnouncementManager.shared.announce(announcement: "Creating cloud anchor in \(round(delay)) seconds")
        guard let cameraTransform = self.arView.session.currentFrame?.camera.transform,
              let geoSpatialTransfrom = garSession?.currentFramePair?.garFrame.earth?.cameraGeospatialTransform else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.createCloudAnchor(
                atPose: cameraTransform.alignY(),
                withMetadata: CloudAnchorMetadata(
                    name: name,
                    type: .indoorDestination,
                    associatedOutdoorFeature: "",
                    geospatialTransform: GeospatialData(arCoreGeospatial: geoSpatialTransfrom))
            )
        }
    }
    
    func createCloudAnchorFromBufferedPose(withMetadata metadata: CloudAnchorMetadata)->(GARAnchor, ARAnchor)? {
        if poseBuffer.isEmpty {
            return nil
        }
        let poseIndex = max(0, poseBuffer.count - Self.poseBufferLookbackForCloudAnchorAssessment)
        let poseToUseForQualityEstimation = poseBuffer[poseIndex].alignY()
        return createCloudAnchor(atPose: poseToUseForQualityEstimation, withMetadata: metadata)
    }
    
    func monitorQuality() {
        qualityChecker?.invalidate()
        qualityChecker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard let cameraTransform = self.arView.session.currentFrame?.camera.transform,
                  let geoSpatialTransfrom = self.garSession?.currentFramePair?.garFrame.earth?.cameraGeospatialTransform else {
                return
            }
            // TODO: not the best data structure
            self.poseBuffer.append(cameraTransform)
            if self.poseBuffer.count > Self.poseBufferMaxLength {
                // equivalent to pop front
                self.poseBuffer = Array(self.poseBuffer[1...])
            }
            do {
                let poseIndex = max(0, self.poseBuffer.count - Self.poseBufferLookbackForCloudAnchorAssessment)
                let poseToUseForQualityEstimation = self.poseBuffer[poseIndex]
                self.estimateFeatureMapQualityForHosting(pose: poseToUseForQualityEstimation)
            } catch {
                
            }
        }
    }
    
    func createCloudAnchor(atPose pose: simd_float4x4, withMetadata metadata: CloudAnchorMetadata)->(GARAnchor, ARAnchor)? {
        let newAnchor = ARAnchor(transform: pose)
        arView.session.add(anchor: newAnchor)
        do {
            AnnouncementManager.shared.announce(announcement: "Trying to host anchor")
            if let newGARAnchor = try garSession?.hostCloudAnchor(newAnchor) {
                pendingCloudAnchorMetadata[newGARAnchor.identifier] = metadata
                return (newGARAnchor, newAnchor)
            }
        } catch {
            print("host cloud anchor failed \(error.localizedDescription)")
        }
        return nil
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
    
    /// This function is called whenever a cloud anchor has been successfully hosted by Google's ARCore library.  This gives our app a chance to store the newly created anchor in various datastructures or databases.
    /// - Parameters:
    ///   - session: the GAR session associated with the anchor
    ///   - garAnchor: the GARAnchor itself (this will have the cloudIdentifier, which is the way to refer to this anchor across session, as well as the anchor identifier, which s the way to refer to the anchor within this session)
    func session(_ session: GARSession, didHost garAnchor:GARAnchor) {
        guard let metadata = pendingCloudAnchorMetadata[garAnchor.identifier] else {
            AnnouncementManager.shared.announce(announcement: "Unexpectedly hosted an anchor without metadata")
            return
        }
        guard let cloudIdentifier = garAnchor.cloudIdentifier else {
            return
        }
        pendingCloudAnchorMetadata.removeValue(forKey: garAnchor.identifier)
        switch metadata.type {
        case .indoorDestination:
           FirebaseManager.shared.storeCloudAnchor(identifier: cloudIdentifier, metadata: metadata)
        default:
            PathRecorder.shared.addCloudAnchor(identifier: cloudIdentifier, metadata: metadata, currentPose: garAnchor.transform)
        }
        AnnouncementManager.shared.announce(announcement: "Cloud Anchor Created")
    }
    
    
    func session(_ session: GARSession, didFailToHost garAnchor: GARAnchor) {
        AnnouncementManager.shared.announce(announcement: "Failed to host anchor")
        pendingCloudAnchorMetadata.removeValue(forKey: garAnchor.identifier)
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
        let material = SimpleMaterial(color: UIColor(AppColor.accent), isMetallic: false)
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

extension PositioningModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last, garSession == nil else {
            return
        }
        print("Updating with coarse localization")
        currentLatLon = mostRecentLocation.coordinate
        geoLocalizationAccuracy = .coarse
    }
}
