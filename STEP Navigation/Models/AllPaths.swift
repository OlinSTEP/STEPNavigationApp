//
//  AllPaths.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import ARCore

enum NavigationType {
    case none
    case asTheCrowFlies
    case route
}

class PathPlanner {
    public static var shared = PathPlanner()
    private var crowFliesGoal: GARAnchor?
    private var navigationType: NavigationType = .none
    private var cloudAnchors: [String] = []
    
    private init() {
        
    }
    
    func navigate(to anchor: LocationDataModel) {
        navigationType = .asTheCrowFlies
        crowFliesGoal = PositioningModel.shared.addTerrainAnchor(at: anchor.getLocationCoordinate(), withName: anchor.getName())
    }
    
    func prepareToNavigate(to destination: LocationDataModel) {
        PositioningModel.shared.addTerrainAnchor(at: destination.getLocationCoordinate(), withName: "destination")
    }
    
    func prepareToNavigate(from start: LocationDataModel, to end: LocationDataModel) {
        guard let cloudAnchorID1 = start.getCloudAnchorID(), let cloudAnchorID2 = end.getCloudAnchorID() else {
            // Note: this shouldn't happen
            return
        }
        PathLogger.shared.startLoggingData()
        cloudAnchors = NavigationManager.shared.computePathBetween(cloudAnchorID1, cloudAnchorID2)
        NavigationManager.shared.computeMultisegmentPath(cloudAnchors)
    }
    
    func navigate(from start: LocationDataModel, to end: LocationDataModel) {
        NavigationManager.shared.startNavigating()
    }
    
    func getGoalForAsTheCrowFlies()->GARAnchor? {
        if navigationType == .asTheCrowFlies {
            return crowFliesGoal
        }
        return nil
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
        guard let nextKeypointPosition = keypoints.first?.currentTransform.translation else {
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
