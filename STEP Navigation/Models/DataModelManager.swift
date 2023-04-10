//
//  DataModelManager.swift
//  STEP Navigation
//
//  Created by Sam Coleman on 4/8/23.
//

import Foundation
import CoreLocation

/**
 A class that manages the storage of `LocationDataModel` objects.
 
 It stores the resulting data models in a dictionary, where the keys are the `AnchorType` enum cases and the values are sets of `LocationDataModel` objects.
 
 The class provides methods to retrieve data models by anchor type, location, and distance. It also provides a method to return all data models in the dictionary.
 */

class DataModelManager {
    
    // Dictionary that stores all the location models
    private var allLocationModels = [AnchorType: Set<LocationDataModel>]()
    
    /**
        Adds a new location data model to the allDataModels dictionary.
     
        - parameter dataModel: The location data model to add.
    */
    func addDataModel(_ dataModel: LocationDataModel) {
        var models = allLocationModels[dataModel.getAnchorType()] ?? []
        models.insert(dataModel)
        allLocationModels[dataModel.getAnchorType()] = models
    }
    
    /**
     Add a set of new location data models to the allDataModels dictionary item for that AnchorType
     
     - parameter dataModels: The set of data models to add (they must all be the same anchorType)
     */
    func multiAddDataModel(_ dataModels: Set<LocationDataModel>, anchorType: AnchorType) {
        var models = allLocationModels[anchorType] ?? []
        models.formUnion(dataModels)
        allLocationModels[anchorType] = models
        
    }
    
    /**
        Returns dictionary with all location models
        Note: this is primiarly used for debuggina and should not be used in finalized code
     */
    func getAllLocationModels() -> [AnchorType: Set<LocationDataModel>] {
        return allLocationModels
    }
    
    /**
     Returns an array of all AnchorTypes currently in the system
     */
    func getAnchorTypes() -> [AnchorType] {
        return Array(allLocationModels.keys)
    }
     
    /**
      Returns set of all locations of a given anchorType
      
      - parameter anchorType: The type of anchor.
      
      - returns: A set containing all location data models of the specified anchor type.
      */
    func getLocationsByType(anchorType: AnchorType) -> Set<LocationDataModel> {
        guard let locations = allLocationModels[anchorType] else { return Set<LocationDataModel>() }
        return locations
    }
    
    /**
            Returns a set containing all location data models within the specified distance from the specified location.
         
            - parameter anchorType: The type of the anchor.
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A set containing all location data models within the specified distance from the specified location.
    */
    func getNearbyLocations(for anchorType: AnchorType, location: CLLocationCoordinate2D, maxDistance: CLLocationDistance) -> Set<LocationDataModel> {
        guard let models = allLocationModels[anchorType] else {
            print("in the guard let")
            return Set<LocationDataModel>()
        }
        
        let threshold = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return models.filter { model in
            let locationCoordinate = model.getLocationCoordinate()
            let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            return location.distance(from: threshold) <= maxDistance
        }
    }
     
}
