//
//  PathLogger.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/11/23.
//

import Foundation
import ARKit

struct LoggedCloudAnchorResolution {
    let cloudID: String
    let sessionID: String
    let pose: simd_float4x4
    let mapPose: simd_float4x4
    let timestamp: Double
    
    func asDict()->[String: Any] {
        return ["cloudID": cloudID,
                "sessionID": sessionID,
                "pose": pose.toColumnMajor(),
                "mapPose": mapPose.toColumnMajor(),
                "timestamp": timestamp]
    }
}

class PathLogger {
    public static var shared = PathLogger()
    private init() {
        
    }
    var cloudAnchorResolutions: [LoggedCloudAnchorResolution] = []
    var cloudAnchorLandmarks: [String: simd_float4x4]?
    var poseLog: [simd_float4x4] = []
    
    func uploadLog() {
        let data = try! JSONSerialization.data(withJSONObject:
                    ["poses": poseLog.map({ $0.toColumnMajor() }),
                     "cloudAnchorResolutions": cloudAnchorResolutions.map({$0.asDict()}),
                     "cloudAnchorLandmarks": Array((cloudAnchorLandmarks ?? [:]).keys)
                    ]
                   )
        FirebaseManager.shared.uploadLog(data: data)
        reset()
    }
    
    func reset() {
        poseLog = []
        cloudAnchorResolutions = []
    }
    
    func logPose(_ pose: simd_float4x4, timestamp: Double) {
        poseLog.append(pose)
    }
    
    func logCloudAnchorDidUpdate(cloudID: String, identifier: String, pose: simd_float4x4, mapPose: simd_float4x4, timestamp: Double) {
        cloudAnchorResolutions.append(LoggedCloudAnchorResolution(cloudID: cloudID, sessionID: identifier, pose: pose, mapPose: mapPose, timestamp: timestamp))
    }
}
