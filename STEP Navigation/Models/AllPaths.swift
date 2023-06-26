//
//  AllPaths.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import ARKit
import ARCore

/// A class used to plan both single and multisegment paths
class PathPlanner {
    /// The handle to the shared singleton instance of the class
    public static var shared = PathPlanner()
    /// The cloud anchor identifiers of the anchors along this path
    private var cloudAnchors: [String] = []
    
    /// The private initializer (shouldn't be called directly)
    private init() {
        
    }
    
    /// Prepare to navigate between two locations.
    /// - Parameters:
    ///   - start: the start location
    ///   - end: the end location
    ///   - completionHandler: a completion handler that will be called to indicate whether the navigation preparation was successful.  The completion handler is necessary as fetching the full paths from the database is an asynchronous operation.
    func prepareToNavigate(from start: LocationDataModel, to end: LocationDataModel, completionHandler: @escaping (Bool)->()) {
        guard let cloudAnchorID1 = start.getCloudAnchorID(), let cloudAnchorID2 = end.getCloudAnchorID() else {
            // Note: this shouldn't happen
            return completionHandler(false)
        }
        PathLogger.shared.startLoggingData()
        cloudAnchors = NavigationManager.shared.computePathBetween(cloudAnchorID1, cloudAnchorID2)
        NavigationManager.shared.computeMultisegmentPath(cloudAnchors, outsideStart: nil) { wasSuccessful in
            completionHandler(wasSuccessful)
        }
    }
    
    /// Start the process of navigating from an outdoor location to a specified indoor location.
    /// - Parameter end: the indoor location to navigate to
    func startNavigatingFromOutdoors(to end: LocationDataModel) {
        guard let cloudAnchorID = end.getCloudAnchorID() else {
            NavigationManager.shared.computePathToOutdoorMarker(end) {
                PathLogger.shared.startLoggingData()
                NavigationManager.shared.startNavigating()
            }
            return
        }
        cloudAnchors = NavigationManager.shared.computePathBetween("outdoors", cloudAnchorID)
        // we should have at least 2 nodes in this path (the first is the special node "outdoors" and
        // the second is the first cloud anchor
        guard cloudAnchors.count >= 2 else {
            return
        }
        let firstCloudAnchor = cloudAnchors[1]
        for model in DataModelManager.shared.getAllIndoorLocationModels() {
            if model.getCloudAnchorID() == firstCloudAnchor,
               let outdoorFeature = model.getAssociatedOutdoorFeature(),
               let outdoorDataModel = DataModelManager.shared.getLocationDataModel(byID: outdoorFeature) {
                NavigationManager.shared.computeMultisegmentPath(cloudAnchors, outsideStart: outdoorDataModel.getLocationCoordinate()) { wasSuccessful in
                    guard wasSuccessful else {
                        return
                    }
                    PathLogger.shared.startLoggingData()
                    NavigationManager.shared.startNavigating()
                }
                return
            }
        }
        fatalError("Unexpectedly unable to plan path")
    }
}


/// This class builds in support for managing the list of keypoints (intermediate destinations along the route)
class RouteNavigator: ObservableObject {
    /// list of keypoints calculated after path completion.  These keypoints are updated as they are checked off.
    @Published var keypoints: [KeypointInfo]?
    /// anchor  points
    @Published var anchorpoints: [AnchorPointInfo]?
    /// keep a list of the keypoints from the original route since the keypoints array is cleared as the user traverses the route (TODO: use an index instead of deleting)
    var originalKeypoints: [KeypointInfo]?
    /// The name of this particular route navigation (used for determining the filename of the log data)
    var routeNameForLogging: String?
    /// The shared handle to the singleton instance of this class
    static var shared = RouteNavigator()
    
    /// The private initializer (should not be called directly)
    private init() {
    }
    
    /// Compute the distance remaining in the route.  The distance is the as the crow flies distance to the next keypoint and the remaining path semgnets.
    /// - Returns: the remaining route distance (in meters)
    func getRemainingRouteDistance()->Float {
        guard let keypoints = keypoints else {
            return 0.0
        }
        guard let currentPosition = PositioningModel.shared.cameraTransform?.translation else {
            return 0.0
        }
        guard let nextKeypointPosition = keypoints.first?.currentTransform?.translation else {
            return 0.0
        }
        var totalDistance: Float = simd_distance(currentPosition, nextKeypointPosition)
        for (kp_i, kp_iplus1) in zip(keypoints[0..<keypoints.count-1], keypoints[1...]) {
            totalDistance += simd_distance(kp_i.location.translation, kp_iplus1.location.translation)
        }
        return totalDistance
    }
    
    /// Sets the route keypoints
    /// - Parameter kps: a list of keypoints along the route
    func setRouteKeypoints(kps: [KeypointInfo]) {
        originalKeypoints = kps
        keypoints = kps
    }
    
    /// The next keypoint (this changes as keypoints are checked off).  If none exists, the value is nil.
    var nextKeypoint: KeypointInfo? {
        return keypoints?.first
    }
    
//    var AnchorPoint: AnchorPointInfo? {
//        return anchorpoints?.first
//    }
    
    
    /// The keypoint after the next one (this changes as keypoints are checked off).  If none exists, the value is nil.
    var nextNextKeypoint: KeypointInfo? {
        if let keypoints = keypoints, keypoints.count > 1 {
            return keypoints[1]
        } else {
            return nil
        }
    }
    
    /// Checks to see if the specified keypoint has been checked off
    /// - Parameter keypoint: the keypoint to search for
    /// - Returns: true if the keypoint has been checked off (or was never present), and false otherwise.
    func isCheckedOff(_ keypoint: KeypointInfo)->Bool {
        for otherKeypoint in keypoints ?? [] {
            if keypoint.id == otherKeypoint.id {
                return false
            }
        }
        return true
    }
    
    /// Check off the next keypoint on the list
    func checkOffKeypoint() {
        guard let originalKeypoints = originalKeypoints else {
            keypoints?.remove(at: 0)
            return
        }
        // TODO: this is super weird. I (Paul) don't know what is going on with this code.
        for keypoint in originalKeypoints {
            if keypoints?.first!.id == keypoint.id {
                break
            }
        }
        keypoints?.remove(at: 0)
    }
    
    /// Return the keypoint previous to the specified keypoint
    /// - Parameter to: the keypoint to use as a reference for calculating the previous keypoint
    /// - Returns: the keypoint before the specified one or nil if none exists
    func getPreviousKeypoint(to: KeypointInfo)->KeypointInfo? {
        guard let originalKeypoints = originalKeypoints else {
            return nil
        }
        for (pKp, nKp) in zip(originalKeypoints[..<(originalKeypoints.count-1)], originalKeypoints[1...]) {
            if to.id == nKp.id {
                return pKp
            }
        }
        return nil
    }
    
    /// True if and only if we are on the last keypoint
    var onLastKeypoint: Bool {
        return keypoints?.count == 1
    }
    
    /// True if and only if we are on the first keypoint
    var onFirstKeypoint: Bool {
        return keypoints?.count == originalKeypoints?.count
    }
    
    /// True if and only if the all keypoints have been checked off
    var isComplete: Bool {
        return keypoints?.isEmpty == true
    }
    
    /// The last keypoint (based on the original keypoint list)
    var lastKeypoint: KeypointInfo? {
        return originalKeypoints?.last
    }
}
