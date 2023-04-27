//
//  NavigationManager.swift
//  STEP Navigation
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
    /// stores whether we are localized ot the next part of the route (how to compute this and keep it current).  Could do this timer based?
    @Published var localizedToNextKeypoint: Bool = false
    /// haptic feedback timer
    var hapticTimer: Timer?
    
    /// haptic feedback timer
    var followingCrumbs: Timer?
    
    /// The delay between haptic feedback pulses in seconds
    static let FEEDBACKDELAY = 0.4
    
    private init() {
        
    }
    
    func getReachabilityFromOutdoors(outOf pool: [LocationDataModel])->[Bool] {
        let anchorGraph = makeWeightedGraph()
        let (distances, _) = anchorGraph.dijkstra(root: "outdoors", startDistance: 0)
        let nameDistance: [String: Float?] = distanceArrayToVertexDict(distances: distances, graph: anchorGraph)
        return pool.map({ nameDistance[$0.getCloudAnchorID() ?? ""]! != nil })
    }
    
    /// Get a Boolean array that specifies the reachability of each of the pool of candidates from the starting location
    /// - Parameters:
    ///   - start: the start location
    ///   - pool: the potential destinations
    /// - Returns: a boolean Array such that array[i] is true iff destination i is recahable from start
    func getReachability(from start: LocationDataModel, outOf pool: [LocationDataModel])->[Bool] {
        guard let cloudID = start.getCloudAnchorID() else {
            return []
        }
        let anchorGraph = makeWeightedGraph()
        let (distances, _) = anchorGraph.dijkstra(root: cloudID, startDistance: 0)
        let nameDistance: [String: Float?] = distanceArrayToVertexDict(distances: distances, graph: anchorGraph)
        return pool.map({ nameDistance[$0.getCloudAnchorID() ?? ""]! != nil && start != $0 })
    }
    
    /// Filter a list of destinations based on their rechability from the start
    /// - Parameters:
    ///   - start: the start location
    ///   - pool: the potential destinations
    /// - Returns: a set of reachable destination
    func getReachability(from start: LocationDataModel, outOf pool: Set<LocationDataModel>)->Set<LocationDataModel> {
        guard let cloudID = start.getCloudAnchorID() else {
            return []
        }
        // TODO: need to avoid recreating the graph constantly
        let anchorGraph = makeWeightedGraph()
        let (distances, _) = anchorGraph.dijkstra(root: cloudID, startDistance: 0)
        let nameDistance: [String: Float?] = distanceArrayToVertexDict(distances: distances, graph: anchorGraph)
        return pool.filter({ nameDistance[$0.getCloudAnchorID() ?? ""]! != nil && start != $0 })
    }
    
    /// Creates the weighted graph from the currently recorded nodes and edges.
    /// Note: this doesn't auto update with Firebase changes
    /// - Returns: the weighted SwiftGraph
    private func makeWeightedGraph()->WeightedGraph<String, Float> {
        let currentLatLon = PositioningModel.shared.currentLatLon ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let nodes = FirebaseManager.shared.pathGraph.cloudNodes + ["outdoors"]
        let edges = FirebaseManager.shared.pathGraph.connections
        let anchorGraph = WeightedGraph<String, Float>(vertices: Array(nodes))
        for (nodeInfo, edgeInfo) in edges {
            guard nodes.contains(nodeInfo.from), nodes.contains(nodeInfo.to) else {
                continue
            }
            anchorGraph.addEdge(from: nodeInfo.from, to: nodeInfo.to, weight: edgeInfo.cost, directed: true)
        }
        guard let indoorLocations = DataModelManager.shared.getAllLocationModels()[.indoorDestination] else {
            return anchorGraph
        }
        for indoorLocation in indoorLocations {
            if let cloudID = indoorLocation.getCloudAnchorID(),
               let associatedOutdoorFeature = indoorLocation.getAssociatedOutdoorFeature(),
               // TODO: we really need the identifier to be persistent (not named based)
               let searchLatLon = DataModelManager.shared.getLocationDataModel(byName: associatedOutdoorFeature) {
                anchorGraph.addEdge(from: "outdoors", to: cloudID, weight: Float(currentLatLon.distance(from: searchLatLon.getLocationCoordinate())), directed: true)
            }
        }
        printNodeGraph(graph: anchorGraph)
        return anchorGraph
    }
    
    private func printNodeGraph(graph: WeightedGraph<String, Float>) {
        print("VERTICES")
        for node in graph.vertices {
            
            print("  - \(FirebaseManager.shared.getCloudAnchorName(byID: node) ?? node)")
        }
        print("EDGES")
        for outgoingEdges in graph.edges {
            for edge in outgoingEdges {
                print(" - \(FirebaseManager.shared.getCloudAnchorName(byID: graph.vertices[edge.u]) ?? graph.vertices[edge.u]) to \(FirebaseManager.shared.getCloudAnchorName(byID: graph.vertices[edge.v]) ?? graph.vertices[edge.v]) weight: \(edge.weight)")
            }
        }
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
    
    func computeMultisegmentPath(_ cloudAnchors: [String], outsideStart: CLLocationCoordinate2D?=nil) {
        guard !cloudAnchors.isEmpty else {
            fatalError("the path unexpectedly has no cloud anchors")
        }
        let finalCloudAnchors: [String]
        var poses: [simd_float4x4] = []
        if outsideStart != nil {
            finalCloudAnchors = Array(cloudAnchors[1...])
        } else {
            finalCloudAnchors = cloudAnchors
        }
        if finalCloudAnchors.count == 1 {
            // TODO: think of how to handle this case
            return
        }
        var aligner = matrix_identity_float4x4
        var endTransformFromPreviousEdge: simd_float4x4?
        var landmarks: [String: simd_float4x4] = [:]
        for (a_n, a_nplus1) in zip(finalCloudAnchors[0..<finalCloudAnchors.count-1],
                finalCloudAnchors[1...]) {
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
        if let outsideStart = outsideStart,
           let garAnchor = PositioningModel.shared.addTerrainAnchor(at: outsideStart, withName: "crossover") {

            let newKeypoint = KeypointInfo(id: garAnchor.identifier, mode: .latLonBased, location: garAnchor.transform)
            RouteNavigator.shared.setRouteKeypoints(kps: [newKeypoint] + routeKeypoints)
        } else {
            RouteNavigator.shared.setRouteKeypoints(kps: routeKeypoints)
        }
        PositioningModel.shared.setCloudAnchors(landmarks: landmarks)
        if outsideStart != nil {
            RouteNavigator.shared.routeNameForLogging = "outside_\(FirebaseManager.shared.getCloudAnchorName(byID: finalCloudAnchors.last!)!)_\(UUID().uuidString)"
        } else {
            RouteNavigator.shared.routeNameForLogging = "\(FirebaseManager.shared.getCloudAnchorName(byID: finalCloudAnchors.first!)!)_\(FirebaseManager.shared.getCloudAnchorName(byID: finalCloudAnchors.last!)!)_\(UUID().uuidString)"
        }
    }

    func startNavigating() {
        soundTimer = Date()
        feedbackTimer = Date()
        prevKeypointPosition = PositioningModel.shared.cameraTransform ?? matrix_identity_float4x4
        hapticTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: (#selector(getHapticFeedback)), userInfo: nil, repeats: true)
        followingCrumbs = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: (#selector(self.followCrumb)), userInfo: nil, repeats: true)
        HapticFeedbackAdapter.shared.startEndOfRouteHaptics()
        PositioningModel.shared.renderKeypoint(RouteNavigator.shared.nextKeypoint!)
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
            guard let curPos = PositioningModel.shared.cameraTransform?.translation,
                  let routeEndKeypoint = RouteNavigator.shared.lastKeypoint,
                  let routeEnd = PositioningModel.shared.currentLocation(of: routeEndKeypoint) else {
                // TODO: might want to indicate that something is wrong to the user
                return
            }
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
                PositioningModel.shared.renderKeypoint(RouteNavigator.shared.nextKeypoint!)
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
