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

struct NodePair<T: Hashable, U: Hashable>: Hashable {
  let from: T
  let to: U
}

struct SimpleEdge {
    let pathID: String
    let cost: Float
}

struct ComplexEdge {
    let startAnchorTransform: simd_float4x4
    let endAnchorTransform: simd_float4x4
    let path: [simd_float4x4]
    let pathAnchors: [String: simd_float4x4]
    
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

class MapGraph {
    var cloudNodes = Set<String>()
    var lightweightConnections: [NodePair<String, String>: SimpleEdge] = [:]
    var connections: [NodePair<String, String>: ComplexEdge] = [:]
    
    func reset() {
        cloudNodes = Set<String>()
        connections = [:]
        lightweightConnections = [:]
    }
    
    func printEdges() {
        for key in connections.keys {
            print(key.from, key.to)
        }
    }
    
    func add(node: String) {
        cloudNodes.insert(node)
    }
    
    func addLightweightConnection(from fromID: String, to toID: String, withEdge simpleEdge: SimpleEdge) {
        lightweightConnections[NodePair(from: fromID, to: toID)] = simpleEdge
        // add reverse edge if it doesn't exist yet
        if lightweightConnections[NodePair(from: toID, to: fromID)] == nil {
            let reversed = SimpleEdge(pathID: simpleEdge.pathID,
                                      cost: simpleEdge.cost)
            lightweightConnections[NodePair(from: toID, to: fromID)] = reversed
        }
    }
}
