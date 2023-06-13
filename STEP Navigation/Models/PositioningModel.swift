//
//  PositioningModel.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import ARKit
import ARCoreGeospatial
import ARCoreCloudAnchors
import SwiftUI
import GeoFireUtils

/// This is a coarse metric of how well we have localized the user with respect to their latitude and longitude.
/// Currently, there is no defined standard for these values (they are determined on a View by View basis)
enum GeoLocationAccuracy: Int {
    /// We have no sense of where we are
    case none = 0
    /// We have localized but is with GPS only
    case coarse = 1
    /// We have are localizing with a combination of GPS and imagery, but we don't have high confidence in where we are yet
    case low = 2
    /// We have are localizing with a combination of GPS and imagery, but we only have medium confidence in where we are
    case medium = 3
    /// We have are localizing with a combination of GPS and imagery and we have high confidence in where we are
    case high = 4
    
    /// Determines whether this accuracy value is at least as good as the specified `other`
    /// - Parameter other: the accuracy value to compare against
    /// - Returns: true if the accuracy value is at least as good as other
    func isAtLeastAsGoodAs(other: GeoLocationAccuracy)->Bool {
        return self.rawValue >= other.rawValue
    }
}

//struct AnchorPoseData {
//    var pose: simd_float4x4
//    var timestamp: Double
//}

/// This stores the metadata about the cloud anchor.  Note: that the cloudIdentifier is not stored here, but rather maintained as the key in various data structures that store ``CloudAnchorMetadata``
struct CloudAnchorMetadata {
    /// The name of the cloud anchor (this is user-facing, can be changed, and is not guaranteed to be unique)
    let name: String
    /// This is the high-level category of the cloud anchor
    let type: AnchorType
    /// This is the ID of a ``LocationDataModel`` object for an outdoor feature.  The assumption is that cloud anchor and this outdoor feature are roughly coincident
    let associatedOutdoorFeature: String
    /// The geospatial data for this feature
    let geospatialTransform: GeospatialData
    /// The creator of this cloud anchor
    let creatorUID: String
    /// True if the cloud anchor can be read by the general public, false if it can only be ready by the user who created it
    let isReadable: Bool
//    /// The timestamps for when the anchors are resolved
//    let anchorTimestamp: Double
    
    /// Convert the cloud anchor data to a dictionary that is suitable for serialization or storage in a database
    /// - Returns: the dictionary as key-value pairs
    func asDict()->[String: Any] {
        // Compute the GeoHash for a lat/lng point
        let hash = GFUtils.geoHash(forLocation: geospatialTransform.location)
        return ["name": name,
                "creatorUID": creatorUID,
                "isReadable": isReadable,
                "type": type.rawValue,
                "category": type.rawValue,
                "associatedOutdoorFeature": associatedOutdoorFeature,
                "geospatialTransform": geospatialTransform.asDict(),
                "geohash": hash]
    }
}

/// Information on how various cloud anchors were resolved.  This is used primarily for logging and data analysis
struct CloudAnchorResolutionInfomation {
    /// The cloud identifier for the anchor
    let identifier: String
    /// The time the anchor was last updated (cloud anchors move around periodically after they are first resolved)
    let lastUpdateTime: Date
    /// The pose of the cloud anchor in the current `ARSession`
    let pose: simd_float4x4
}

/// This class handles three basic functions.  First, it maintains the positioning information for the current session (in both AR space and in geolocation space).  Second, it handles the alignment of map space to the current AR space.  Third, it manages the rendering of content in the AR scene.
class PositioningModel: NSObject, ObservableObject {
    /// The shared handle to the singleton instance of this class
    public static var shared = PositioningModel()

    // this would host and manage the ARSession
    let arView = ARSCNView(frame: .zero)
    /// the location manager (used for asking for localization permission and for coarse positioning)
    private let locationManager = CLLocationManager()
    /// the ARCore session
    private var garSession: GARSession?
    /// the most recently captured anchor from the ARCore sesion
    private var latestGARAnchors: [GARAnchor]? = nil
    /// a timer used to periodically check the quality of data for hosting a new cloud anchor
    private var qualityChecker: Timer?
    /// a mapping from anchor identifiers to cloud identifiers
    private var identifierToCloudIdentifier: [UUID: String] = [:]
    /// the most recent quality (useful for updating SwiftUI-based views)
    @Published var currentQuality: GARFeatureMapQuality?
    /// the cloud anchors that have been resolved so far.  The elements of the set are the cloud identifiers
    @Published var resolvedCloudAnchors = Set<String>()
    /// the name of the anchor that was most recently resolved
    @Published var lastAnchor : String = ""
    /// the current geo localization accuracy
    @Published var geoLocalizationAccuracy: GeoLocationAccuracy = .none
    /// the current latitude and longitude
    @Published var currentLatLon: CLLocationCoordinate2D?
    /// A buffer of previous poses that provide us with suitable history for estimate cloud anchor quality
    private var poseBuffer: [simd_float4x4] = []
    /// the maximum length of the pose buffer
    private static let poseBufferMaxLength = 30
    /// the lookback in the pose buffer when estimating cloud anchor quality
    private static let poseBufferLookbackForCloudAnchorAssessment = 15
    /// the cloud anchors currently being resolved in this session
    private var cloudAnchorsBeingResolved: Set<String> = []
    
    /// the alignment that transforms the map coordinate system to the current ARKit session's coordinate system
    private var manualAlignment: simd_float4x4? {
        didSet {
            if let newValue = manualAlignment {
                DispatchQueue.main.async {
                    if RouteNavigator.shared.nextKeypoint?.mode != .latLonBased {
                        self.rendererHelper.anchorNode?.simdTransform = newValue
                    }
                }
            }
        }
    }
    /// used for rendering to the `ARSCNView`
    private let rendererHelper: RendererHelper
    /// used for filtering cloud anchor resolution data
    private var cloudAnchorAligner = CloudAnchorAligner()
    
    /// the pose of the camera in the current ARKit tracking session (or nil if not available)
    var cameraTransform: simd_float4x4? {
        return arView.session.currentFrame?.camera.transform
    }
    /// the most recent geo spatial data from ARCore (or nil if not available)
    var cameraGeoSpatialTransform: GARGeospatialTransform? {
        return garSession?.currentFramePair?.garFrame.earth?.cameraGeospatialTransform
    }
    
    /// The private initializer.  Don't call this directly (use the singleton instance)
    private override init() {
        rendererHelper = RendererHelper(arView: arView)
        super.init()
        locationManager.requestWhenInUseAuthorization()
        arView.session.delegate = self
    }
    
    /// Start the ARCore session
    private func startGARSession() {
        do {
            garSession = try GARSession(apiKey: garAPIKey, bundleIdentifier: nil)
            identifierToCloudIdentifier = [:]
            var error: NSError?
            let configuration = GARSessionConfiguration()
            configuration.cloudAnchorMode = .enabled
            configuration.geospatialMode = .enabled
            configuration.streetscapeGeometryMode = SettingsManager.shared.visualizeStreetscapeData ? .enabled : .disabled
            garSession?.setConfiguration(configuration, error: &error)
            print("gar set configuration error \(error?.localizedDescription ?? "none")")
        } catch {
            print("failed to create GARSession")
        }
    }
    
    /// Start positioning using ARKit and ARCore
    func startPositioning() {
        stopPositioning()
        let configuration = ARWorldTrackingConfiguration()
        configuration.isAutoFocusEnabled = false
        arView.session.run(configuration)
    }
    
    /// Start positioning using only GPS
    func startCoarsePositioning() {
        locationManager.delegate = self
        // in case we have already positioned, use it here
        if let location = locationManager.location, -location.timestamp.timeIntervalSinceNow < 1000.0 {
            // we do this on a delay to give the view a chance to observe this change
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                guard self.geoLocalizationAccuracy == .none else {
                    return
                }
                self.currentLatLon = location.coordinate
                self.geoLocalizationAccuracy = .coarse
                FirebaseManager.shared.queryNearbyAnchors(to: location.coordinate, withRadius: 1000.0)
            }
        }
        locationManager.startUpdatingLocation()
    }
    
    /// Stop positioning using ARCore and ARKit
    func stopPositioning() {
        garSession = nil
        cloudAnchorsBeingResolved = []
        arView.session.pause()
        resetAlignment()
    }
    
    /// Remove any rendered content
    func removeRenderedContent() {
        rendererHelper.removeRenderedContent()
    }
    
    /// Reset the alignment that has been determined between map space and ARKit space
    func resetAlignment() {
        manualAlignment = nil
        currentQuality = nil
        currentLatLon = nil
        geoLocalizationAccuracy = .none
        resolvedCloudAnchors = []
        cloudAnchorAligner = CloudAnchorAligner()
    }
    
    /// Computes whether alignment has successfully occurred to map space
    /// - Returns: true if alignment has occurred and false otherwise
    func hasAligned()->Bool {
        if let nextKeypoint = RouteNavigator.shared.nextKeypoint,
           nextKeypoint.mode == .latLonBased,
           let currentPosition = currentLocation(of: nextKeypoint) {
            return !simd_almost_equal_elements(currentPosition, matrix_identity_float4x4, 0.001)
        }
        return manualAlignment != nil
    }
    
    /// Provides the current location of some feature in the map by applying the current transform between map and ARKit space
    /// - Parameter transform: a pose in map space
    /// - Returns: a pose in ARKit tracking space.  If alignment has not happened yet, the pose is returned without modification.
    func currentLocation(of transform: simd_float4x4)->simd_float4x4 {
        if let manualAlignment = manualAlignment {
            return manualAlignment * transform
        } else {
            return transform
        }
    }
    
    /// Compute the location of a keypoint object in ARKit tracking space
    /// - Parameter keypoint: the keypoint info
    /// - Returns: the pose in ARKit tracking space if the transform can be done and nil if it cannot
    func currentLocation(of keypoint: KeypointInfo)->simd_float4x4? {
        switch keypoint.mode {
        case .cloudAnchorBased:
            return currentLocation(of: keypoint.location)
        case .latLonBased:
            return currentLocation(ofGARAnchor: keypoint.id)
        }
    }
    
    /// Get the current location of the specified cloud anchor in ARKit space based on its cloud identifier
    /// - Parameter id: the cloud identifier
    /// - Returns: the latest pose (if one is available) and nil if none is available
    func currentLocation(ofCloudAnchor id: String)->simd_float4x4? {
        guard let latestGARAnchors = latestGARAnchors else {
            return nil
        }
        for anchor in latestGARAnchors {
            if identifierToCloudIdentifier[anchor.identifier] == id {
                return anchor.transform
            }
        }
        return nil
    }
    
    /// Get the current location of the specified anchor based on its identifier
    /// - Parameter id: the `GARAnchor` identifier
    /// - Returns: the latest pose (if one is available) and nil if none is available
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
    
    /// Initiate a request to resolve a cloud anchor based on its cloud identifier
    /// - Parameter cloudAnchorID: the cloud identifier
    func resolveCloudAnchor(byID cloudAnchorID: String) {
        
        guard !cloudAnchorsBeingResolved.contains(cloudAnchorID) else {
            return
        }
        do {
            cloudAnchorsBeingResolved.insert(cloudAnchorID)
            try garSession?.resolveCloudAnchor(cloudAnchorID) { garAnchor, anchorState in
                guard anchorState == .success else {
                    return
                }
                guard let garAnchor = garAnchor else {
                    return
                }
//                self.anchorCrumbs.append(AnchorTimeData(pose: , timestamp: PositioningModel.shared.arView.session.currentFrame?.timestamp ?? 0.0))
                self.identifierToCloudIdentifier[garAnchor.identifier] = cloudAnchorID
                self.cloudAnchorAligner.cloudAnchorDidUpdate(
                    withCloudID: cloudAnchorID,
                    withIdentifier: garAnchor.identifier.uuidString,
                    withPose: garAnchor.transform,
                    timestamp: self.arView.session.currentFrame?.timestamp ?? 0.0)
                self.resolvedCloudAnchors.insert(cloudAnchorID)
                self.lastAnchor = FirebaseManager.shared.getCloudAnchorName(byID: cloudAnchorID) ?? ""
                self.manualAlignment = self.cloudAnchorAligner.adjust(currentAlignment: self.manualAlignment)
                
                PathRecorder.shared.addCloudAnchor(identifier: cloudAnchorID, metadata: FirebaseManager.shared.getCloudAnchorMetadata(byID: cloudAnchorID)!, currentPose: garAnchor.transform, timestamp: self.arView.session.currentFrame?.timestamp ?? 0.0)
            }
        } catch {
            print("error \(error.localizedDescription)")
        }
    }
    
    /// Estimate the quality of data for creating a cloud anchor
    /// - Parameter pose: the pose to use as a reference
    private func estimateFeatureMapQualityForHosting(pose: simd_float4x4) {
        do {
            currentQuality = try garSession?.estimateFeatureMapQualityForHosting(pose)
        } catch {
            print("quality estimation error: \(error.localizedDescription)")
        }
    }
    
    /// Render the keypoint in the session
    /// - Parameter keypoint: the keypoint description
    func renderKeypoint(_ keypoint: KeypointInfo) {
        // if we are using a lat / lon based keypoint, we don't want to use manualAlignment
        let initialAlignment = keypoint.mode == .cloudAnchorBased ? manualAlignment : matrix_identity_float4x4
        rendererHelper.renderKeypoint(at: keypoint.location, withInitialAlignment: initialAlignment)
    }
    
    /// Add a new terrain anchor at the specified location
    /// - Parameters:
    ///   - location: the location for the cloud anchor (the altitude is set automatically by the ARCore machinery)
    ///   - name: the name to use for the terrain anchor
    /// - Returns: the initial GARAnchor that tracks the terrain anchor
    func addTerrainAnchor(at location: CLLocationCoordinate2D, withName name: String, completionHandler: @escaping (GARAnchor?, GARTerrainAnchorState)->()) {
        guard let garSession = garSession else {
            completionHandler(nil, .errorInternal)
            return
        }
        do {
            try garSession.createAnchorOnTerrain(coordinate: location, altitudeAboveTerrain: 1.0, eastUpSouthQAnchor: simd_quatf()) { garAnchor, anchorState in
                completionHandler(garAnchor, anchorState)
            }
        } catch {
            completionHandler(nil, .errorInternal)
        }
    }
    
    /// Monitor the quality of a potential cloud anchor that could be created from the recently captured visual / spatial data
    func monitorQuality() {
        qualityChecker?.invalidate()
        qualityChecker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard let cameraTransform = self.arView.session.currentFrame?.camera.transform else {
                return
            }
            // TODO: not the best data structure
            self.poseBuffer.append(cameraTransform)
            if self.poseBuffer.count > Self.poseBufferMaxLength {
                // equivalent to pop front
                self.poseBuffer = Array(self.poseBuffer[1...])
            }
            let poseIndex = max(0, self.poseBuffer.count - Self.poseBufferLookbackForCloudAnchorAssessment)
            let poseToUseForQualityEstimation = self.poseBuffer[poseIndex]
            self.estimateFeatureMapQualityForHosting(pose: poseToUseForQualityEstimation)
        }
    }
    
    
    /// Set the cloud anchor landmarks that will be used for aligning map space and the current tracking session
    /// - Parameter landmarks: the keys are cloud anchor identifiers and the values are the expected poses in map space.
    func setCloudAnchors(landmarks: [String: simd_float4x4]) {
        cloudAnchorAligner.cloudAnchorLandmarks = landmarks
        for cloudAnchorID in landmarks.keys {
            resolveCloudAnchor(byID: cloudAnchorID)
        }
    }
    
    /// Create a new cloud anchor after the specified delay and with the specified name
    /// - Parameters:
    ///   - delay: the delay in seconds before creating the cloud anchor
    ///   - name: the name to associate with the cloud anchor
    ///   - completionHandler: called with true if the cloud anchor is successful created and false otherwise
    func createCloudAnchor(afterDelay delay: Double, withName name: String, completionHandler: @escaping (Bool)->()) {
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
                    geospatialTransform: GeospatialData(arCoreGeospatial: geoSpatialTransfrom), creatorUID: AuthHandler.shared.currentUID ?? "", isReadable: true),
                completionHandler: completionHandler
            )
        }
    }

    /// Create a new cloud anchor using a pose from several seconds ago
    /// - Parameters:
    ///     - metadata: the metadata for the cloud anchor
    ///     - completionHandler: called with an input of true if the cloud anchor is successfully created and false otherwise
    func createCloudAnchorFromBufferedPose(withMetadata metadata: CloudAnchorMetadata, completionHandler: @escaping (Bool)->()) {
        guard !poseBuffer.isEmpty else {
            return
        }
        let poseIndex = max(0, poseBuffer.count - Self.poseBufferLookbackForCloudAnchorAssessment)
        let poseToUseForQualityEstimation = poseBuffer[poseIndex].alignY()
        createCloudAnchor(atPose: poseToUseForQualityEstimation, withMetadata: metadata, completionHandler: completionHandler)
    }
    
    /// Create a new cloud anchor
    /// - Parameters:
    ///   - pose: the pose of the cloud anchor in the current tracking session
    ///   - metadata: the metadata to be associated with the cloud anchor
    ///   - completionHandler: called with an input of true if the cloud anchor is successfully created and false otherwise
    func createCloudAnchor(atPose pose: simd_float4x4, withMetadata metadata: CloudAnchorMetadata, completionHandler: @escaping (Bool)->()) {
        let newAnchor = ARAnchor(transform: pose)
        arView.session.add(anchor: newAnchor)
        do {
            AnnouncementManager.shared.announce(announcement: "Trying to host anchor")
            try garSession?.hostCloudAnchor(newAnchor, ttlDays: 1) { cloudIdentifier, anchorState in
                guard anchorState == .success else {
                    AnnouncementManager.shared.announce(announcement: "Failed to host anchor")
                    return completionHandler(false)
                }
                guard let cloudIdentifier = cloudIdentifier else {
                    return completionHandler(false)
                }
                switch metadata.type {
                case .indoorDestination:
                    FirebaseManager.shared.storeCloudAnchor(identifier: cloudIdentifier, metadata: metadata)
                default:
                    PathRecorder.shared.addCloudAnchor(identifier: cloudIdentifier, metadata: metadata, currentPose: pose, timestamp: self.arView.session.currentFrame?.timestamp ?? 0.0)
              // I'm taking the current timestamp but not totally sure if that's write
                }
                AnnouncementManager.shared.announce(announcement: "Cloud Anchor Created")
                return completionHandler(true)
            }
        } catch {
            print("host cloud anchor failed \(error.localizedDescription)")
            return completionHandler(false)
        }
    }
    
    /// Print some debug information about the street scape (warning produces a lot of output each frame).  Only high quality street scapes are printed currently.
    /// - Parameter garFrame: a frame from the ARCore session
    private func serializeStreetscape(_ garFrame: GARFrame) {
        for geometries in garFrame.streetscapeGeometries ?? [] {
            if geometries.quality == .buildingLOD_2 {
                print("vertices")
                print("[")
                for point in UnsafeBufferPointer(start: geometries.mesh.vertices, count: Int(geometries.mesh.vertexCount)) {
                    print("[\(point.x), \(point.y), \(point.z)]")
                }
                print("]")
                print("triangles")
                print("[")
                for triangle in UnsafeBufferPointer(start: geometries.mesh.triangles, count: Int(geometries.mesh.triangleCount)) {
                    print("[\(triangle.indices.0), \(triangle.indices.1), \(triangle.indices.2)]")
                }
                print("]")
            }
        }
    }
}

extension PositioningModel: ARSessionDelegate {
    /// Handle new frames from the ARKit tracking session.  This is called automatically as part of the delegate interface.
    /// This function currently performs the following functions
    ///     * Starts the ARCore session if it has not been started yet
    ///     * Passes the frame to ARCore
    ///     * Updates the geo spatial tracking accuracy
    ///     * Adjusts `manualAlignment` based on cloud anchors that have been resolved
    /// - Parameters:
    ///   - session: the session currently used for tracking
    ///   - frame: the new frame
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
                            rendererHelper.keypointNode?.simdTransform = anchor.transform
                        }
                    }
                }
                if SettingsManager.shared.visualizeStreetscapeData {
                    for geometry in garFrame.streetscapeGeometries ?? [] {
                        if geometry.type == .building {
                            rendererHelper.renderStreetscapeMesh(geometries: geometry, color: .cyan)
                        } else {
                            rendererHelper.renderStreetscapeMesh(geometries: geometry, color: .black)
                        }
                    }
                    //serializeStreetscape(garFrame)
                }
                var shouldDoCloudAnchorAlignment = false
                for anchor in garFrame.updatedAnchors {
                    guard let cloudIdentifier = identifierToCloudIdentifier[anchor.identifier] else {
                        continue
                    }
                    self.lastAnchor = FirebaseManager.shared.getCloudAnchorName(byID: cloudIdentifier) ?? ""
                    PathRecorder.shared.addCloudAnchor(identifier: cloudIdentifier, metadata: FirebaseManager.shared.getCloudAnchorMetadata(byID: cloudIdentifier)!, currentPose: anchor.transform, timestamp: garFrame.timestamp)
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
}

/// This class is used for rendering keypoints and (eventually) other objects into the `ARSCNView`
class RendererHelper {
    /// the view used for rendering
    let arView: ARSCNView
    /// The root node of the scene that adjusts the position of its children relative to the current tracking session.  We can think of `anchorNode` as defining a local coordinate system in map space.
    var anchorNode: SCNNode?
    /// The node used to render the keypoint
    var keypointNode: SCNNode?
    /// The streetscape meshes that have been rendered
    var renderedStreetscapes: [UUID: SCNNode] = [:]
    
    init(arView: ARSCNView) {
        self.arView = arView
    }
    
    func renderStreetscapeMesh(geometries: GARStreetscapeGeometry, color: UIColor) {
        if renderedStreetscapes[geometries.identifier] == nil {
            var vertices: [SCNVector3] = []
            var triangles: [UInt32] = []
            for point in UnsafeBufferPointer(start: geometries.mesh.vertices, count: Int(geometries.mesh.vertexCount)) {
                vertices.append(SCNVector3(point.x, point.y, point.z))
            }
            let geometrySource = SCNGeometrySource(vertices: vertices)
            for triangle in UnsafeBufferPointer(start: geometries.mesh.triangles, count: Int(geometries.mesh.triangleCount)) {
                triangles.append(triangle.indices.0)
                triangles.append(triangle.indices.1)
                triangles.append(triangle.indices.2)
            }
            let geometryElement = SCNGeometryElement(indices: triangles, primitiveType: .triangles)
            let geometryFinal = SCNGeometry(sources: [geometrySource], elements: [geometryElement])
            let node = SCNNode(geometry: geometryFinal)
            node.geometry?.firstMaterial?.diffuse.contents = color
            node.geometry?.firstMaterial?.fillMode = .lines
            PositioningModel.shared.arView.scene.rootNode.addChildNode(node)
            print("adding new node")
            renderedStreetscapes[geometries.identifier] = node
        }
        renderedStreetscapes[geometries.identifier]!.simdTransform = geometries.meshTransform
    }
    
    
    func renderKeypoint(at location: simd_float4x4, withInitialAlignment alignment: simd_float4x4?) {
        let mesh = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
        mesh.firstMaterial?.diffuse.contents = UIColor(AppColor.accent)
        keypointNode?.removeFromParentNode()
        keypointNode = SCNNode(geometry: mesh)
        keypointNode!.simdPosition = location.translation
        if anchorNode == nil {
            anchorNode = SCNNode()
            arView.scene.rootNode.addChildNode(anchorNode!)
        }
        let initialTransform = alignment ?? matrix_identity_float4x4
        anchorNode?.simdTransform = initialTransform
        anchorNode!.addChildNode(keypointNode!)
    }
    
    /// Get rid of any content that has been rendered in the scene
    func removeRenderedContent() {
        anchorNode?.removeFromParentNode()
        anchorNode = nil
        for streetscape in renderedStreetscapes.values {
            streetscape.removeFromParentNode()
        }
        renderedStreetscapes = [:]
    }
}

extension PositioningModel: CLLocationManagerDelegate {
    /// Handle updates in coarse positioning (this happens through the`CLLocationManagerDelegate` interface
    /// - Parameters:
    ///   - manager: the location manager
    ///   - locations: the new locations of the device.  If more than one are present, the last one is the most recent.
    func locationManager(_ manager: CLLocationManager, Locations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last, garSession == nil else {
            return
        }
        print("Updating with coarse localization")
        currentLatLon = mostRecentLocation.coordinate
        FirebaseManager.shared.queryNearbyAnchors(to: mostRecentLocation.coordinate, withRadius: 1000.0)
        geoLocalizationAccuracy = .coarse
    }
}
