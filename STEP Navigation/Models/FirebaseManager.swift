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

enum FirebaseMode {
    case mapping
    case navigation
}

class FirebaseManager: ObservableObject {
    public static var shared = FirebaseManager()
    @Published var mapAnchors: [String: CloudAnchorMetadata] = [:]
    var outdoorFeatures: [String: CLLocationCoordinate2D] = [:]
    private var connectionObserver: ListenerRegistration?
    private var cloudAnchorObserver: ListenerRegistration?
    private var lastQueryLocation: CLLocationCoordinate2D?
    private var mode: FirebaseMode = .mapping

    let pathGraph = PathGraph()
    
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
        FirebaseApp.configure()
        db = Firestore.firestore()
    }
    
    func setMode(mode: FirebaseMode) {
        self.mode = mode
        if mode == .mapping {
            observeAllCloudAnchors()
            observeAllConnections()
        } else {
            // TODO: really don't want to have to observe all the connections, but instead pull the path when needed
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
            print(error?.localizedDescription)
        }
    }
    
    func deleteCloudAnchor(id: String) {
        cloudAnchorCollection.document(id).delete()
    }
    
    func uploadLog(data: Data) {
        let uniqueId = RouteNavigator.shared.routeNameForLogging ?? UUID().uuidString
        print("UPLOADING LOG \(RouteNavigator.shared.routeNameForLogging)")
        Storage.storage().reference().child("take2logs").child("\(uniqueId).log").putData(data) { (metadata, error) in
            print("error \(error)")
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
    
    private func parseCloudAnchor(id: String, _ data: [String: Any])->(CloudAnchorMetadata, LocationDataModel)? {
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
                              cloudAnchorID: id)
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
                for document in documents {
                    if let (cloudMetadata, dataModel) = self.parseCloudAnchor(id: document.documentID, document.data()) {
                        // we could wind up adding the same model multiple times, but that is okay
                        self.mapAnchors[document.documentID] = cloudMetadata
                        DataModelManager.shared.addDataModel(dataModel)
                        self.pathGraph.cloudNodes.insert(document.documentID)
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
                    if let (cloudMetadata, dataModel) = self.parseCloudAnchor(id: diff.document.documentID, diff.document.data()) {
                        self.mapAnchors[diff.document.documentID] = cloudMetadata
                        DataModelManager.shared.addDataModel(dataModel)
                        self.pathGraph.cloudNodes.insert(diff.document.documentID)
                    }
                case .removed:
                    if DataModelManager.shared.deleteDataModel(byCloudAnchorID: diff.document.documentID) {
                        self.mapAnchors.removeValue(forKey: diff.document.documentID)
                        self.pathGraph.cloudNodes.remove(diff.document.documentID)
                    }
                case .modified:
                    if let (cloudMetadata, dataModel) = self.parseCloudAnchor(id: diff.document.documentID, diff.document.data()), DataModelManager.shared.deleteDataModel(byCloudAnchorID: diff.document.documentID) {
                        self.mapAnchors[diff.document.documentID] = cloudMetadata
                        DataModelManager.shared.addDataModel(dataModel)
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
        // pathGraph.deleteConnections(from: snapshot.key)
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
        pathGraph.connections[NodePair(from: startID, to: endID)] = ComplexEdge(startAnchorTransform: fromPose,
                        endAnchorTransform: endPose,
                        path: pathPoses,
                        pathAnchors: pathAnchorsAsDict)
        // Add the reverse edge if none exists yet.  If we have an actual reverse edge than this would not run
        if pathGraph.connections[NodePair(from: endID, to: startID)] == nil {
            pathGraph.connections[NodePair(from: endID, to: startID)] = ComplexEdge(startAnchorTransform: endPose,
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
