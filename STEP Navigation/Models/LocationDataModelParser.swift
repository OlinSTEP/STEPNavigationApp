//
//  LocationDataModelParser.swift
//  STEP Navigation
//
//  Created by Sam Coleman on 4/9/23.
//

import Foundation
import CoreLocation

/// Provides parsing for ``LocationDataModel``
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
            
            for i in 0..<stopsRaw.count {
                let stop = stopsRaw[i]
                let coordinates = CLLocationCoordinate2D(latitude: stop.Latitude, longitude: stop.Longitude)
                // TODO: construct a real ID for the bus stops (rather than creator a UUID each time)
                locationModels.insert(LocationDataModel(anchorType: anchorType, associatedOutdoorFeature: nil, coordinates: coordinates, name: stop.Stop_name, id: UUID().uuidString))
            }
        case .externalDoor:
            print("Decode external door file.")
            var doorsRaw: [Feature] = []
            doorsRaw = try decoder.decode(DoorRaw.self, from: data).features
            
            for i in 0..<doorsRaw.count {
                let door = doorsRaw[i]
                let name = door.properties.name
                let coordinates = CLLocationCoordinate2D(latitude: door.geometry.coordinates[1], longitude: door.geometry.coordinates[0])
                locationModels.insert(LocationDataModel(anchorType: anchorType, associatedOutdoorFeature: nil, coordinates: coordinates, name: name, id: door.id))
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
    /// The bus stop ID
    var Stop_ID: Int
    /// The bus stop name
    var Stop_name: String
    /// The bus stop direction
    var Direction: Int
    /// The bus stop latitude
    var Latitude: Double
    /// The bus stop longitude
    var Longitude: Double
}

// External Door helper structs
// hold raw data from JSON
struct DoorRaw: Codable {
    let type: String
    let name: String
    let crs: CRS
    let features: [Feature]
}

/// Holds coordinate reference system (see: https://datatracker.ietf.org/doc/html/rfc7946)
struct CRS: Codable {
    let type: String
    let properties: CRSProperties
}

/// Holds coordinate reference system properties
struct CRSProperties: Codable {
    let name: String
}

/// Stores a feature that is part of a Geo JSON file
struct Feature: Codable {
    let type: String
    /// A unique ID associated with each feature
    let id: String
    let properties: FeatureProperties
    let geometry: Geometry
}

/// Stores the geometry of feature
struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

/// Stores the property of a feature
struct FeatureProperties: Codable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
    }
}

