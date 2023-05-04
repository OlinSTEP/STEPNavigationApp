//
//  LocationDataModel.swift
//  STEP Navigation
//
//  Created by Sam Coleman on 4/8/23.
//

import Foundation
import CoreLocation

/**
    A struct that represents a location data model where an anchor can be created.
*/
struct LocationDataModel: Hashable {
    private let anchorType: AnchorType
    private let associatedOutdoorFeature: String?
    private let coordinates: CLLocationCoordinate2D
    private let notes: String?
    private let name: String
    private let cloudAnchorID: String?
    
    
    /**
        Initializes a new location data model.
     
        - parameter anchorType: The type of the anchor.
        - parameter coordinates: the latitude and longitude of the model
        - parameter notes: Any additional notes about the location.
        - parameter name: The name of the location.
        - parameter cloudAnchorID: the anchor id associated with this model
    */
    init(anchorType: AnchorType,
         associatedOutdoorFeature: String?=nil,
         coordinates: CLLocationCoordinate2D,
         notes: String? = "",
         name: String,
         cloudAnchorID: String?=nil) {
        self.anchorType = anchorType
        self.associatedOutdoorFeature = associatedOutdoorFeature
        self.coordinates = coordinates
        self.notes = notes
        self.name = name
        self.cloudAnchorID = cloudAnchorID
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
    
    func getCloudAnchorID() -> String? {
        return self.cloudAnchorID
    }
    
    func getAssociatedOutdoorFeature() -> String? {
        return self.associatedOutdoorFeature
    }
}

/**
An enum representing the different types of anchors that can be used to categorize `LocationDataModel` objects.
 
- case busStop: Represents a bus stop anchor type.
- case externalDoor: Represents an external door anchor type.
- case bathroom: Represents a bathroom anchor type.
- case frontdesk: Represents a front desk anchor type.
*/
enum AnchorType: String, CaseIterable, Identifiable {
    var id: String {
        return rawValue
    }
    
    case busStop = "Bus Stop"
    case externalDoor = "External Door"
    case bathroom = "Bathroom"
    case frontdesk = "Front Desk"
    case junction = "Junction"
    case indoorDestination = "Indoor"
    case room = "Room"
    case exit = "Exit"
    case waterFountain = "Water Fountain"
    case path = "path"
    
    var isIndoors: Bool {
        switch self {
        case .bathroom:
            return true
        case .frontdesk:
            return true
        case .waterFountain:
            return true
        case .room:
            return true
        case .indoorDestination:
            return true
        case .junction:
            return true
        case .exit:
            return true
        default:
            return false
        }
    }
//    case indoorDestination = "Indoors (temporary category)"
}
