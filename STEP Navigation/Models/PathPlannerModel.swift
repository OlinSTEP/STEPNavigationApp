//
//  PathPlannerModel.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

// TODO which of these imports is actually needed?
import Foundation
import ARKit
import ARCore
import ARCoreCloudAnchors
import ARCoreGeospatial

class PathFinderModel {
    /// The current ARFrame.
    private var frame: ARFrame?
    
    /// The next node in the path (where we want to go).
    private var nextNode: SCNNode?
    
    /// The straight line distance to the next node in meters.
    private var straightDistance: Float?
    
    /// The angle difference between the current direction and the direction to the next node in degrees.
    private var angleDifference: Float?
    
    /// Initializes a new instance of the PathFinderModel with the given ARFrame and SCNNode.
    ///
    /// - parameter frame: The current ARFrame.
    /// - parameter nextNode: The next node in the path.
    init(frame: ARFrame, nextNode: SCNNode) {
        self.frame = frame
        self.nextNode = nextNode
    }
    
    /// Calculates the straight line distance in meters between the current position and the next node.
    func calculateStraightDistance() {
        if let nextNode = self.nextNode, let frame = self.frame {
            self.straightDistance = simd_distance(nextNode.simdTransform.columns.3, frame.camera.transform.columns.3) // Straight line distance in meters.
        }
    }
    
    /// Calculates the angle difference in degrees between the current direction and the direction to the next node.
    func calculateAngleDifference() {
        if let nextNode = self.nextNode, let frame = self.frame {
            
            // Direction we are currently facing.
            let headingVec = simd_normalize(simd_float3(-frame.camera.transform.columns.2.x, 0.0, -frame.camera.transform.columns.2.z))
            
            // Direction we want to go.
            let pointingVector = simd_float3(nextNode.simdTransform.columns.3.x - frame.camera.transform.columns.3.x,
                                             0.0,
                                             nextNode.simdTransform.columns.3.z - frame.camera.transform.columns.3.z)
            
            // Calculate angle between 2 vectors.
            let q = simd_quaternion(headingVec, pointingVector)
            self.angleDifference = q.angle * sign(q.axis.y)
        }
       
    }
    
    /// Updates the instance attributes with the given ARFrame and SCNNode, and calculates the straight line distance and the angle difference.
    ///
    /// - parameter frame: The new ARFrame.
    /// - parameter nextNode: The next node in the path.
    ///
    /// - returns: The straight line distance and angle differene to the node.
    func getDirections(frame: ARFrame, nextNode: SCNNode) -> (Float?, Float?){
        // Update instance attributes.
        self.frame = frame
        self.nextNode = nextNode
        
        self.calculateStraightDistance()
        self.calculateAngleDifference()
        
        return (self.straightDistance, self.angleDifference)
    }
    
}
