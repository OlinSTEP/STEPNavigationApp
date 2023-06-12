//
//  PathRecorder.swift
//  InvisibleMapTake2
//
//  Created by Paul Ruvolo on 4/4/23.
//

import Foundation
import ARKit
import ARCoreGeospatial
import Firebase
import FirebaseDatabase
import FirebaseStorage

var firebaseRef: DatabaseReference!
var firebaseStorage: Storage!
var firebaseStorageRef: StorageReference!

struct PoseData {
    var pose: simd_float4x4
    var timestamp: Double
}
/// Record breadcrumbs (sequence of poses) along with cloud anchors recorded along the path
class PathRecorder {
    /// The shared singleton instance of this class
    public static var shared = PathRecorder()
    /// The sequence of poses that make up this path
    private (set) var breadCrumbs: [PoseData] = []
    /// The cloud anchors created along this path (the key is the cloud identifier and the value consists of the
    /// cloud anchor metadata and itse pose in the recording session)
    private (set) var cloudAnchors: [String: (CloudAnchorMetadata, simd_float4x4)] = [:]
    /// A timer used to periodically capture poses
    private var recordingTimer: Timer?
    /// A timer used to periodically host cloud anchors
    private var cloudAnchorTimer: Timer?
    /// The cloud identifier of the starting cloud anchor of this path
    var startAnchorID: String?
    /// The cloud identifier of the starting cloud anchor of this path
    var stopAnchorID: String?
    
    /// The private initializer (this should not be called directly)
    private init() {
    }
    
    ///Start recording path breadcrumbs and hosting path cloud anchors
    func startRecording() {
        startRecordingPath(withFrequency: 5.0)
        startRecordingCloudAnchors(withFrequency: 1/20.0)
    }
    
    func startRecordingPathonly(){
        startRecordingPath(withFrequency: 5.0)
    }
    
    /// Start recording the path with the specified frequency of pose capture.
    /// - Parameter hz: this is the frquency with which to capture poses to store as breadcrumbs.
    private func startRecordingPath(withFrequency hz: Double) {
        breadCrumbs = []
        cloudAnchors = [:]
        recordingTimer?.invalidate()
        cloudAnchorTimer?.invalidate()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1/hz, repeats: true) { timer in
            guard let currentPose = PositioningModel.shared.cameraTransform else {
                return
            }
            self.breadCrumbs.append(PoseData(pose: currentPose, timestamp: PositioningModel.shared.arView.session.currentFrame?.timestamp ?? 0.0))
        }
    }
    
    /// Start recording cloud anchors at the specified frequency
    /// - Parameter hz: this is the frequency with which to initiate a host anchor request.  Cloud anchors uses about 30 seconds of data (as specified in Google's own documentation)
    private func startRecordingCloudAnchors(withFrequency hz: Double) {
        cloudAnchorTimer = Timer.scheduledTimer(withTimeInterval: 1/hz, repeats: true) { timer in
            guard let geospatialTransform = PositioningModel.shared.cameraGeoSpatialTransform else {
                return
            }
            // NOTE: the geospatial transform is not buffered in the same way as the pose
            let _ = PositioningModel.shared.createCloudAnchorFromBufferedPose(
                withMetadata: CloudAnchorMetadata(name: "", type: .path, associatedOutdoorFeature: "", geospatialTransform: GeospatialData(arCoreGeospatial: geospatialTransform), creatorUID: AuthHandler.shared.currentUID ?? "", isReadable: true)
            ) { wasSuccessful in
                // TODO: handle this somehow
            }
        }
    }
    
    /// Add the specified cloud anchor to the path recording
    /// - Parameters:
    ///   - identifier: the cloud identifier (returned from ARCore)
    ///   - metadata: the metadata describing the cloud anchor
    ///   - currentPose: the pose of the cloud anchor as specified in the corresponding `GARAnchor`
    func addCloudAnchor(identifier: String, metadata: CloudAnchorMetadata, currentPose: simd_float4x4) {
        cloudAnchors[identifier] = (metadata, currentPose)
    }
    
    /// Stop recording the path.
    func stopRecordingPath() {
        recordingTimer?.invalidate()
        cloudAnchorTimer?.invalidate()
    }
    
    func manyAnchorstoFirebase(){
        firebaseRef = Database.database(url: "https://stepnavigation-default-rtdb.firebaseio.com").reference()
        firebaseStorage = Storage.storage()
        firebaseStorageRef = firebaseStorage.reference()
        
        let mapId = UUID().uuidString
        let filePath = "testing/\(mapId)"
        
        let newCrumbs = PathRecorder.shared.breadCrumbs.map({ $0.pose.toColumnMajor() }).reduce(into: []) { partialResult, newPose in
            partialResult += newPose
        }
        
        var finalAnchors: [String: (CloudAnchorMetadata, simd_float4x4)] = [:]
        
        for (cloudIdentifier, anchorInfo) in cloudAnchors {
            if anchorInfo.0.type == .path {
                finalAnchors[cloudIdentifier] = anchorInfo
            } else {
                guard let currentPose = PositioningModel.shared.currentLocation(ofCloudAnchor: cloudIdentifier) else {
                    continue
                }
                finalAnchors[cloudIdentifier] = (anchorInfo.0, currentPose)
            }
        }
        
        let formattedPathAnchors = finalAnchors.map{
            [
                "timestamp": 0,
                "cloudIdentifier": $0.0,
                "pose": $0.1.1.toColumnMajor(),
                "poseId": 0
            ]
        }
        
        let formattedPoses = PathRecorder.shared.breadCrumbs.enumerated().map{
            [
                "pose": $1.pose.toColumnMajor(),
                "timestamp": $1.timestamp,
                "id": $0,
                "planes": [:] as [String:Any]
            ] as [String: Any]
        }
        
        let mapJsonFile: [String: Any] = ["tag_data": [], "map_id": mapId, "pose_data": formattedPoses, "cloud_data": formattedPathAnchors, "location_data": [], "plane_data": []]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: mapJsonFile, options: []) {
            firebaseStorageRef.child(filePath).putData(jsonData, metadata: StorageMetadata(dictionary: ["contentType": "application/json"])){ (metadata, error) in
                // Write to unprocessed maps node in database
                firebaseRef.child("unprocessed_maps").child(String(describing: Auth.auth().currentUser!.uid)).child(mapId).setValue(filePath)
            }
            let db = Firestore.firestore()
            
            let connectionCollection: CollectionReference = db.collection("JSON MAPPING")
            let ref = connectionCollection.document(mapId)
            
            ref.setData([
                "pathId" : "testing/\(mapId).json"
            ]) { error in
                print("error: \(error?.localizedDescription ?? "none")")
            }
        }
    }
    
    
    
    /// Upload the path data to Firebase
    func toFirebase(){
        guard let startAnchorID = startAnchorID, let stopAnchorID = stopAnchorID, let anchor1Pose = PositioningModel.shared.currentLocation(ofCloudAnchor: startAnchorID), let anchor2Pose = PositioningModel.shared.currentLocation(ofCloudAnchor: stopAnchorID) else {
            return
        }
        
        firebaseRef = Database.database(url: "https://stepnavigation-default-rtdb.firebaseio.com").reference()
        firebaseStorage = Storage.storage()
        firebaseStorageRef = firebaseStorage.reference()
        
        let mapId = UUID().uuidString
        
        var finalAnchors: [String: (CloudAnchorMetadata, simd_float4x4)] = [:]
        
        for (cloudIdentifier, anchorInfo) in cloudAnchors {
            if anchorInfo.0.type == .path {     // Note: the path anchors are not currently resolved, so they don't move around.  We should add them anyway
                finalAnchors[cloudIdentifier] = anchorInfo
            } else {
                guard let currentPose = PositioningModel.shared.currentLocation(ofCloudAnchor: cloudIdentifier) else {
                    continue
                }
                finalAnchors[cloudIdentifier] = (anchorInfo.0, currentPose)
            }
        }
    
        FirebaseManager.shared.addConnection(
            anchorID1: startAnchorID,
            anchor1Pose: anchor1Pose,
            anchorID2: stopAnchorID,
            anchor2Pose: anchor2Pose,
            breadCrumbs: PathRecorder.shared.breadCrumbs,
            pathAnchors: finalAnchors)
    }
    
}

