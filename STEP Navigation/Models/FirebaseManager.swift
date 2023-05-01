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

class FirebaseManager: ObservableObject {
    public static var shared = FirebaseManager()
    @Published var mapAnchors: [String: CloudAnchorMetadata] = [:]
    let pathGraph = PathGraph()
    
    var cloudAnchorRef: DatabaseReference {
        return Database.database().reference().child("cloud_anchors")
    }
    
    private init() {
        FirebaseApp.configure()
        createObservers()
    }
    
    func storeCloudAnchor(identifier: String, metadata: CloudAnchorMetadata) {
        let ref = cloudAnchorRef
        ref.updateChildValues([identifier: metadata.asDict()])
    }
    
    func deleteCloudAnchor(id: String) {
        cloudAnchorRef.child(id).removeValue()
    }
    
    func uploadLog(data: Data) {
        let uniqueId = RouteNavigator.shared.routeNameForLogging ?? UUID().uuidString
        print("UPLOADING LOG \(RouteNavigator.shared.routeNameForLogging)")
        Storage.storage().reference().child("take2logs").child("\(uniqueId).log").putData(data) { (metadata, error) in
            print("error \(error)")
        }
    }
    
    /// Writes the specified data to the realtime database. This is useful when importing data from JSONs.
    /// - Parameters:
    ///   - key: the key to store the data at (root/outdoor\_features/key
    ///   - data: the values to store there
    func uploadOutdoorInfoToDB(_ key: String, _ data: [String: Any]) {
        Database.database().reference().child("outdoor_features").child(key).setValue(data)
    }
    
    func addConnection(anchorID1: String, anchor1Pose: simd_float4x4, anchorID2: String, anchor2Pose: simd_float4x4, breadCrumbs: [simd_float4x4], pathAnchors: [String: (CloudAnchorMetadata, simd_float4x4)]) {
        let ref = cloudAnchorRef.child("connections").child(anchorID1).child(anchorID2)
        ref.updateChildValues(
            ["fromPose": anchor1Pose.toColumnMajor(),
             "toPose": anchor2Pose.toColumnMajor(),
             "path": breadCrumbs.map({ $0.toColumnMajor() }),
             "pathAnchors": pathAnchors.reduce(into: [String: [Float]]()) { dict, anchorItem in
                 let cloudIdentifier = anchorItem.0
                 let anchorPose = anchorItem.1.1
                 dict[cloudIdentifier] = anchorPose.toColumnMajor()
             }
            ]
        )
    }
    
    var firstCloudAnchor: String? {
        return mapAnchors.sorted(by: { $0.0 > $1.0 }).first?.key
    }
    
    func createObservers() {
        cloudAnchorRef.observe(.childAdded) { snapshot  in
            guard let keyValuePairs = snapshot.value as? [String: Any] else {
                return
            }
            guard let anchorName = keyValuePairs["name"] as? String else {
                return
            }
            guard let geospatialTransform = keyValuePairs["geospatialTransform"] as? [String: Any],
                  let geoLocation = geospatialTransform["location"] as? [String: Double],
                  let latitude = geoLocation["latitude"],
                  let longitude = geoLocation["longitude"] else {
                return
            }
            let anchorCategory = (keyValuePairs["category"] as? String) ?? ""
            let associatedOutdoorFeature = (keyValuePairs["associatedOutdoorFeature"] as? String) ?? ""
            let anchorType = AnchorType(rawValue: anchorCategory) ?? .indoorDestination
            DataModelManager.shared.addDataModel(LocationDataModel(anchorType: anchorType, associatedOutdoorFeature: associatedOutdoorFeature,  coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), name: anchorName, cloudAnchorID: snapshot.key))
            self.mapAnchors[snapshot.key] = CloudAnchorMetadata(name: anchorName, type: anchorType)
            self.pathGraph.cloudNodes.insert(snapshot.key)
        }
        cloudAnchorRef.child("connections").observe(.childAdded) { snapshot in
            self.handleConnections(snapshot: snapshot)
        }
        cloudAnchorRef.child("connections").observe(.childChanged) { snapshot in
            self.handleConnections(snapshot: snapshot)
        }
    }
    
    func handleConnections(snapshot: DataSnapshot) {
        // delete existing connections and repopulate (TODO: this is causing issues with our bidirectional treatment of edges).  We might have to do this at another part of the app
        // pathGraph.deleteConnections(from: snapshot.key)
        guard let outgoingEdges = snapshot.value as? [String: Any] else {
            return
        }
        let startID = snapshot.key
        for (endID, edge) in outgoingEdges {
            guard let edgeDict = edge as? [String: Any],
                  let fromPoseArray = edgeDict["fromPose"] as? [Double],
                  let fromPose = simd_float4x4(fromColumnMajorArray: fromPoseArray),
                  let endPoseArray = edgeDict["toPose"] as? [Double],
                  let endPose = simd_float4x4(fromColumnMajorArray: endPoseArray),
                  let pathArrays = edgeDict["path"] as? [[Double]]
            else {
                continue
            }
            let pathAnchors = (edgeDict["pathAnchors"] as? [String: [Double]]) ?? [:]
            let pathPoses = pathArrays.compactMap( {simd_float4x4(fromColumnMajorArray: $0) })
            let pathAnchorsAsDict = pathAnchors.reduce(into: [String: simd_float4x4]()) { dict, anchorInfo in
                let cloudIdentifier = anchorInfo.0
                let columnMajor = anchorInfo.1
                dict[cloudIdentifier] = simd_float4x4(fromColumnMajorArray: columnMajor)
            }
            print("adding edge \(startID) \(endID)")
            pathGraph.connections[NodePair(from: startID, to: endID)] = ComplexEdge(startAnchorTransform: fromPose,
                            endAnchorTransform: endPose,
                            path: pathPoses,
                                                                         pathAnchors: pathAnchorsAsDict)
            // Add the reverse edge if none exists yet.  If we have an actual reverse edge than this would not run
            if pathGraph.connections[NodePair(from: endID, to: startID)] == nil {
                pathGraph.connections[NodePair(from: endID, to: startID)] = ComplexEdge(startAnchorTransform: endPose,
                                                                                        endAnchorTransform: fromPose,
                                                                                        path: pathPoses.reversed(), pathAnchors: pathAnchorsAsDict)
            }
        }
    }
    
    func getCloudAnchorID(byName name: String)->String? {
        for (id, metadata) in mapAnchors {
            if metadata.name == name {
                return id
            }
        }
        return nil
    }
    
    func getCloudAnchorName(byID id: String)->String? {
        return mapAnchors[id]?.name
    }
    
    func getCloudAnchorMetadata(byID id: String)->CloudAnchorMetadata? {
        return mapAnchors[id]
    }
}
