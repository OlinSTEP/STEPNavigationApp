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

/// A class to handle creating logs and sheherding them to Firebase
class PathLogger {
    /// The shared singleton instance of this class
    public static var shared = PathLogger()
    /// The private initializer (should not be called directly)
    private init() {
        
    }
    /// Stores information about cloud anchors that have been resolved in the session.  The same cloud anchor may appear multiple times if its position is reestimated during the session.
    var cloudAnchorResolutions: [LoggedCloudAnchorResolution] = []
    /// These are the cloud anchors that could be resolved and where we are expecting to find them in route space
    var cloudAnchorLandmarks: [String: simd_float4x4]?
    /// A pose sequence
    var poseLog: [simd_float4x4] = []
    /// The time stamps that correspond to the poses in ``poseLog``
    var poseTimestamps: [Double] = []
    /// A Boolean that gates whether to log data
    private var isLoggingData = false
    /// A Boolean that keeps track of whether the log data has been successfully uploaded to Firebase
    private var hasUploadedData = false
    
    /// Begin logging data.  Before this call, any calls to log data will not result in data being logged
    func startLoggingData() {
        hasUploadedData = false
        isLoggingData = true
    }
    
    /// Stop logging data
    func stopLoggingData() {
        isLoggingData = false
    }
    
    /// Upload the logged data to Firebase.  This function completes asynchronously and currently doesn't provide a completion handler.
    /// - Parameter logFilePath: the path to store the log data
    func uploadLog(logFilePath: String) {
        guard !hasUploadedData else {
            return
        }
        let data = try! JSONSerialization.data(withJSONObject:
                    ["poses": poseLog.map({ $0.toColumnMajor() }),
                     "poseTimestamp": poseTimestamps,
                     "cloudAnchorResolutions": cloudAnchorResolutions.map({$0.asDict()}),
                     "cloudAnchorLandmarks": Array((cloudAnchorLandmarks ?? [:]).keys),
                     "userID": AuthHandler.shared.currentUID ?? ""
                    ] as [String : Any]
                   )
        FirebaseManager.shared.uploadLog(logFilePath: logFilePath, data: data)
        hasUploadedData = true
        reset()
    }
    
    /// Reset the logged data so we don't duplicate it into multiple logs
    func reset() {
        poseLog = []
        poseTimestamps = []
        cloudAnchorResolutions = []
        cloudAnchorLandmarks = [:]
        isLoggingData = false
    }
    
    /// Log the specified pose at the specified timestamp
    /// - Parameters:
    ///   - pose: the device pose specified as a 4x4 matrix
    ///   - timestamp: the timestamp measured with respect to some clock (typically the ARSession's clock)
    func logPose(_ pose: simd_float4x4, timestamp: Double) {
        guard isLoggingData else {
            return
        }
        poseLog.append(pose)
        poseTimestamps.append(timestamp)
    }
    
    /// Log information about a cloud anchor resolution or update
    /// - Parameters:
    ///   - cloudID: the cloud anchor identifier
    ///   - identifier: the identifier of the anchor within the `GARSession`
    ///   - pose: the new pose of the cloud anchor
    ///   - mapPose: the predicted pose of the cloud anchor in map (or route) space
    ///   - timestamp: the timestamp associated with this logging event.
    func logCloudAnchorDidUpdate(cloudID: String, identifier: String, pose: simd_float4x4, mapPose: simd_float4x4, timestamp: Double) {
        guard isLoggingData else {
            return
        }
        cloudAnchorResolutions.append(LoggedCloudAnchorResolution(cloudID: cloudID, sessionID: identifier, pose: pose, mapPose: mapPose, timestamp: timestamp))
    }
}
