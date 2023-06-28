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
    var id: Int
}




/// Record breadcrumbs (sequence of poses) along with cloud anchors recorded along the path
class PathRecorder {
    /// The shared singleton instance of this class
    public static var shared = PathRecorder()
    /// The sequence of poses that make up this path
    private (set) var breadCrumbs: [PoseData] = []
    /// The cloud anchors created along this path (the key is the cloud identifier and the value consists of the
    /// cloud anchor metadata and itse pose in the recording session)
//    private (set) var cloudAnchors: [String: (CloudAnchorMetadata, simd_float4x4, Double)] = [:]
    /// dictioanry of cloudAnchor information
    private (set) var cloudAnchors: [[[String:Any]]] = []
    /// A timer used to periodically capture poses
    private var recordingTimer: Timer?
    /// A timer used to periodically host cloud anchors
    private var cloudAnchorTimer: Timer?
    /// The amount of seconds to wait from last resolved anchor before hosting a path anchor
    private var pathAnchorInterval: Double = 25
    /// The cloud identifier of the starting cloud anchor of this path
    var startAnchorID: String?
    /// The cloud identifier of the starting cloud anchor of this path
    var stopAnchorID: String?
    
    
    /// The private initializer (this should not be called directly)
    private init() {
    }
    
    ///Start recording path breadcrumbs and hosting path cloud anchors
    func startRecording(){
        startRecordingPath(withFrequency: 5.0)
        restartPathAnchorTimer()
    }
    
    private func restartPathAnchorTimer () {
        cloudAnchorTimer?.invalidate()
        cloudAnchorTimer = Timer.scheduledTimer(withTimeInterval: pathAnchorInterval, repeats: false){ timer in
            self.recordCloudAnchor()
        }
    }
    
    /// Start recording the path with the specified frequency of pose capture.
    /// - Parameter hz: this is the frquency with which to capture poses to store as breadcrumbs.
    private func startRecordingPath(withFrequency hz: Double) {
        breadCrumbs = []
        cloudAnchors = []
        recordingTimer?.invalidate()
        cloudAnchorTimer?.invalidate()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1/hz, repeats: true) { timer in
            guard let currentPose = PositioningModel.shared.cameraTransform else {
                return
            }
            self.breadCrumbs.append(PoseData(pose: currentPose, timestamp: PositioningModel.shared.arView.session.currentFrame?.timestamp ?? 0.0, id: self.breadCrumbs.count))
        }
    }
    
    /// Host a cloud anchor
    /// - Parameter sec the amount of seconds to wait before initiating another cloud anchor hosting request.  Cloud anchors uses about 30 seconds of data (as specified in Google's own documentation)
    private func recordCloudAnchor() {
        guard let geospatialTransform = PositioningModel.shared.cameraGeoSpatialTransform else {
            return
        }
        // NOTE: the geospatial transform is not buffered in the same way as the pose
        let _ = PositioningModel.shared.createCloudAnchorFromBufferedPose(
            withMetadata: CloudAnchorMetadata(name: "Path Anchor", type: .path, associatedOutdoorFeature: "", geospatialTransform: GeospatialData(arCoreGeospatial: geospatialTransform), creatorUID: AuthHandler.shared.currentUID ?? "", isReadable: true)
        ) { wasSuccessful in
            if !wasSuccessful { // if successful, already handled by addCloudAnchor
                self.restartPathAnchorTimer()
            }
        }
    }
    
    func resolvedAnchor () {
        guard let currentPose = PositioningModel.shared.cameraTransform else {
            return
        }
        self.breadCrumbs.append(PoseData(pose: currentPose, timestamp: PositioningModel.shared.arView.session.currentFrame?.timestamp ?? 0.0, id: self.breadCrumbs.count))
    }
    
    /// Add the specified cloud anchor to the path recording
    /// - Parameters:
    ///   - identifier: the cloud identifier (returned from ARCore)
    ///   - metadata: the metadata describing the cloud anchor
    ///   - currentPose: the pose of the cloud anchor as specified in the corresponding `GARAnchor`
    func addCloudAnchor(identifier: String, metadata: CloudAnchorMetadata, currentPose: simd_float4x4, timestamp: Double) {
        cloudAnchors.append([[
//            "metadata": metadata,
            "timestamp": timestamp,
            "pose": currentPose.toColumnMajor(),
            "poseId":  breadCrumbs.count,
            "cloudIdentifier": identifier
        ]])
        
        // reset timer to wait pathAnchorInterval seconds before hosting anchor
        restartPathAnchorTimer()
    }
    
    /// Stop recording the path.
    func stopRecordingPath() {
        recordingTimer?.invalidate()
        cloudAnchorTimer?.invalidate()
    }
    
    /// Stores the recorded data in firebase storage and the JSON path in realtime database
    func toFirebase(){
        firebaseRef = Database.database(url: "https://stepnavigation-default-rtdb.firebaseio.com").reference()
        firebaseStorage = Storage.storage()
        firebaseStorageRef = firebaseStorage.reference()

        
        let mapId = UUID().uuidString
        let filePath = "testing/\(mapId)"
        
        let newCrumbs = PathRecorder.shared.breadCrumbs.map({ $0.pose.toColumnMajor() }).reduce(into: []) { partialResult, newPose in
            partialResult += newPose
        }

        
        let formattedPoses = PathRecorder.shared.breadCrumbs.enumerated().map{
            [
                "pose": $1.pose.toColumnMajor(),
                "timestamp": $1.timestamp,
                "id": $1.id,
                "planes": []
            ] as [String: Any]
        }

        
        let mapJsonFile: [String: Any] = ["tag_data": [], "map_id": mapId, "pose_data": formattedPoses, "cloud_data": cloudAnchors, "location_data": [], "plane_data": []]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: mapJsonFile, options: []) {
            firebaseStorageRef.child(filePath).putData(jsonData, metadata: StorageMetadata(dictionary: ["contentType": "application/json"])){ (metadata, error) in
                // Write to unprocessed maps node in database
                firebaseRef.child("unprocessed_maps").child(String(describing: Auth.auth().currentUser!.uid)).child(mapId).setValue(filePath)
            }
        }

    }
}

