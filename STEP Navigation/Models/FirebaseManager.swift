//
//  FirebaseManager.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 3/30/23.
//

import ARKit
import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import GeoFireUtils

/// The mode of operation for the database manager.  This is used to set the scope of some of the database listeners (e.g., how much data to prefetch).
enum FirebaseMode {
    case mapping
    case navigation
}

/// Manages the data stored in Firebase.  Currently, this includes both Firebase Realtime Database along with Firestore.  In the future, we hope to migrate all data away from Realtime Database.
class FirebaseManager: ObservableObject {
    /// The singleton instance of this class
    public static var shared = FirebaseManager()
    /// Keeps track of the cloud anchor IDs (keys) and associated metadata.  This variable can be observed by views
    @Published var mapAnchors: [String: CloudAnchorMetadata] = [:]
    /// Maps outdoor features to location
    var outdoorFeatures: [String: CLLocationCoordinate2D] = [:]
    /// Keeps track of new cloud anchor connections that get added to the database
    private var connectionObserver: ListenerRegistration?
    /// Keeps track of new cloud anchors that get added to the database
    private var cloudAnchorObserver: ListenerRegistration?
    /// Keeps track of the location at which we last probed for nearby destinations
    private var lastQueryLocation: CLLocationCoordinate2D?
    /// The mode the database is currently operating within.  This mode is useful for setting various listeners.
    private var mode: FirebaseMode = .mapping
    
    /// The graph used to encode relationships between cloud anchors and compute shortest paths
    let mapGraph = MapGraph()
    
    /// A connection to the Firestore database
    private let db: Firestore
    private var cloudAnchorCollection: CollectionReference {
        if SettingsManager.shared.mappingSubFolder.isEmpty {
            return db.collection("cloud_anchors")
        } else {
            return db.collection("\(SettingsManager.shared.mappingSubFolder)_cloud_anchors")
        }
    }
    private var connectionCollection: CollectionReference {
        if SettingsManager.shared.mappingSubFolder.isEmpty {
            return db.collection("connections")
        } else {
            return db.collection("\(SettingsManager.shared.mappingSubFolder)_connections")
        }
    }
    
    private init() {
        db = Firestore.firestore()
    }
    
    func setMode(mode: FirebaseMode) {
        self.mode = mode
        // if we are in the mapping mode then we download all of the cloud anchors and observe all connections (this is best for when you are editing data)
        if mode == .mapping {
            // TODO: we need to be careful not to download too much of our database in the mapping case
            observeAllCloudAnchors()
            observeAllConnections()
        }
    }
    
    /// Store the cloud anchor in the database.  The identifier is assumed to be the cloudAnchorID returned
    /// by ARCore
    /// - Parameters:
    ///   - identifier: the ARCore Cloud Anchor ID
    ///   - metadata: the data to store with the cloud anchor
    ///   TODO: need to support geo hash
    func storeCloudAnchor(identifier: String, metadata: CloudAnchorMetadata) {
       cloudAnchorCollection.document(identifier).setData(metadata.asDict()) { error in
            print("error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    /// Update the cloud anchor in the database.  The identifier is assumed to be the cloudAnchorID returned
    /// by ARCore
    /// - Parameters:
    ///   - identifier: the ARCore Cloud Anchor ID
    ///   - metadata: the data to store with the cloud anchor
    ///   TODO: need to support geo hash
    func updateCloudAnchor(identifier: String, metadata: CloudAnchorMetadata) {
        self.cloudAnchorCollection.document(identifier).updateData(metadata.asDict()) { error in
            print("error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    func download(edges: [(String, String)], completionHandler: @escaping  (Bool)->()) {
        guard let firstEdge = edges.first else {
            // we got all of the edges
            return completionHandler(true)
        }
        // TODO: I'm not sure if this structure of serially downloading the path edges is slow
        let nodePair = NodePair(from: firstEdge.0, to: firstEdge.1)
        guard mapGraph.connections[nodePair] == nil else {
            // download the rest
            return download(edges: Array(edges[1...]), completionHandler: completionHandler)
        }
        guard let lightweightEdge = mapGraph.lightweightConnections[nodePair] else {
            return completionHandler(false)
        }
        connectionCollection.document(lightweightEdge.pathID).getDocument() { (snapshot, error) in
            guard let document = snapshot, let data = document.data() else {
                print("error: \(error?.localizedDescription ?? "none")")
                return completionHandler(false)
            }
            self.addConnection(id: document.documentID, snapshot: data)
            return self.download(edges: Array(edges[1...]), completionHandler: completionHandler)
        }
    }
    
    func deleteCloudAnchor(id: String) {
        cloudAnchorCollection.document(id).delete()
    }
    
    func uploadLog(data: Data) {
        let uniqueId = RouteNavigator.shared.routeNameForLogging ?? UUID().uuidString
        print("UPLOADING LOG \(RouteNavigator.shared.routeNameForLogging ?? "nil")")
        Storage.storage().reference().child("take2logs").child("\(uniqueId).log").putData(data) { (metadata, error) in
            print("error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    func addConnection(anchorID1: String, anchor1Pose: simd_float4x4, anchorID2: String, anchor2Pose: simd_float4x4, breadCrumbs: [simd_float4x4], pathAnchors: [String: (CloudAnchorMetadata, simd_float4x4)]) {
        // we'll create an identifier to refer to the path and then link it to the cloud anchors
        // TODO: add transaction
        let id = UUID().uuidString
        let ref = connectionCollection.document(id)
        ref.setData(
            ["fromID": anchorID1,
             "toID": anchorID2,
             "fromPose": anchor1Pose.toColumnMajor(),
             "toPose": anchor2Pose.toColumnMajor(),
             // Need to flatten this due to a limitation where nested arrays cannot be stored
             "path": breadCrumbs.map({ $0.toColumnMajor() }).reduce(into: []) { partialResult, newPose in
                 partialResult += newPose
             },
             "pathAnchors": pathAnchors.reduce(into: [String: [Float]]()) { dict, anchorItem in
                 let cloudIdentifier = anchorItem.0
                 let anchorPose = anchorItem.1.1
                 dict[cloudIdentifier] = anchorPose.toColumnMajor()
             }
            ]
        ) { error in
            print("error: \(error?.localizedDescription ?? "none")")
        }
        // add data to the the from node
        let edgeWeight = ComplexEdge(startAnchorTransform: anchor1Pose, endAnchorTransform: anchor2Pose, path: breadCrumbs, pathAnchors: [:]).cost
        cloudAnchorCollection.document(anchorID1).updateData([
            "connections": FieldValue.arrayUnion(
                [["toID": anchorID2,
                  "weight": edgeWeight,
                  "pathID": id] as [String : Any]])
        ])

    }
    
    var firstCloudAnchor: String? {
        return mapAnchors.sorted(by: { $0.0 > $1.0 }).first?.key
    }
    
    private func parseCloudAnchor(id: String, _ data: [String: Any])->(CloudAnchorMetadata, LocationDataModel, [String: SimpleEdge])? {
        guard let anchorName = data["name"] as? String else {
            return nil
        }
        guard let geospatialTransform = data["geospatialTransform"] as? [String: Any],
              let geoLocation = geospatialTransform["location"] as? [String: Double],
              let latitude = geoLocation["latitude"],
              let longitude = geoLocation["longitude"],
              let geospatialData = GeospatialData(fromDict: geospatialTransform) else {
            return nil
        }
        let anchorTypeString = (data["category"] as? String) ?? ""
        let associatedOutdoorFeature = (data["associatedOutdoorFeature"] as? String) ?? ""
        let anchorType = AnchorType(rawValue: anchorTypeString) ?? .indoorDestination
        var simpleConnections: [String: SimpleEdge] = [:]
        for connection in (data["connections"] as? [[String: Any]]) ?? [] {
            guard let pathID = connection["pathID"] as? String,
                  let toID = connection["toID"] as? String,
                  let weight = connection["weight"] as? Double else {
                continue
            }
            simpleConnections[toID] = SimpleEdge(pathID: pathID, cost: Float(weight), isReversed: false)
        }
        return (
            CloudAnchorMetadata(
            name: anchorName,
            type: anchorType,
            associatedOutdoorFeature: associatedOutdoorFeature,
            geospatialTransform: geospatialData),
            LocationDataModel(anchorType: anchorType,
                              associatedOutdoorFeature: associatedOutdoorFeature,
                              coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                              name: anchorName,
                              cloudAnchorID: id),
            simpleConnections
        )
    }
    
    func queryNearbyAnchors(to center: CLLocationCoordinate2D, withRadius radiusInM: Double) {
        guard mode == .navigation else {
            return
        }
        if let lastQueryLocation = lastQueryLocation, center.distance(from: lastQueryLocation) < 100.0 {
            // too close, no need to query again
            return
        }
        lastQueryLocation = center
        // Each item in 'bounds' represents a startAt/endAt pair. We have to issue
        // a separate query for each pair. There can be up to 9 pairs of bounds
        // depending on overlap, but in most cases there are 4.
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInM)
        let queries = queryBounds.map { bound -> Query in
            return cloudAnchorCollection
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        for query in queries {
            query.getDocuments() { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    print("Unable to fetch snapshot data. \(String(describing: error))")
                    return
                }
                print("querying \(documents.count)")
                for document in documents {
                    if let (cloudMetadata, dataModel, lightweightConnections) = self.parseCloudAnchor(id: document.documentID, document.data()) {
                        // we could wind up adding the same model multiple times, but that is okay
                        self.mapAnchors[document.documentID] = cloudMetadata
                        DataModelManager.shared.addDataModel(dataModel)
                        self.mapGraph.cloudNodes.insert(document.documentID)
                        for (toID, simpleEdge) in lightweightConnections {
                            print("added lightweight \(document.documentID) to \(toID)")
                            self.mapGraph.addLightweightConnection(from: document.documentID, to: toID, withEdge: simpleEdge)
                        }
                    }
                }
            }
        }
    }
    
    private func observeAllCloudAnchors() {
        cloudAnchorObserver?.remove()
        cloudAnchorObserver = cloudAnchorCollection.addSnapshotListener() { snapshot, error  in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                switch diff.type {
                case .added:
                    if let (cloudMetadata, dataModel, lightweightConnections) = self.parseCloudAnchor(id: diff.document.documentID, diff.document.data()) {
                        self.mapAnchors[diff.document.documentID] = cloudMetadata
                        DataModelManager.shared.addDataModel(dataModel)
                        self.mapGraph.cloudNodes.insert(diff.document.documentID)
                        for (toID, simpleEdge) in lightweightConnections {
                            self.mapGraph.addLightweightConnection(from: diff.document.documentID, to: toID, withEdge: simpleEdge)
                        }
                    }
                case .removed:
                    if DataModelManager.shared.deleteDataModel(byCloudAnchorID: diff.document.documentID) {
                        self.mapAnchors.removeValue(forKey: diff.document.documentID)
                        self.mapGraph.cloudNodes.remove(diff.document.documentID)
                    }
                case .modified:
                    if let (cloudMetadata, dataModel, lightweightConnections) = self.parseCloudAnchor(id: diff.document.documentID, diff.document.data()), DataModelManager.shared.deleteDataModel(byCloudAnchorID: diff.document.documentID) {
                        self.mapAnchors[diff.document.documentID] = cloudMetadata
                        DataModelManager.shared.addDataModel(dataModel)
                        for (toID, simpleEdge) in lightweightConnections {
                            self.mapGraph.addLightweightConnection(from: diff.document.documentID, to: toID, withEdge: simpleEdge)
                        }
                    }
                }
            }
        }
    }
    
    private func observeAllConnections() {
        connectionObserver?.remove()
        connectionObserver = connectionCollection.addSnapshotListener() { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                switch diff.type {
                case .added:
                    self.addConnection(id: diff.document.documentID, snapshot: diff.document.data())
                    break
                case .modified:
                    // TODO: support modifying connections
                    break
                case .removed:
                    // TODO: support deleting connections
                    break
                }
            }
        }
        // TODO: support the creation of a graph without the full path data
        
        // TODO: these might need to be migrated to Firestore also
        Database.database().reference().child("outdoor_features").observe(.childAdded) { snapshot  in
            guard let value = snapshot.value as? [String: Any],
                  let features = value["features"] as? [[String:Any]] else {
                return
            }
            for feature in features {
                guard let properties = feature["properties"] as? [String: Any],
                      let name = properties["Name"] as? String,
                      let geometry = feature["geometry"] as? [String: Any],
                      let coordinates = geometry["coordinates"] as? [Double] else {
                    continue
                }
                self.outdoorFeatures[name] = CLLocationCoordinate2D(latitude: coordinates[0], longitude: coordinates[1])
            }
        }
    }
    
    func addConnection(id: String, snapshot: [String: Any]) {
        // delete existing connections and repopulate (TODO: this is causing issues with our bidirectional treatment of edges).  We might have to do this at another part of the app
        guard let startID = snapshot["fromID"] as? String,
              let endID = snapshot["toID"] as? String,
              let fromPoseArray = snapshot["fromPose"] as? [Double],
              let fromPose = simd_float4x4(fromColumnMajorArray: fromPoseArray),
              let endPoseArray = snapshot["toPose"] as? [Double],
              let endPose = simd_float4x4(fromColumnMajorArray: endPoseArray),
              let pathArrays = snapshot["path"] as? [Double] else {
            return
        }
        let pathAnchors = (snapshot["pathAnchors"] as? [String: [Double]]) ?? [:]
        var pathPoses: [simd_float4x4] = []
        for i in stride(from: 0, to: pathArrays.count, by: 16) {
            if let newPose = simd_float4x4(fromColumnMajorArray: Array(pathArrays[i..<i+16])) {
                pathPoses.append(newPose)
            }
        }
        let pathAnchorsAsDict = pathAnchors.reduce(into: [String: simd_float4x4]()) { dict, anchorInfo in
            let cloudIdentifier = anchorInfo.0
            let columnMajor = anchorInfo.1
            dict[cloudIdentifier] = simd_float4x4(fromColumnMajorArray: columnMajor)
        }
        print("adding edge \(startID) \(endID)")
        mapGraph.connections[NodePair(from: startID, to: endID)] = ComplexEdge(startAnchorTransform: fromPose,
                        endAnchorTransform: endPose,
                        path: pathPoses,
                        pathAnchors: pathAnchorsAsDict)
        // Add the reverse edge if none exists yet.  If we have an actual reverse edge than this would not run
        if mapGraph.connections[NodePair(from: endID, to: startID)] == nil {
            mapGraph.connections[NodePair(from: endID, to: startID)] = ComplexEdge(startAnchorTransform: endPose,
                            endAnchorTransform: fromPose,
                            path: pathPoses.reversed(),
                            pathAnchors: pathAnchorsAsDict)
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
