//
//  PathRecorder.swift
//  InvisibleMapTake2
//
//  Created by Paul Ruvolo on 4/4/23.
//

import Foundation
import ARKit
import ARCoreGeospatial

struct Breadcrumb {
    var pose: simd_float4x4
    var leftWall: Bool
    var rightWall: Bool
    
    
    func toDictionary() -> [String: Any] {
        return [
            "pose": pose.toColumnMajor(),
            "leftWall": leftWall,
            "rightWall": rightWall
        ]
    }
}

class PathRecorder {
    public static var shared = PathRecorder()
    var breadCrumbs: [simd_float4x4] = []
    var cloudAnchors: [String: (CloudAnchorMetadata, simd_float4x4)] = [:]
    var recordingTimer: Timer?
    var cloudAnchorTimer: Timer?
    var qualityTimer: Timer?
    var startAnchorID: String?
    var stopAnchorID: String?
    var leftWallEnabled: Bool?;
    var rightWallEnabled: Bool?;

    private init() {
    }
    
    func updateLeftWallEnabled(_ isEnabled: Bool) {
        leftWallEnabled = isEnabled
    }
    
    func updateRightWallEnabled(_ isEnabled: Bool) {
        rightWallEnabled = isEnabled
    }
    
    func startRecordingPath(withFrequency hz: Double) {
        breadCrumbs = []
        cloudAnchors = [:]
        // just in case
        print("RESETTING")
        recordingTimer?.invalidate()
        cloudAnchorTimer?.invalidate()

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1/hz, repeats: true) { timer in
            guard let currentPose = PositioningModel.shared.cameraTransform else {
                return
            }

            print("left \(self.leftWallEnabled ?? false)")
            print("right \(self.rightWallEnabled ?? false)")

            // removing this for now
            let breadcrumb = Breadcrumb(pose: currentPose, leftWall: self.leftWallEnabled ?? false, rightWall: self.rightWallEnabled ?? false)
            self.breadCrumbs.append(currentPose)
        }
    }

    func startRecordingCloudAnchors(withFrequency hz: Double) {
        qualityTimer = Timer.scheduledTimer(withTimeInterval: 1.0,
                                            repeats: true) { timer in
            // use current transform?
            guard let currentPose = PositioningModel.shared.cameraTransform else {
                return
            }
            PositioningModel.shared.estimateFeatureMapQualityForHosting(pose: currentPose)
        }
        cloudAnchorTimer = Timer.scheduledTimer(withTimeInterval: 1/hz, repeats: true) { timer in
            guard let geospatialTransform = PositioningModel.shared.cameraGeoSpatialTransform else {
                return
            }
            // NOTE: the geospatial transform is not buffered in the same way as the pose
            let _ = PositioningModel.shared.createCloudAnchorFromBufferedPose(withMetadata: CloudAnchorMetadata(name: "", type: .path, associatedOutdoorFeature: "", geospatialTransform: GeospatialData(arCoreGeospatial: geospatialTransform)))
        }
    }
    
    func addCloudAnchor(identifier: String, metadata: CloudAnchorMetadata, currentPose: simd_float4x4) {
        cloudAnchors[identifier] = (metadata, currentPose)
    }
    
    func stopRecordingPath() {
        recordingTimer?.invalidate()
        cloudAnchorTimer?.invalidate()
        qualityTimer?.invalidate()
    }
    
    func toFirebase() {
        guard let startAnchorID = startAnchorID, let stopAnchorID = stopAnchorID, let anchor1Pose = PositioningModel.shared.currentLocation(ofCloudAnchor: startAnchorID), let anchor2Pose = PositioningModel.shared.currentLocation(ofCloudAnchor: stopAnchorID) else {
            return
        }
        var finalAnchors: [String: (CloudAnchorMetadata, simd_float4x4)] = [:]
        for (cloudIdentifier, anchorInfo) in cloudAnchors {
            guard let currentPose = PositioningModel.shared.currentLocation(ofCloudAnchor: cloudIdentifier) else {
                continue
            }
            finalAnchors[cloudIdentifier] = (anchorInfo.0, currentPose)
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
