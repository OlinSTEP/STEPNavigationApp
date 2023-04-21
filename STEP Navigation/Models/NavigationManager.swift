//
//  NavigationManager.swift
//  InvisibleMapTake2
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation
import SwiftGraph
import ARKit

class NavigationManager: ObservableObject {
    public static var shared = NavigationManager()
    let nav = Navigation()
    /// The time of last sound feedback
    var soundTimer: Date!
    /// The time of last haptic feedback
    var feedbackTimer: Date!
    /// Description the current navigation direction for the user (if one exists)
    @Published var navigationDirection: String?
    /// previous keypoint location - originally set to current location
    var prevKeypointPosition: simd_float4x4!
    
    /// haptic feedback timer
    var hapticTimer: Timer?
    
    /// haptic feedback timer
    var followingCrumbs: Timer?
    
    /// The delay between haptic feedback pulses in seconds
    static let FEEDBACKDELAY = 0.4
    
    private init() {
        
    }
    
    func getReachability(from start: LocationDataModel, outOf pool: [LocationDataModel])->[Bool] {
        guard let cloudID = start.getCloudAnchorID() else {
            return []
        }
        let anchorGraph = makeWeightedGraph()
        let (distances, _) = anchorGraph.dijkstra(root: cloudID, startDistance: 0)
        let nameDistance: [String: Float?] = distanceArrayToVertexDict(distances: distances, graph: anchorGraph)
        return pool.map({ nameDistance[$0.getCloudAnchorID() ?? ""]! != nil && start != $0 })
    }
    
    /// Creates the weighted graph from the currently recorded nodes and edges.
    /// Note: this doesn't auto update with Firebase changes
    /// - Returns: the weighted SwiftGraph
    private func makeWeightedGraph()->WeightedGraph<String, Float> {
        let nodes = FirebaseManager.shared.pathGraph.cloudNodes
        let edges = FirebaseManager.shared.pathGraph.connections
        let anchorGraph = WeightedGraph<String, Float>(vertices: Array(nodes))
        for (nodeInfo, edgeInfo) in edges {
            guard nodes.contains(nodeInfo.from), nodes.contains(nodeInfo.to) else {
                continue
            }
            print("adding \(nodeInfo.from) \(nodeInfo.to)")
            anchorGraph.addEdge(from: nodeInfo.from, to: nodeInfo.to, weight: edgeInfo.cost, directed: true)
        }
        return anchorGraph
    }
    
    /// Computes the path between the two specified anchors.  The path is stored within the navigation to enable navigation guidance as the user moves through the environment.
    /// - Parameters:
    ///   - anchorID1: the starting cloud anchor ID
    ///   - anchorID2: the ending cloud anchor ID
    /// - Returns: a list of cloud anchor IDs that are on the route.  These should be passed to ARCore for resolving
    func computePathBetween(_ anchorID1: String, _ anchorID2: String)->[String] {
        let anchorGraph = makeWeightedGraph()
        // Note: from https://github.com/davecom/SwiftGraph
        let (distances, pathDict) = anchorGraph.dijkstra(root: anchorID1, startDistance: 0)
        // let nameDistance: [String: Float?] = distanceArrayToVertexDict(distances: distances, graph: anchorGraph)
        // let totalDistance = nameDistance[anchorID2]
        let path: [WeightedEdge<Float>] = pathDictToPath(from: anchorGraph.indexOfVertex(anchorID1)!, to: anchorGraph.indexOfVertex(anchorID2)!, pathDict: pathDict)
        let stops: [String] = anchorGraph.edgesToVertices(edges: path)
        return stops
    }
    
    func computeMultisegmentPath(_ cloudAnchors: [String]) {
        var poses: [simd_float4x4] = []
        if cloudAnchors.count == 1 {
            // TODO: think of how to handle this case
            return
        }
        var aligner = matrix_identity_float4x4
        var endTransformFromPreviousEdge: simd_float4x4?
        var landmarks: [String: simd_float4x4] = [:]
        for (a_n, a_nplus1) in zip(cloudAnchors[0..<cloudAnchors.count-1],
                                   cloudAnchors[1...]) {
            guard let edge = FirebaseManager.shared.pathGraph.connections[NodePair(from: a_n, to: a_nplus1)] else {
                FirebaseManager.shared.pathGraph.printEdges()
                // AnnouncementManager.shared.announce(announcement: "unexpectedly didn't find connection")
                return
            }
            if let endTransformFromPreviousEdge = endTransformFromPreviousEdge {
                aligner = endTransformFromPreviousEdge * edge.startAnchorTransform.alignY().inverse
            }
            landmarks[a_n] = aligner * edge.startAnchorTransform.alignY()
            landmarks[a_nplus1] = aligner * edge.endAnchorTransform.alignY()
            poses.append(aligner * edge.startAnchorTransform.alignY())
            poses += edge.path.map({aligner * $0})
            for pathAnchors in edge.pathAnchors {
                landmarks[pathAnchors.key] = aligner * pathAnchors.value.alignY()
            }
            endTransformFromPreviousEdge = aligner * edge.endAnchorTransform.alignY()
            poses.append(endTransformFromPreviousEdge!)
        }
        let routeKeypoints = MultiSegmentPathBuilder(crumbs: poses, manualKeypointIndices: []).keypoints
        //AnnouncementManager.shared.announce(announcement: "route has \(landmarks.count) cloud anchors")
        RouteNavigator.shared.setRouteKeypoints(kps: routeKeypoints)
        PositioningModel.shared.setCloudAnchors(landmarks: landmarks)
        RouteNavigator.shared.routeNameForLogging = "\(FirebaseManager.shared.getCloudAnchorName(byID: cloudAnchors.first!)!)_\(FirebaseManager.shared.getCloudAnchorName(byID: cloudAnchors.last!)!)_\(UUID().uuidString)"
    }

    func startNavigating() {
        soundTimer = Date()
        feedbackTimer = Date()
        prevKeypointPosition = PositioningModel.shared.cameraTransform ?? matrix_identity_float4x4
        hapticTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(getHapticFeedback)), userInfo: nil, repeats: true)
        followingCrumbs = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: (#selector(self.followCrumb)), userInfo: nil, repeats: true)
        HapticFeedbackAdapter.shared.startEndOfRouteHaptics()
        PositioningModel.shared.renderKeypoint(at: RouteNavigator.shared.nextKeypoint!.location)
    }
    
    func stopNavigating() {
        // TODO: we may not be cleaning up the cloud anchors appropriately
        PositioningModel.shared.removeRenderedContent()
        // TODO: we may not be cleaning up old cloud anchors
        PositioningModel.shared.resetAlignment()
        hapticTimer?.invalidate()
        HapticFeedbackAdapter.shared.stopHaptics()
        followingCrumbs?.invalidate()
        // NOTE: we may have already called these functions if we finished navigating the route
        PathLogger.shared.stopLoggingData()
        PathLogger.shared.uploadLog()
    }
    
    /// send haptic feedback if the device is pointing towards the next keypoint.
    @objc func getHapticFeedback() {
        if RouteNavigator.shared.isComplete {
            guard let curPos = PositioningModel.shared.cameraTransform?.translation, let routeEndKeypoint = RouteNavigator.shared.lastKeypoint else {
                // TODO: might want to indicate that something is wrong to the user
                return
            }
            let routeEnd = PositioningModel.shared.currentLocation(of: routeEndKeypoint.location)
            let routeEndPos = routeEnd.translation
            let routeEndPosFloorPlane = simd_float2(routeEndPos.x, routeEndPos.z)
            let curPosFloorPlane = simd_float2(curPos.x, curPos.z)
            HapticFeedbackAdapter.shared.adjustHaptics(pos: curPosFloorPlane, goal: routeEndPosFloorPlane)
            return
        }
        guard let curLocation = PositioningModel.shared.cameraTransform else {
            // TODO: might want to indicate that something is wrong to the user
            return
        }
        guard let directionToNextKeypoint = nav.getDirectionToNextKeypoint(currentLocation: curLocation) else {
            return
        }
        
        HapticFeedbackAdapter.shared.adjustHaptics(intensity: max(0.1, 1.0 - directionToNextKeypoint.distance/5.0))
        
        let coneWidth = Float.pi/12
        let lateralDisplacementToleranceRatio = Float(0.5)
        let facingTarget = directionToNextKeypoint.lateralDistanceRatioWhenCrossingTarget < lateralDisplacementToleranceRatio || abs(directionToNextKeypoint.angleDiff) < coneWidth
        let triggerSoundFeedback = facingTarget && -soundTimer.timeIntervalSinceNow > Self.FEEDBACKDELAY*max(0.2, Double(min(2.0, directionToNextKeypoint.distance)))
        if triggerSoundFeedback {
            SoundEffectManager.shared.playSystemSound(id: 1103)
            soundTimer = Date()
        }
    }
    
    func updateDirections() {
        guard let curLocation = PositioningModel.shared.cameraTransform, let nextKeypoint = RouteNavigator.shared.nextKeypoint else {
            // TODO: might want to indicate that something is wrong to the user
            return
        }
        if let directionToNextKeypoint = nav.getDirectionToNextKeypoint(currentLocation: curLocation),
           let newDirection = nav.setDirectionText(currentLocation: curLocation, direction: directionToNextKeypoint, displayDistance: true) {
            NavigationManager.shared.navigationDirection = newDirection
            AnnouncementManager.shared.announce(announcement: newDirection)
        }
    }
    
    /// checks to see if user is on the right path during navigation.
    @objc func followCrumb() {
        guard let curLocation = PositioningModel.shared.cameraTransform, let nextKeypoint = RouteNavigator.shared.nextKeypoint else {
            // TODO: might want to indicate that something is wrong to the user
            return
        }
        guard let directionToNextKeypoint = nav.getDirectionToNextKeypoint(currentLocation: curLocation) else {
            return
        }
        
        if directionToNextKeypoint.targetState == PositionState.atTarget {
            if !RouteNavigator.shared.onLastKeypoint {
                // arrived at keypoint
                // send haptic/sonic feedback
                SoundEffectManager.shared.meh()
                
                // remove current visited keypont from keypoint list
                prevKeypointPosition = nextKeypoint.location
                RouteNavigator.shared.checkOffKeypoint()
                
                // erase current keypoint and render next keypoint node
                PositioningModel.shared.renderKeypoint(at: RouteNavigator.shared.nextKeypoint!.location)
                updateDirections()
            } else {
                // arrived at final keypoint
                // send haptic/sonic feedback
                SoundEffectManager.shared.success()
                RouteNavigator.shared.checkOffKeypoint()
                AnnouncementManager.shared.announce(announcement: "You've arrived")
                PathLogger.shared.stopLoggingData()
                PathLogger.shared.uploadLog()
            }
        }
    }
}
