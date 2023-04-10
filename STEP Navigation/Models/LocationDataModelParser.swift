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
     Parses a given json file into a list of LocationDataModel objects.
     
     - parameter filename: The name of the file to parse (without the .extension).
     - parameter fileType: The file extension (either json or geojson).
     - parameter anchorType: The type of anchor the file is representing.
     
     - returns: A list of LocationDataModels.
     */
    static func parse(from filename: String, fileType: String, anchorType: AnchorType) throws -> [LocationDataModel] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileType) else {
            throw NSError(domain: "LocatinoDataModelParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON file not found"])
        }
        
        var locationModels: [LocationDataModel] = []
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
                locationModels.append(LocationDataModel(anchorType: anchorType, coordinates: coordinates, name: stop.Stop_name))
            }
        case .externalDoor:
            print("Decode external door file.")
            var doorsRaw: [Feature] = []
            doorsRaw = try decoder.decode(DoorRaw.self, from: data).features
            
            for i in 0...doorsRaw.count-1 {
                let door = doorsRaw[i]
                let name = door.properties.name
                let coordinates = CLLocationCoordinate2D(latitude: door.geometry.coordinates[1], longitude: door.geometry.coordinates[1])
                locationModels.append(LocationDataModel(anchorType: anchorType, coordinates: coordinates, name: name))
            }
        default:
            print("Not valid anchor type \(anchorType)")
        }

        return locationModels
    }
}

// MARK: Helper structs

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

