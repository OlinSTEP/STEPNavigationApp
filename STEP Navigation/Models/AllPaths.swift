//
//  AllPaths.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import ARKit
import ARCore

class PathPlanner {
    public static var shared = PathPlanner()
    private var cloudAnchors: [String] = []
    
    private init() {
        
    }
    
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
    
    func startNavigatingFromOutdoors(to end: LocationDataModel) {
        guard let cloudAnchorID = end.getCloudAnchorID() else {
            NavigationManager.shared.computePathToOutdoorMarker(end)
            PathLogger.shared.startLoggingData()
            NavigationManager.shared.startNavigating()
            return
        }
        cloudAnchors = NavigationManager.shared.computePathBetween("outdoors", cloudAnchorID)
        // we should have at least 2 nodes in this path (the first is the special node "outdoors" and
        // the second is the first cloud anchor
        guard cloudAnchors.count >= 2 else {
            return
        }
        let firstCloudAnchor = cloudAnchors[1]
        for model in DataModelManager.shared.getIndoorLocations() {
            if model.getCloudAnchorID() == firstCloudAnchor,
               let outdoorFeature = model.getAssociatedOutdoorFeature(),
               let outdoorDataModel = DataModelManager.shared.getLocationDataModel(byName: outdoorFeature) {
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
    
    func navigate(from start: LocationDataModel, to end: LocationDataModel) {
        NavigationManager.shared.startNavigating()
    }
}


class RouteNavigator: ObservableObject {
    /// list of keypoints calculated after path completion
    @Published var keypoints: [KeypointInfo]?
    /// keep a list of the keypoints from the original route since the keypoints array is cleared as the user traverses the route (TODO: use an index instead of deleting)
    var originalKeypoints: [KeypointInfo]?
    var routeNameForLogging: String?
    static var shared = RouteNavigator()
    
    private init() {
    }
    
    /// Compute the distance remaining in the route.  The distance is the as the crow flies distance to the next keypoint and the remaining path semgnets.
    /// - Returns: the remaining route distance
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
    
    func setRouteKeypoints(kps: [KeypointInfo]) {
        originalKeypoints = kps
        keypoints = kps
    }
    
    var nextKeypoint: KeypointInfo? {
        return keypoints?.first
    }
    
    var nextNextKeypoint: KeypointInfo? {
        if let keypoints = keypoints, keypoints.count > 1 {
            return keypoints[1]
        } else {
            return nil
        }
    }
    
    func isCheckedOff(_ keypoint: KeypointInfo)->Bool {
        for otherKeypoint in keypoints ?? [] {
            if keypoint.id == otherKeypoint.id {
                return false
            }
        }
        return true
    }
    
    func checkOffKeypoint() {
        guard let originalKeypoints = originalKeypoints else {
            keypoints?.remove(at: 0)
            return
        }
        for keypoint in originalKeypoints {
            if keypoints?.first!.id == keypoint.id {
                break
            }
        }
        keypoints?.remove(at: 0)
    }
    
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
    
    var onLastKeypoint: Bool {
        return keypoints?.count == 1
    }
    
    var onFirstKeypoint: Bool {
        return keypoints?.count == originalKeypoints?.count
    }
    
    var isComplete: Bool {
        return keypoints?.isEmpty == true
    }
    
    var lastKeypoint: KeypointInfo? {
        return originalKeypoints?.last
    }
}
