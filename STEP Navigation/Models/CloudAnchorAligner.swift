//
//  CloudAnchorAligner.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/14/23.
//

import Foundation
import ARKit

/// This class implements a basic approach to aligning an `ARSession` to a specified map.  The basic approach is to use a voting scheme where cloud anchors each vote for a transform that will align the two spaces in questions (route space and session space).  In the case of a tie, primacy is given to the transform that agrees as much as possible with the current transform estimate.
class CloudAnchorAligner {
    /// These are the cloud anchor identifiers (keys) and expected positions in map space (values)
    var cloudAnchorLandmarks: [String: simd_float4x4]? {
        didSet {
            PathLogger.shared.cloudAnchorLandmarks = cloudAnchorLandmarks
        }
    }
    /// These are the cloud anchors that have been resolved (the cloud identifiers are the keys) and the specific details of their resolutions are the values.
    var resolvedCloudAnchors: [String: [CloudAnchorResolutionInfomation] ] = [:]
    
    /// Reset the aligner
    func reset() {
        resolvedCloudAnchors = [:]
    }
    
    /// This function should be called everytime a cloud anchor resolves or its pose updates
    /// - Parameters:
    ///   - cloudID: the cloud identifier in question
    ///   - identifier: the `GARAnchor` identfier
    ///   - pose: the new pose of the cloud anchor
    ///   - timestamp: the timeestamp (typically in the `ARSession` clock)
    func cloudAnchorDidUpdate(withCloudID cloudID: String, withIdentifier identifier: String, withPose pose: simd_float4x4, timestamp: Double) {
        let newInfo = CloudAnchorResolutionInfomation(identifier: cloudID, lastUpdateTime: Date(), pose: pose)
        if let landmark = cloudAnchorLandmarks?[cloudID] {
            PathLogger.shared.logCloudAnchorDidUpdate(cloudID: cloudID, identifier: identifier, pose: pose, mapPose: landmark, timestamp: timestamp)
            print("This is landmark\( landmark)")
        }
        if var resolvedAnchors = resolvedCloudAnchors[cloudID] {
            resolvedAnchors.append(newInfo)
        } else {
            resolvedCloudAnchors[cloudID] = [newInfo]
        }
    }
    
    /// Adjust the alignment based on the current cloud anchor resolution data
    /// - Parameter currentAlignment: the current estimate of the session to map transform
    /// - Returns: the updated session to map transform if one can be computed or nil if none can be computed.
    func adjust(currentAlignment: simd_float4x4?)->simd_float4x4? {
        var proposedAlignments: [String: (Double, simd_float4x4)] = [:]
        for (cloudID, resolutions) in resolvedCloudAnchors {
            // TODO: maybe don't use last? if it jumped around too much?
            guard let lastResolution = resolutions.last, let mapTransform = cloudAnchorLandmarks?[cloudID] else {
                continue
            }
            let anchorTransform = lastResolution.pose
            proposedAlignments[cloudID] = (lastResolution.lastUpdateTime.timeIntervalSince1970, anchorTransform.alignY() * mapTransform.alignY().inverse)
        }
        // for right now we can filter based on
        guard let currentDevicePose = PositioningModel.shared.cameraTransform else {
            return currentAlignment
        }
        // TODO: fix bad O(n^2) algorithm
        var votes: [(Int, Double, simd_float4x4)] = []
        for (_, proposedAlignment) in proposedAlignments {
            var vote = 0
            var inlierPoses: [simd_float4x4] = []
            inlierPoses.append(proposedAlignment.1)
            let projectedPosition = proposedAlignment.1 * currentDevicePose
            var otherAlignments = proposedAlignments
            // add the current alignment (if it exists) to provide a vote for the current alignment
            if let currentAlignment = currentAlignment {
                otherAlignments["current"] = (0.0, currentAlignment)
            }
            for (_, proposedAlignment2) in otherAlignments {
                let projectedPosition2 = proposedAlignment2.1 * currentDevicePose
                if simd_distance(projectedPosition.columns.3,
                                 projectedPosition2.columns.3) < 2.0 {
                    vote += 1
                    inlierPoses.append(proposedAlignment2.1)
                }
            }
            votes.append((vote, proposedAlignment.0, proposedAlignment.1))
            // NOTE: we tried averaging, but this seemed to be a bit worse (see below)
            // votes.append((vote, proposedAlignment.0, average(poses: inlierPoses)!))
        }
        
        // choose the one with the most votes.  If there is a tie, choose the most recent one. If there are no votes, just stick with what we had originally
        return votes.max(by: { $0.0 < $1.0 || ($0.0 == $1.0 && $0.1 < $1.1 ) })?.2 ?? currentAlignment
    }
    
    /// A function for averaging 3D poses.  The poses are assumed to be
    /// - Parameter poses: the 3D poses to average
    /// - Returns: the average if the list is non-empy, or nil otherwise
    private func average(poses: [simd_float4x4])->simd_float4x4? {
        if poses.count == 0 {
            return nil
        }
        let angles = poses.map({pose in atan2(pose.columns.2.x, pose.columns.2.z) })
        let positions = poses.map({pose in pose.translation})
        let positionAverage = positions.reduce(simd_float3(repeating: 0.0), +) / Float(positions.count)
        let cosSum = angles.map({cos($0)}).reduce(0.0, +)
        let sinSum = angles.map({sin($0)}).reduce(0.0, +)
        let averageAngle = atan2(sinSum, cosSum)
        var consensusAlignment = simd_float4x4(simd_quatf(angle: averageAngle, axis: simd_float3(0.0, 1.0, 0.0)))
        consensusAlignment.columns.3 = simd_float4(positionAverage, 1.0)
        
        return consensusAlignment
    }
}
