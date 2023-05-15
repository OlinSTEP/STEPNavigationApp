//
//  LocationDataModel.swift
//  STEP Navigation
//
//  Created by Sam Coleman on 4/8/23.
//

import Foundation
import CoreLocation

/// A struct that represents a location data model where an anchor can be created.
struct LocationDataModel: Hashable {
    /// the type of the anchor
    private let anchorType: AnchorType
    /// the name of the associated outodor feature (or nil if none exists)
    private let associatedOutdoorFeature: String?
    /// the latitude / longitude for the data model
    private let coordinates: CLLocationCoordinate2D
    /// the notes for the data model
    private let notes: String?
    /// the name of the data model
    private let name: String
    /// the identifier for this data model
    private let id: String
    /// the cloud anchor identifier of the data model (or nil if none exists)
    private let cloudAnchorID: String?
    
    /**
        Initializes a new location data model.
     
        - parameter anchorType: The type of the anchor.
        - parameter associatedOutdoorFeature: The id of the associated outdoor feature (or nil if N/A)
        - parameter coordinates: the latitude and longitude of the model
        - parameter notes: Any additional notes about the location.
        - parameter name: The name of the location.
        - parameter id: The identifier for this data model
        - parameter cloudAnchorID: the anchor id associated with this model
    */
    init(anchorType: AnchorType,
         associatedOutdoorFeature: String?=nil,
         coordinates: CLLocationCoordinate2D,
         notes: String? = "",
         name: String,
         id: String,
         cloudAnchorID: String?=nil) {
        self.anchorType = anchorType
        self.associatedOutdoorFeature = associatedOutdoorFeature
        self.coordinates = coordinates
        self.notes = notes
        self.name = name
        self.id = id
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
    
    /// Returns the anchor type
    /// - Returns: the anchor type of this model
    func getAnchorType() -> AnchorType {
        return self.anchorType
    }
    
    /// Return the location of the model
    /// - Returns: the location of the model as a latitude / longitude pair.
    func getLocationCoordinate() -> CLLocationCoordinate2D {
        return self.coordinates
    }
    
    /// Return the name of the model
    /// - Returns: the name of the model
    func getName() -> String {
        return self.name
    }
    
    /// Return the associated notes
    /// - Returns: the associated notes or nil if none exist
    func getNotes() -> String? {
        return self.notes
    }
    
    /// Return the associated cloud identifier
    /// - Returns: the cloud identifier or nil if none exists.
    func getCloudAnchorID() -> String? {
        return self.cloudAnchorID
    }
    
    /// Return the model identifier
    /// - Returns: the identifier
    func getID() -> String {
        return self.id
    }
    
    /// Return the outdoor feature associated with this data model
    /// - Returns: the name of the associated outdoor feature
    func getAssociatedOutdoorFeature() -> String? {
        return self.associatedOutdoorFeature
    }
}

/// An enum representing the different types of anchors that can be used to categorize `LocationDataModel` objects.
enum AnchorType: String, CaseIterable, Identifiable {
    var id: String {
        return rawValue
    }
    
    /// Represents a bus stop anchor type.
    case busStop = "Bus Stop"
    /// Represents an external door anchor type.
    case externalDoor = "External Door"
    /// Represents a bathroom anchor type.
    case bathroom = "Bathroom"
    /// Represents a front desk anchor type.
    case frontdesk = "Front Desk"
    /// Represents a junction anchor type (e.g., a hallway intersection)
    case junction = "Junction"
    /// Represents a generic indoor destination.  This is a placeholder value for when the specific category has not yet been set.
    case indoorDestination = "Indoor"
    /// Represents a room destination that doesn't fall into a more specific category
    case room = "Room"
    /// Represents a destination that is at the exit of the building
    case exit = "Exit"
    /// Represents a water fountain anchor type
    case waterFountain = "Water Fountain"
    /// Represents an anchor type that is part of a path (not a destination in and of itself)
    case path = "path"
    
    /// True if and only if the category corresponds to an indoor feature (i.e., not latitude / longitude based)
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
}
