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
    /// mapping mode (load all data so it can be edited if needed).  TODO: make this more efficient at some point.
    case mapping
    /// navigation mode (load data only as the user requests it)
    case navigation
}

/// Manages the data stored in Firebase.  Currently, this includes both Firebase Realtime Database along with Firestore.  In the future, we hope to migrate all data away from Realtime Database.
class FirebaseManager: ObservableObject {
    /// The singleton instance of this class
    public static var shared = FirebaseManager()
    /// Keeps track of the cloud anchor IDs (keys) and associated metadata.  This variable can be observed by views
    @Published var mapAnchors: [String: CloudAnchorMetadata] = [:]
    /// Keeps track of new cloud anchor connections that get added to the database
    private var connectionObserver: ListenerRegistration?
    /// Keeps track of new cloud anchors that get added to the database
    private var cloudAnchorObservers: [ListenerRegistration] = []
    /// Keeps track of the location at which we last probed for nearby destinations
    private var lastQueryLocation: CLLocationCoordinate2D?
    /// The mode the database is currently operating within.  This mode is useful for setting various listeners.
    private var mode: FirebaseMode = .mapping
    /// The graph used to encode relationships between cloud anchors and compute shortest paths
    let mapGraph = MapGraph()
    /// A connection to the Firestore database
    private let db: Firestore
    /// the path where we last stored a log file
    var lastLogPath: String?
    
    /// Stores the current version of the edge connecting two nodes.  This is used for path versioning
    private var currentVersionMap: [NodePair<String, String>: Int] = [:]
    
    /// a handle to the cloud anchor collection.  This handle is affected by the the mapping sub folder setting.
    private var cloudAnchorCollection: CollectionReference {
        if SettingsManager.shared.mappingSubFolder.isEmpty {
            return db.collection("cloud_anchors")
        } else {
            return db.collection("\(SettingsManager.shared.mappingSubFolder)_cloud_anchors")
        }
    }
    
    /// a handle to the connection collection.  This handle is affected by the the mapping sub folder setting.
    private var connectionCollection: CollectionReference {
        if SettingsManager.shared.mappingSubFolder.isEmpty {
            return db.collection("connections")
        } else {
            return db.collection("\(SettingsManager.shared.mappingSubFolder)_connections")
        }
    }
    
    /// The first cloud anchor that is currently cached in the `FirebaseManager` object.  The notion of first is determined by alphabetically ordering the cloud identifiers
    var firstCloudAnchor: String? {
        return mapAnchors.sorted(by: { $0.0 > $1.0 }).first?.key
    }
    
    /// The private init method (this should not be called directly)
    private init() {
        db = Firestore.firestore()
    }
    
    /// Sets the mode for the database.
    /// When in .mapping mode: all data is downloaded from the database (which is not optimal).  This choice was made to allow all data to be edited.
    /// When in .navigation mode: data is downloaded as needed.
    /// - Parameter mode: the mode to set
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
    func updateCloudAnchor(identifier: String, metadata: CloudAnchorMetadata) {
        self.cloudAnchorCollection.document(identifier).updateData(metadata.asDict()) { error in
            print("error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    
    /// Uploads feedback data to the Firebase storage. The data is stored under the 'feedbackSurveyData' folder,
    /// and each feedback file is given a unique filename.
    /// - Parameter data: The JSON formatted version of feeback data.
    func uploadFeedback(_ data: Data) {
        guard let uid = AuthHandler.shared.currentUID else {
            return
        }
        let filename = "\(UUID().uuidString).json"
        Storage.storage().reference().child("feedbackSurveyData").child(uid).child(filename).putData(data) { (metadata, error) in
            print("error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    /// Uploads feedback data to the Firebase storage. The data is stored under the 'feedbackSurveyData' folder,
    /// and each feedback file is given a unique filename.
    /// - Parameter data: The JSON formatted version of feeback data.
    func uploadRecordFeedback(_ data: Data) {
        guard let uid = AuthHandler.shared.currentUID else {
            return
        }
        let filename = "\(UUID().uuidString).json"
        Storage.storage().reference().child("recordFeedback").child(uid).child(filename).putData(data) { (metadata, error) in
            print("error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    /// Download the path data from Firestore corresponding to the specified edges.
    /// - Parameters:
    ///   - edges: The edges to download specified as a list of String tuples.  Each tuple contains the start cloud anchor ID and end cloud anchor ID for the requested edge.
    ///   - completionHandler: a completion handler to call when the the downloads finish.  The success of the downloads is communicated via the Boolean input to the completion handler (`true` for success and `false` for failure).
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
    
    /// Delete the specified cloud anchor
    /// - Parameter id: the identifier of the cloud anchor ID to delete.
    func deleteCloudAnchor(id: String) {
        cloudAnchorCollection.document(id).delete()
        let _ = DataModelManager.shared.deleteDataModel(byCloudAnchorID: id)
    }
    
    /// Upload the log data to the storage bucket
    /// - Parameter logFilePath: the path to store the log file data
    /// - Parameter data: the data to upload
    func uploadLog(logFilePath: String, data: Data) {
        print("UPLOADING LOG \(logFilePath)")
        Storage.storage().reference().child("take2logs").child("\(logFilePath).log").putData(data) { (metadata, error) in
            self.lastLogPath = metadata?.path
            print("error: \(error?.localizedDescription ?? "none")")
        }
    }
    
    /// Add a connection between the specified nodes and store it in Firebase.
    /// - Parameters:
    ///   - anchorID1: the anchor ID that the connection is starting from
    ///   - anchor1Pose: the pose of corresponding to `anchorID1` (this should be in the current session's world tracking coordinate system)
    ///   - anchorID2: the anchor ID that the connection is ending at
    ///   - anchor2Pose: the pose of corresponding to `anchorID2` (this should be in the current session's world tracking coordinate system)
    ///   - breadCrumbs: the sequence of poses connecting the starting to the ending anchor
    ///   - pathAnchors: the cloud anchors that were recorded as part of the path.  Each key in this dictionary is a cloud identifier and the values are a tuple containing the cloud anchor metadata and the cloud anchor pose.
    func addConnection(anchorID1: String,
                       anchor1Pose: simd_float4x4,
                       anchorID2: String,
                       anchor2Pose: simd_float4x4,
                       breadCrumbs: [simd_float4x4],
                       pathAnchors: [String: (CloudAnchorMetadata, simd_float4x4)]) {
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
             },
             "creatorUID": AuthHandler.shared.currentUID ?? "",
             "isReadable": true
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
                  "pathID": id,
                  "version": getConnectionVersion(from: anchorID1, to: anchorID2)] as [String : Any]])
        ])
    }
    
    /// Get the next version for the connection to use between the two anchors
    /// - Parameters:
    ///   - anchorID1: the "from" anchor
    ///   - anchorID2: the "to" anchor
    /// - Returns: the integer to use for the version (this will increase by one with each new recorded path)
    private func getConnectionVersion(from anchorID1: String, to anchorID2: String)->Int {
        if let currentVersion = currentVersionMap[NodePair(from: anchorID1, to: anchorID2)] {
            return currentVersion + 1
        } else {
            return 0
        }
    }
    
    /// Parse the data from Firebase containing the cloud anchor
    /// - Parameters:
    ///   - id: the cloud anchor identifier
    ///   - data: the key-value pairs stored in the Firestore database corresponding to the cloud anchor
    /// - Returns: A tuple containing the cloud anchor metadata, the location data model, and a dictionary of ``SimpleEdge`` objects where the key for each edge is the cloud anchor identifier that the edge points to.
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
        let anchorType = AnchorType(rawValue: anchorTypeString) ?? .other
        let organization = (data["organization"] as? String) ?? ""
        let notes = (data["notes"] as? String) ?? ""
        let creatorUID = (data["creatorUID"] as? String) ?? ""
        let isReadable = (data["isReadable"] as? Bool) ?? true
        var simpleConnections: [String: SimpleEdge] = [:]
        for connection in (data["connections"] as? [[String: Any]]) ?? [] {
            guard let pathID = connection["pathID"] as? String,
                  let toID = connection["toID"] as? String,
                  let weight = connection["weight"] as? Double else {
                continue
            }
            let version = connection["version"] as? Int ?? 0
            currentVersionMap[NodePair(from: id, to: toID)] = max(version, currentVersionMap[NodePair(from: id, to: toID)] ?? 0)
            simpleConnections[toID] = SimpleEdge(pathID: pathID, cost: Float(weight), wasReversed: false, version: version)
        }
        return (
            CloudAnchorMetadata(name: anchorName,
                                type: anchorType,
                                associatedOutdoorFeature: associatedOutdoorFeature,
                                geospatialTransform: geospatialData, creatorUID: creatorUID,
                                isReadable: isReadable,
                                organization: organization,
                                notes: notes
            ),
            LocationDataModel(anchorType: anchorType,
                              associatedOutdoorFeature: associatedOutdoorFeature,
                              coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                              name: anchorName,
                              id: id,       // note: the cloudAnchorID is the same in this case
                              cloudAnchorID: id),
            simpleConnections
        )
    }
    
    /// Query for all cloud anchors within a current distance of the specified coordinate.  The results of the query are cached in the `FirebaseManager` object and its associated attributes.  This function will not query again if a the last query that was executed was within 100m of the requested point.
    /// - Parameters:
    ///   - center: the reference point for the query
    ///   - radiusInM: the distance from the query allowable to be included.
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
        // TODO: when we start enforcing security rules, we'll need to fix these queries so they can only return documents that are readable to the user
        let queries = queryBounds.map { bound -> Query in
            return cloudAnchorCollection
                .order(by: "geohash")
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
        }
        removeAllCloudAnchorObservers()
        for query in queries {
            cloudAnchorObservers.append(
                query.addSnapshotListener() { (snapshot, error) in
                    guard let snapshot = snapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    self.handleCloudAnchorSnapshot(snapshot: snapshot)
                }
            )
        }
    }
    
    private func observeQuery(query: Query) {
        
    }
    
    private func handleCloudAnchorSnapshot(snapshot: QuerySnapshot) {
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
    
    private func removeAllCloudAnchorObservers() {
        cloudAnchorObservers.map({$0.remove()})
        cloudAnchorObservers = []
    }
    
    /// Create a snapshot listener for all the cloud anchors.
    private func observeAllCloudAnchors() {
        cloudAnchorObservers.append( cloudAnchorCollection.addSnapshotListener() { snapshot, error  in
                guard let snapshot = snapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                self.handleCloudAnchorSnapshot(snapshot: snapshot)
            }
        )
    }
    
    /// Create a snapshot listener for all of the connection objects in the database
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
    }
    
    /// This is a private function used to parse data from Firebase into the appropriate connection objects.
    /// - Parameters:
    ///   - id: the UUID (encoded as a string) for the connection.  This identifier is used to associate the cloud anchors with the path.
    ///   - snapshot: the key-value pairs of the connection.
    private func addConnection(id: String, snapshot: [String: Any]) {
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
        // TODO: we don't do anything with these values right now
        let _ = (snapshot["creatorUID"] as? String) ?? ""
        let _ = (snapshot["isReadable"] as? Bool) ?? true
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
        let newEdge = ComplexEdge(startAnchorTransform: fromPose,
                                  endAnchorTransform: endPose,
                                  path: pathPoses,
                                  pathAnchors: pathAnchorsAsDict)
        FirebaseManager.shared.mapGraph.addConnection(from: startID, to: endID, withEdge: newEdge)
    }
    
    /// Get the name of the cloud anchor based on its identifier.  If the cloud anchor has not been downloaded already, this will return nil
    /// - Parameter id: the cloud anchor identifier
    /// - Returns: the cloud anchor name (or nil if the cloud anchor is not found)
    func getCloudAnchorName(byID id: String)->String? {
        return mapAnchors[id]?.name
    }
    
    /// Get the cloud anchor metadata based on its identifier.  If hte cloud anchor has not been downloaded already, this will return nil
    /// - Parameter id: the cloud anchor identifier
    /// - Returns: the metadata for the cloud anchor
    func getCloudAnchorMetadata(byID id: String)->CloudAnchorMetadata? {
        return mapAnchors[id]
    }
}
 
