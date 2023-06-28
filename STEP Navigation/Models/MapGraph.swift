//
//  FirebaseManager.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 3/30/23.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import ARKit
import FirebaseStorage
import SwiftGraph
import SwiftUI

/// A pair of nodes suitable for specifying the start and end of an edge
struct NodePair<T: Hashable, U: Hashable>: Hashable {
    /// The start of the edge
    let from: T
    /// The end of the edge
    let to: U
}

/// Simple edges contain a identifier that allows for downloading and constructing a ``ComplexEdge``.  The simple edge only defines cost, rather than the actual sequence of poses that are specified in a ``ComplexEdge``.
struct SimpleEdge {
    /// The identifier of the edge (suitable for downloading the full path)
    let pathID: String
    /// The cost of traversing the edge (currently based on the length of the path)
    let cost: Float
    /// True if this simple edge was created from reversing an edge
    let wasReversed: Bool
    /// The sequential 
    let version: Int
}

/// A complex edge that allows for multiple paths to be stitched together into a single, unified path.
struct ComplexEdge {
    /// The pose of the start of this edge (this will coincide with a cloud anchor)
    let startAnchorTransform: simd_float4x4
    /// The pose of the end of this edge (this will coincide with a cloud anchor)
    let endAnchorTransform: simd_float4x4
    /// The sequence of poses that make up the path itself (excluding the start and end anchor)
    let path: [simd_float4x4]
    /// Any cloud anchors (cloud identifier is the key) and anchor poses (values) that were created while recording this path.
    let pathAnchors: [String: simd_float4x4]
    
    /// The length of the path measured in meters.
    var cost: Float {
        if let first = path.first, let end = path.last {
            var d: Float = 0.0
            
            // add the cost of moving from start anchor to the beginning of the path
            d += simd_distance(startAnchorTransform.columns.3, first.columns.3)
            
            // add the cost along the path itself
            for (from, to) in zip(path[0..<path.count-1], path[1...]) {
                d += simd_distance(from.columns.3, to.columns.3)
            }
            
            // add the cost of moving from end of the path to the end anchor
            d += simd_distance(end.columns.3, endAnchorTransform.columns.3)
            return d
        } else {
            return simd_distance(startAnchorTransform.columns.3, endAnchorTransform.columns.3)
        }
    }
}

enum ConnectionStatus: CaseIterable {
    case notConnected
    case connectedThroughMultipleHops
    case connectedThroughReverseEdge
    case connectedDirectly
    
    var connectionColor: Color {
        switch self {
        case .connectedDirectly:
            return .green
        case .connectedThroughReverseEdge:
            return .yellow
        case .notConnected:
            return .red
        case .connectedThroughMultipleHops:
            return .blue
        }
    }
<<<<<<< HEAD
    
=======
  
>>>>>>> main
    var connectionText: String {
        switch self {
        case .connectedDirectly:
            return "Directly Connected"
        case .connectedThroughReverseEdge:
            return "Connected in Reverse"
        case .notConnected:
            return "Not Connected"
        case .connectedThroughMultipleHops:
            return "Indirectly Connected"
        }
    }
    
    static var allCases: [ConnectionStatus] {
            return [
                .notConnected,
                .connectedThroughMultipleHops,
                .connectedThroughReverseEdge,
                .connectedDirectly
            ]
        }
<<<<<<< HEAD

=======
>>>>>>> main
}

/// This class encompasses a map consisting of cloud anchors (nodes) and paths connecting cloud
/// anchors (edges).  This class is mainly a datastructure and other classes access its data for
/// performing operations (e.g., path planning)
class MapGraph {
    /// The cloud anchors that compose this graph (the cloud identifier is stored in the set)
    var cloudNodes = Set<String>()
    /// These connections are composed of starting and ending cloud anchors (keys) and
    /// simple edges (values).  These connections can be used for path planning even when
    /// the full connections have not downloaded yet.
    private (set) var lightweightConnections: [NodePair<String, String>: SimpleEdge] = [:]
    /// These connections are comprised of starting and ending cloud anchors (keys) and
    /// complex edges (values).  These connections are useful for constructing the full path
    /// which can then be converted into ``KeypointInfo`` objects.
    private (set) var connections: [NodePair<String, String>: ComplexEdge] = [:]
    
    /// This private Boolean trakcs whether the weighted graph should be recomputed or not
    private var isDirty: Bool = false
    
    /// This object is used to cache the weighted graph that was last generated by this class
    private var cachedWeightedGraph: WeightedGraph<String, Float>?
    
    /// The `SwiftGraph` version of the map graph.  This graph is recomputed only when the underlying data
    /// has changed.
    var weightedGraph: WeightedGraph<String, Float> {
        if !isDirty, let currentGraph = cachedWeightedGraph {
            return currentGraph
        }
        return makeWeightedGraph()
    }
    
    /// Reset the data
    func reset() {
        cloudNodes = Set<String>()
        connections = [:]
        isDirty = false
        lightweightConnections = [:]
    }
    
    /// Using the vertices currently downloaded from the database, determine which the connection status between the the specified cloud anchor (`anchorID1`) and each cloud anchor in the pool
    /// - Parameters:
    ///   - anchorID1: the cloud anchor to start from
    ///   - pool: the pool of anchors (only cloud anchors are tested for connectivity)
    /// - Returns: an array where the `i`th entry indicates the connection status
    func getConnectionStatus(from anchorID1: String, to pool: [LocationDataModel])->[ConnectionStatus] {
        // start out by assuming nothing is connected
        var statuses = Array(repeating: ConnectionStatus.notConnected, count: pool.count)
        
        // create this map to speed up search later
        var cloudAnchorIDToIndex : [String: Int] = [:]
        for i in 0..<pool.count {
            if let cloudAnchorID = pool[i].getCloudAnchorID() {
                cloudAnchorIDToIndex[cloudAnchorID] = i
            }
        }
        
        // check direct connections
        for (nodePair, simpleEdge) in lightweightConnections {
            if nodePair.from == anchorID1, let connectedNodeIndex = cloudAnchorIDToIndex[nodePair.to] {
                statuses[connectedNodeIndex] = simpleEdge.wasReversed ? .connectedThroughReverseEdge : .connectedDirectly
            }
        }
        
        // do a breadth first search to find connected nodes
        let allPaths = weightedGraph.findAllBfs(from: anchorID1, goalTest: { vertex in
            return true
        })
        // get the reachable vertex indices
        let reachableVertexIndices = allPaths.compactMap({$0.last?.v})
        // convert to cloud anchor IDs and make it into a set
        let reachableCloudAnchorIds = Set<String>(reachableVertexIndices.map({weightedGraph.vertexAtIndex($0)}))
        // mark the appropriate cloud anchor IDs that haven't yet been marked as connected
        for i in 0..<statuses.count {
            if statuses[i] == .notConnected, let cloudAnchorID = pool[i].getCloudAnchorID(), reachableCloudAnchorIds.contains(cloudAnchorID) {
                statuses[i] = .connectedThroughMultipleHops
            }
        }
        return statuses
    }
    
    func isDirectlyConnected(from anchorID1: String, to anchorID2: String) -> Bool {
        // start out by assuming nothing is connected
        var status = ConnectionStatus.notConnected
        
        for (nodePair, simpleEdge) in lightweightConnections {
            if nodePair.from == anchorID1, nodePair.to == anchorID2 {
                status = simpleEdge.wasReversed ? .connectedThroughReverseEdge : .connectedDirectly
            }
        }
        
        return status == .connectedDirectly
    }
    
    /// Print the edges in the graph
    func printEdges() {
        for key in connections.keys {
            print(key.from, key.to)
        }
    }
    
    /// Add the specified cloud anchor node
    /// - Parameter node: the cloud anchor identifier
    func add(node: String) {
        isDirty = true
        cloudNodes.insert(node)
    }
    
    /// Add a new lightweight connection to the graph.
    /// - Parameters:
    ///   - fromID: the starting cloud anchor's cloud identifier
    ///   - toID: the ending cloud anchor's cloud identifier
    ///   - simpleEdge: the simple edge that encodes that path ID and the edge cost
    func addLightweightConnection(from fromID: String, to toID: String, withEdge simpleEdge: SimpleEdge) {
        isDirty = true
        let currentConnection = lightweightConnections[NodePair(from: fromID, to: toID)]
        if currentConnection == nil || (currentConnection!.version < simpleEdge.version || currentConnection!.wasReversed) {
            lightweightConnections[NodePair(from: fromID, to: toID)] = simpleEdge
        }
        let reverseConnection = lightweightConnections[NodePair(from: toID, to: fromID)]
        // add reverse edge if it doesn't exist yet or if it was reversed and has a lower version
        if reverseConnection == nil || (reverseConnection!.wasReversed && reverseConnection!.version < simpleEdge.version) {
            let reversed = SimpleEdge(pathID: simpleEdge.pathID,
                                      cost: simpleEdge.cost,
                                      wasReversed: true,
                                      version: simpleEdge.version)
            lightweightConnections[NodePair(from: toID, to: fromID)] = reversed
        }
    }
    
    /// Add a new connection to the graph.
    /// - Parameters:
    ///   - fromID: the starting cloud anchor's cloud identifier
    ///   - toID: the ending cloud anchor's cloud identifier
    ///   - complexEdge: the complex edge that encodes that path and start and end anchors
    func addConnection(from fromID: String, to toID: String, withEdge complexEdge: ComplexEdge) {
        isDirty = true
        connections[NodePair(from: fromID, to: toID)] = complexEdge
        // Add the reverse edge if none exists yet.  If we have an actual reverse edge than this would not run
        if connections[NodePair(from: toID, to: fromID)] == nil {
            connections[NodePair(from: toID, to: fromID)] = ComplexEdge(startAnchorTransform: complexEdge.endAnchorTransform,
                            endAnchorTransform: complexEdge.startAnchorTransform,
                            path: complexEdge.path.reversed(),
                            pathAnchors: complexEdge.pathAnchors)
        }
    }
    
    /// Creates the weighted graph (SwiftGraph) from the currently recorded nodes and edges.
    /// Note: this doesn't auto update with Firebase changes
    /// - Returns: the weighted SwiftGraph
    private func makeWeightedGraph()->WeightedGraph<String, Float> {
        let currentLatLon = PositioningModel.shared.currentLatLon ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let nodes = FirebaseManager.shared.mapGraph.cloudNodes + ["outdoors"]
        let edges = FirebaseManager.shared.mapGraph.lightweightConnections
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
               let searchLatLon = DataModelManager.shared.getLocationDataModel(byID: associatedOutdoorFeature) {
                anchorGraph.addEdge(from: "outdoors", to: cloudID, weight: Float(currentLatLon.distance(from: searchLatLon.getLocationCoordinate())), directed: true)
            }
        }
        isDirty = false
        cachedWeightedGraph = anchorGraph
        return anchorGraph
    }
}
