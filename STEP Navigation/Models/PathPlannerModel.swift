//
//  PathPlannerModel.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import ARCoreGeospatial

class PathPlannerModel {

    /// Calculates the straight line distance in meters between the current position and the next node.
    func calculateStraightDistance(cameraTransform: simd_float4x4, nextNodeTransform: simd_float4x4)->Float {
       return simd_distance(nextNodeTransform.columns.3, cameraTransform.columns.3) // Straight line distance in meters.
    }
    
    /// Calculates the angle difference in degrees between the current direction and the direction to the next node.
    func calculateAngleDifference(cameraTransform: simd_float4x4, nextNodeTransform: simd_float4x4)->Float {
        // Direction we are currently facing.
        let headingVec = simd_normalize(simd_float3(-cameraTransform.columns.2.x, 0.0, -cameraTransform.columns.2.z))
        
        // Direction we want to go.
        let pointingVector = simd_normalize(
            simd_float3(nextNodeTransform.columns.3.x - cameraTransform.columns.3.x, 0.0, nextNodeTransform.columns.3.z - cameraTransform.columns.3.z)
        )
        // Calculate angle between 2 vectors.
        let q = simd_quaternion(headingVec, pointingVector)
        return q.angle * sign(q.axis.y)
    }
    
    /// Updates the instance attributes with the given ARFrame and SCNNode, and calculates the straight line distance and the angle difference.
    ///
    /// - parameter frame: The new ARFrame.
    /// - parameter nextNode: The next node in the path.
    ///
    /// - returns: The straight line distance and angle differene to the node.
    func getDirections(cameraTransform: simd_float4x4, nextNodeTransform: simd_float4x4) -> (Float, Float) {
        let straightDistance = calculateStraightDistance(cameraTransform: cameraTransform, nextNodeTransform: nextNodeTransform)
        let angleDiff = calculateAngleDifference(cameraTransform: cameraTransform, nextNodeTransform: nextNodeTransform)
        return (straightDistance, angleDiff)
    }
    
}
