//
//  LocationDataModelParser.swift
//  STEP Navigation
//
//  Created by Sam Coleman on 4/9/23.
//

import Foundation
import CoreLocation

struct LocationDataModelParser {
    /**
     Parses a given json file into a set of `LocationDataModel` objects.
     
     - parameter filename: The name of the file to parse (without the .extension).
     - parameter fileType: The file extension (either json or geojson).
     - parameter anchorType: The type of anchor the file is representing.
     
     - returns: A set of LocationDataModels.
     
     - Note: This function assumes that the JSON files have the expected format and are present in the main bundle of the app. If the files are not present or the format is incorrect, the parsing and creation of data models may fail
     */
    static func parse(from filename: String, fileType: String, anchorType: AnchorType) throws -> Set<LocationDataModel> {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileType) else {
            throw NSError(domain: "LocatinoDataModelParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON file not found"])
        }
        
        var locationModels = Set<LocationDataModel>()
        let data = try Data(contentsOf: url, options: .mappedIfSafe)
        let decoder = JSONDecoder()
        
        switch (anchorType) {
        case .busStop:
            print("Decode bus stop file.")
            var stopsRaw: [BusStop] = []
            stopsRaw = try decoder.decode([BusStop].self, from: data)
            
            for i in 0...stopsRaw.count-1 {
                let stop = stopsRaw[i]
                let coordinates = CLLocationCoordinate2D(latitude: stop.Latitude, longitude: stop.Longitude)
                locationModels.insert(LocationDataModel(anchorType: anchorType, associatedOutdoorFeature: nil, coordinates: coordinates, name: stop.Stop_name))
            }
        case .externalDoor:
            print("Decode external door file.")
            // let json = try JSONSerialization.jsonObject(with: data, options: [])
            // Temporary code for transferring to the realtime database
            // FirebaseManager.shared.uploadOutdoorInfoToDB("Olin Doors", json as! [String: Any])
            
            var doorsRaw: [Feature] = []
            doorsRaw = try decoder.decode(DoorRaw.self, from: data).features
            
            for i in 0...doorsRaw.count-1 {
                let door = doorsRaw[i]
                let name = door.properties.name
                let coordinates = CLLocationCoordinate2D(latitude: door.geometry.coordinates[1], longitude: door.geometry.coordinates[0])
                locationModels.insert(LocationDataModel(anchorType: anchorType, associatedOutdoorFeature: nil, coordinates: coordinates, name: name))
            }
        default:
            print("Not valid anchor type \(anchorType)")
        }

        return locationModels
    }
}

// Helper structs for JSON parsing
// MBTA Bus Stops
struct BusStop : Decodable {
    var Stop_ID: Int
    var Stop_name: String
    var Direction: Int
    var Latitude: Double
    var Longitude: Double
}

// External Door helper structs
// hold raw data from JSON
struct DoorRaw: Codable {
    let type, name: String
    let crs: CRS
    let features: [Feature]
}

struct CRS: Codable {
    let type: String
    let properties: CRSProperties
}

struct CRSProperties: Codable {
    let name: String
}

struct Feature: Codable {
    let type: String
    let properties: FeatureProperties
    let geometry: Geometry
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct FeatureProperties: Codable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
    }
}

