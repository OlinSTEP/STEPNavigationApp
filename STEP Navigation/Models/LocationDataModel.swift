//
//  LocationDataModel.swift
//  STEP Navigation
//
//  Created by Sam Coleman on 4/8/23.
//

import Foundation
import CoreLocation

// MARK: Define struct
/**
    A struct that represents a location data model where an anchor can be created.
*/
struct LocationDataModel: Hashable {
    private let anchorType: AnchorType
    private let coordinates: CLLocationCoordinate2D
    private let notes: String?
    private let name: String
    
    
    /**
        Initializes a new location data model.
     
        - parameter anchorType: The type of the anchor.
        - parameter location: The location of the data model.
        - parameter notes: Any additional notes about the location.
        - parameter name: The name of the location.
    */
    init(anchorType: AnchorType, coordinates: CLLocationCoordinate2D, notes: String? = "", name: String) {
        self.anchorType = anchorType
        self.coordinates = coordinates
        self.notes = notes
        self.name = name
    }
    
    /**
        Hashes the essential properties of this location data model.
     
        - parameter hasher: The hasher to use for computing the hash value.
    */
    func hash(into hasher: inout Hasher) {
            hasher.combine(anchorType)
            hasher.combine(coordinates.latitude)
            hasher.combine(coordinates.longitude)
            hasher.combine(notes ?? "")
            hasher.combine(name)
        }
    
    /**
        Returns a Boolean value that indicates whether two location data models are equal.
     
        - parameter lhs: The first location data model to compare.
        - parameter rhs: The second location data model to compare.
        - returns: `true` if the two models are equal; otherwise, `false`.
    */
    static func == (lhs: LocationDataModel, rhs: LocationDataModel) -> Bool {
        return lhs.anchorType == rhs.anchorType &&
            lhs.coordinates.latitude == rhs.coordinates.latitude &&
            lhs.coordinates.longitude == rhs.coordinates.longitude &&
            lhs.notes == rhs.notes &&
            lhs.name == rhs.name
    }
    
// MARK: Get functions for all private attributes
    func getAnchorType() -> AnchorType {
        return self.anchorType
    }
    
    func getLocationCoordinate() -> CLLocationCoordinate2D {
        return self.coordinates
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getNotes() -> String? {
        return self.notes
    }
}

// MARK: Types of anchors
enum AnchorType: String {
    case busStop = "Bus Stop"
    case externalDoor = "External Door"
    case bathroom = "Bathroom"
    case frontdesk = "Front Desk"
}
