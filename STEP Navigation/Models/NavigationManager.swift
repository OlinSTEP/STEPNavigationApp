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
    
    /// a ring buffer used to keep the last 50 positions of the phone
    var locationRingBuffer = RingBuffer<simd_float3>(capacity: 100)
    /// a ring buffer used to keep the last 100 headings of the phone
    var headingRingBuffer = RingBuffer<Float>(capacity: 100)
    
    /// A threshold to determine when the phone rotated too much to update the angle offset
    let angleDeviationThreshold : Float = 0.2
    /// The minimum distance traveled in the floor plane in order to update the angle offset
    let requiredDistance : Float = 0.3
    /// A threshold to determine when a path is too curvy to update the angle offset
    let linearDeviationThreshold: Float = 0.05
    
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
    
    /// Returns the set of destinations that can be reached from the specified pool
    /// starting from at least one of the specified starting locations
    /// - Parameters:
    ///   - from: the list of possible locations to start from
    ///   - pool: the set of locations to test for reachability
    /// - Returns: the reachable destinations in pool starting from an element of
    ///       start locations.
    func getReachability(from startLocations: [LocationDataModel], outOf pool: Set<LocationDataModel>)->Set<LocationDataModel> {
        var reachableCloudAnchorIDs = Set<String>()
        let anchorGraph = makeWeightedGraph()
        let cloudAnchorIDsInPool = pool.compactMap({ $0.getCloudAnchorID() })

        for start in startLocations {
            guard let cloudID = start.getCloudAnchorID() else {
                continue
            }
            let reachableNodes = anchorGraph.findAllBfs(from: cloudID) { v in
                cloudAnchorIDsInPool.contains(v)
            }
            for route in reachableNodes {
                if let lastNode = route.last?.v {
                    reachableCloudAnchorIDs.insert(anchorGraph[lastNode])
                }
            }
        }
        return pool.filter({
            reachableCloudAnchorIDs.contains($0.getCloudAnchorID() ?? "")
        })
    }
    
    /// Filter a list of destinations based on their reachability from the start
    /// - Parameters:
    ///   - start: the start location
    ///   - pool: the potential destinations
    /// - Returns: a set of reachable destination
    func getReachability(from start: LocationDataModel, outOf pool:
                         Set<LocationDataModel>)->Set<LocationDataModel> {
        guard let cloudID = start.getCloudAnchorID() else {
            return []
        }
        var reachableCloudAnchorIDs = Set<String>()
        let cloudAnchorIDsInPool = pool.compactMap({ $0.getCloudAnchorID() })
        // TODO: need to avoid recreating the graph constantly
        let anchorGraph = makeWeightedGraph()
        let reachableNodes = anchorGraph.findAllBfs(from: cloudID) { v in
            cloudAnchorIDsInPool.contains(v)
        }
        for route in reachableNodes {
            if let lastNode = route.last?.v {
                reachableCloudAnchorIDs.insert(anchorGraph[lastNode])
            }
        }
        return pool.filter({
            reachableCloudAnchorIDs.contains($0.getCloudAnchorID() ?? "")
        })
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
        let indoorLocations = DataModelManager.shared.getAllIndoorLocationModels()

        for indoorLocation in indoorLocations {
            if let cloudID = indoorLocation.getCloudAnchorID(),
               let associatedOutdoorFeature = indoorLocation.getAssociatedOutdoorFeature(),
               // TODO: we really need the identifier to be persistent (not named based)
               let searchLatLon = DataModelManager.shared.getLocationDataModel(byName: associatedOutdoorFeature) {
                anchorGraph.addEdge(from: "outdoors", to: cloudID, weight: Float(currentLatLon.distance(from: searchLatLon.getLocationCoordinate())), directed: true)
            }
        }
        return anchorGraph
    }
    
    /// A utility function for printing the nodes and edges of a graph.  This function
    /// makes a bunch of assumptions about the graph structure (e.g., that each of the
    /// vertices (of String type) correspond either to a cloud anchor ID or a "outdoors")
    /// - Parameter graph: a graph describing the node connectivity
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
    
    func computePathToOutdoorMarker(outsideStart: CLLocationCoordinate2D) {
        if let garAnchor = PositioningModel.shared.addTerrainAnchor(at: outsideStart, withName: "crossover") {
            let newKeypoint = KeypointInfo(id: garAnchor.identifier, mode: .latLonBased, location: garAnchor.transform)
            RouteNavigator.shared.setRouteKeypoints(kps: [newKeypoint])
        }
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
        locationRingBuffer.clear()
        headingRingBuffer.clear()
        PositioningModel.shared.resetAlignment()
        hapticTimer?.invalidate()
        HapticFeedbackAdapter.shared.stopHaptics()
        followingCrumbs?.invalidate()
        // NOTE: we may have already called these functions if we finished navigating the route
        PathLogger.shared.stopLoggingData()
        PathLogger.shared.uploadLog()
    }
    
    /// Calculate the offset between the phone's heading (either its z-axis or y-axis projected into the floor plane) and the user's direction of travel.  This offset allows us to give directions based on the user's movement rather than the direction of the phone.
    ///
    /// - Returns: the offset
    private func getHeadingOffset() -> Float? {
        guard let startHeading = headingRingBuffer.get(0), let endHeading = headingRingBuffer.get(-1), let startPosition = locationRingBuffer.get(0), let endPosition = locationRingBuffer.get(-1) else {
            return nil
        }
        // make sure the path was far enough in the ground plane
        if sqrt(pow(startPosition.x - endPosition.x, 2) + pow(startPosition.z - endPosition.z, 2)) < requiredDistance {
            return nil
        }
        
        // make sure that the headings are all close to the start and end headings
        for i in 0..<headingRingBuffer.capacity {
            guard let currAngle = headingRingBuffer.get(i) else {
                return nil
            }
            if abs(nav.getAngleDiff(angle1: currAngle, angle2: startHeading)) > angleDeviationThreshold || abs(nav.getAngleDiff(angle1: currAngle, angle2: endHeading)) > angleDeviationThreshold {
                // the phone turned too much during the last second
                return nil
            }
        }
        // make sure the path is straight
        let u = simd_normalize(endPosition - startPosition)
        
        for i in 0..<locationRingBuffer.capacity {
            let d = locationRingBuffer.get(i)! - startPosition
            let orthogonalVector = d - u*simd_dot(d, u)
            if simd_length(orthogonalVector) > linearDeviationThreshold {
                // the phone didn't move in a straight path during the last second
                return nil
            }
        }
        let movementAngle = atan2f((startPosition.x - endPosition.x), (startPosition.z - endPosition.z))
        
        let potentialOffset = nav.getAngleDiff(angle1: movementAngle, angle2: nav.averageAngle(a: startHeading, b: endHeading))
        // check if the user is potentially moving backwards.  We only try to correct for this if the potentialOffset is in the range [0.75 pi, 1.25 pi]
        if cos(potentialOffset) < -sqrt(2)/2 {
            return potentialOffset - Float.pi
        }
        return potentialOffset
    }
    
    func getDistance(startPosition:simd_float3, endPosition:simd_float3) -> Float{
        return sqrt(pow(startPosition.x - endPosition.x, 2) + pow(startPosition.z - endPosition.z, 2))
    }
    
    
    /// update the offset between direction of travel and the orientation of the phone.  This supports a feature which allows the user to navigate with the phone pointed in a direction other than the direction of travel.  The feature cannot be accessed by users in the app store version.
    func updateHeadingOffset() {
        guard let curLocation = PositioningModel.shared.cameraTransform else {
            return
        }
        // NOTE: currPhoneHeading is not the same as curLocation.location.yaw
        let currPhoneHeading = getPhoneHeadingYaw(currentLocation: curLocation)
        
        if let startPosition = locationRingBuffer.get(0) {
              let curPosition = curLocation.translation
              if getDistance(startPosition: startPosition, endPosition: curPosition) < requiredDistance{
                  // user has not moved in a while
                  // if heading moveing around: clear ringBuffer, toggle navigation icon
                  let numMax = headingRingBuffer.data.compactMap { $0 }.max() ?? 0
                  let numMin = headingRingBuffer.data.compactMap { $0 }.min() ?? 0


                  if numMax-numMin > 0.7{
                      //user is lost
                      if headingRingBuffer.capacity > 80{
                          updateDirections()
                          headingRingBuffer.clear()
                          locationRingBuffer.clear()
                      }
                  }
                  // else: do nothing
                  
              }
          }

        
        headingRingBuffer.insert(currPhoneHeading)
        locationRingBuffer.insert(curLocation.translation)
        
        if let newOffset = getHeadingOffset(), cos(newOffset) > 0 {
            nav.headingOffset = newOffset
        }
    }
    
    /// send haptic feedback if the device is pointing towards the next keypoint.
    @objc func getHapticFeedback() {
        
        updateHeadingOffset()
        
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
