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
    
    private init() {
        
    }
    
    func navigate(to anchor: LocationDataModel) {
        navigationType = .asTheCrowFlies
        crowFliesGoal = PositioningModel.shared.addTerrainAnchor(at: anchor.getLocationCoordinate(), withName: anchor.getName())
        print("test")
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
            // TODO: does thsi actually work
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
