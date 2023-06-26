//
//  PathFinder.swift
//  ARKitTest
//
//  Created by Chris Seonghwan Yoon & Jeremy Ryan on 7/11/17.
//
// Pathfinder class calculates turns or "keypoints" given a path array of LocationInfo
//
import Foundation
import ARKit

/// The keypoint type
enum KeypointType {
    /// A latLonBased keypoint is positioned using the ARCoreGeospatial API.
    case latLonBased
    /// A cloud anchor based keypoint is based on the location of the associated cloud anchors as tracked by the ARCoreCloudAnchor API.  The keypoint itself does not correspond to a cloud anchor, but its positioned relative to cloud anchor is known.
    case cloudAnchorBased
}

/// Struct to store position and orientation of a keypoint
public struct AnchorPointInfo: Identifiable {
    /// The unique identifier of the keypoint
    public let id: UUID
    ///name of the cloud anchor
    let CloudAnchorName : String
    let CloudAnchorID : String
    /// the type of keypoint (either latitude longitude based or cloud anchor based)
    let mode: KeypointType
    /// AR alignment
//    let alignment: simd_float4x4?
    /// the location of the keypoint
    public var location: simd_float4x4
    ///
    var currentTransform: simd_float4x4? {
        return PositioningModel.shared.currentLocation(ofCloudAnchor: CloudAnchorID)
    }
}


/// Struct to store position and orientation of a keypoint
public struct KeypointInfo: Identifiable {
    /// The unique identifier of the keypoint
    public let id: UUID
    /// the type of keypoint (either latitude longitude based or cloud anchor based)
    let mode: KeypointType
    /// the location of the keypoint
    public var location: simd_float4x4
    /// the orientation of a keypoint is a unit vector that points from the previous keypoint to current keypoint.  The orientation is useful for defining the area where we check off the user as having reached a keypoint
    public var orientation: simd_float3 {
        if let previousKeypoint = RouteNavigator.shared.getPreviousKeypoint(to: self),
           let currentKeypointLocation = PositioningModel.shared.currentLocation(of: self),
           let prevKeypointLocation = PositioningModel.shared.currentLocation(of: previousKeypoint) {
            return simd_normalize(simd_float3(prevKeypointLocation.translation.x - currentKeypointLocation.translation.x,
                                              0,
                                              prevKeypointLocation.translation.z - currentKeypointLocation.translation.z))
        } else {
            return simd_float3(1.0, 0.0, 0.0)
        }
    }
    
    var currentTransform: simd_float4x4? {
        return PositioningModel.shared.currentLocation(of: self)
    }
}

/// Pathfinder class calculates turns or "keypoints" given a path array of LocationInfo
class MultiSegmentPathBuilder {
    
    ///  Maximum width of the breadcrumb path in meters.
    ///
    /// Points falling outside this margin will produce more keypoints, through Ramer-Douglas-Peucker algorithm
    private var pathWidth: Float!
    
    /// The crumbs that make up the desired path. These should be ordered with respect to the user's intended direction of travel (start to end versus end to start)
    private var crumbs: [simd_float4x4]
    
    /// These indices specify which crumbs shoudl be used as keypoints
    private var manualKeypointIndices: [Int]
    
    /// Initializes the PathFinder class and determines the value of `pathWidth`
    ///
    /// - Parameters:
    ///   - crumbs: a list of `LocationInfo` objects representing the trail of breadcrumbs left on the path
    ///   - manualKeypointIndices: if non-empty, use these indices to ocnstruct the keypoints.
    /// - Returns: the list of route keypoints
    init(crumbs: [simd_float4x4], manualKeypointIndices: [Int]) {
        self.crumbs = crumbs
        self.manualKeypointIndices = manualKeypointIndices
        pathWidth = 0.3
    }
    
    /// a list of ``KeypointInfo`` objects representing the important turns in the path.
    public var keypoints: [KeypointInfo] {
        get {
            if manualKeypointIndices.count != 0 {
                pathWidth = 0.0001
                var newCrumbs : [simd_float4x4] = []
                for index in manualKeypointIndices {
                    newCrumbs.append(crumbs[index])
                }
                crumbs = newCrumbs
            }
            let kp = getKeypoints(edibleCrumbs: crumbs)
            return kp
        }
    }
    
    /// Creates a list of keypoints in a path given a list of points dropped several times per second.
    ///
    /// - Parameter edibleCrumbs: a list of `LocationInfo` objects representing the trail of breadcrumbs left on the path.
    /// - Returns: a list of `KeypointInfo` objects representing the turns in the path
    func getKeypoints(edibleCrumbs: [simd_float4x4]) -> [KeypointInfo] {
        let firstKeypointLocation = edibleCrumbs.first!
        if edibleCrumbs.count == 1 {
            return [KeypointInfo(id: UUID(), mode: .cloudAnchorBased, location: firstKeypointLocation)]
        }
        var keypoints = [KeypointInfo]()
        keypoints.append(KeypointInfo(id: UUID(), mode: .cloudAnchorBased, location: firstKeypointLocation))
//        print(keypoints)
        keypoints += calculateKeypoints(edibleCrumbs: edibleCrumbs)
        
        let lastKeypointLocation = edibleCrumbs.last!
        keypoints.append(KeypointInfo(id: UUID(), mode: .cloudAnchorBased, location: lastKeypointLocation))
        return keypoints
    }
    
    /// Recursively simplifies a path of points using Ramer-Douglas-Peucker algorithm.
    ///
    /// - Parameter edibleCrumbs: a list of `LocationInfo` objects representing the trail of breadcrumbs left on the path.
    /// - Returns: a list of `KeypointInfo` objects representing the important turns in the path.
    func calculateKeypoints(edibleCrumbs: [simd_float4x4]) -> [KeypointInfo] {
        var keypoints = [KeypointInfo]()
        
        let firstCrumb = edibleCrumbs.first!
        let lastCrumb = edibleCrumbs.last!
        
        //  Direction vector of last crumb in list relative to first
        let pointVector = simd_float3(lastCrumb.translation.x - firstCrumb.translation.x,
                                      lastCrumb.translation.y - firstCrumb.translation.y,
                                      lastCrumb.translation.z - firstCrumb.translation.z)
        
        //  Vector normal to pointVector, rotated 90 degrees about vertical axis
        let normalVector = simd_float3x3(simd_float3(0.0, 0.0, -1.0),
                                         simd_float3(0.0, 0.0, 0.0),
                                         simd_float3(1.0, 0.0, 0.0)) * pointVector
        
        let unitNormalVector = simd_normalize(normalVector)
        let unitPointVector = simd_normalize(pointVector)
        
        //  Third orthonormal vector to normalVector and pointVector, used to detect
        //  vertical changes like stairways
        let unitNormalVector2 = simd_cross(unitPointVector, unitNormalVector)
        
        var listOfDistances: [Float] = []
        //  Find maximum distance from the path trajectory among all points
        for crumb in edibleCrumbs {
            let c = simd_float3(crumb.translation.x - firstCrumb.translation.x,
                                crumb.translation.y - firstCrumb.translation.y,
                                crumb.translation.z - firstCrumb.translation.z)
            let a = simd_dot(c, unitNormalVector2)
            let b = simd_dot(c, unitNormalVector)
            listOfDistances.append(sqrtf(powf(a, 2) + powf(b, 2)))
        }
        
        let maxDistance = listOfDistances.max()
        let maxIndex = listOfDistances.firstIndex(of: maxDistance!)
        
        //  If a point is farther from path center than parameter pathWidth,
        //  there must be another keypoint within that stretch.
        if (maxDistance! > pathWidth) {
            
            //  Recursively find all keypoints before the detected keypoint and
            //  after the detected keypoint, and add them in a list with the
            //  detected keypoint.
            let prevKeypoints = calculateKeypoints(edibleCrumbs: Array(edibleCrumbs[0..<(maxIndex!+1)]))
            let postKeypoints = calculateKeypoints(edibleCrumbs: Array(edibleCrumbs[maxIndex!...]))
            
            if (!prevKeypoints.isEmpty) {
                keypoints += prevKeypoints
            }
                        
            let newKeypointLocation = edibleCrumbs[maxIndex!]
            keypoints.append(KeypointInfo(id: UUID(), mode: .cloudAnchorBased, location: newKeypointLocation))
            
            if (!postKeypoints.isEmpty) {
                keypoints += postKeypoints
            }
        }
        return keypoints
    }
}
