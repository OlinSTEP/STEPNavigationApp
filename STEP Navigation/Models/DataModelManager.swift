//
//  DataModelManager.swift
//  STEP Navigation
//
//  Created by Sam Coleman on 4/8/23.
//

import Foundation
import CoreLocation

class DataModelManager {
    
    // Dictionary that stores all the location models
    private var allLocationModels = [AnchorType: [LocationDataModel]]()
    
    /**
        Adds a new location data model to the allDataModels dictionary.
     
        - parameter dataModel: The location data model to add.
    */
    func addDataModel(_ dataModel: LocationDataModel) {
        var models = allLocationModels[dataModel.getAnchorType()] ?? []
        models.append(dataModel)
        allLocationModels[dataModel.getAnchorType()] = models
    }
    
    /**
        Returns dictionary with all location models
        Note: this is primiarly used for debuggina and should not be used in finalized code
     */
    func getAllLocationModels() -> [AnchorType: [LocationDataModel]] {
        return allLocationModels
    }
    
    /**
     Returns an array of all AnchorTypes currently in the system
     */
    func getAnchorTypes() -> [AnchorType] {
        return Array(allLocationModels.keys)
    }
     
    /**
      Returns list of all locations of a given anchorType
      
      - parameter anchorType: The type of anchor.
      
      - returns: A list containing all location data models of the specified anchor type.
      */
    func getLocationsByType(anchorType: AnchorType) -> [LocationDataModel] {
        guard let locations = allLocationModels[anchorType] else { return [] }
        return locations
    }
    
    /**
            Returns a dictionary containing all location data models within the specified distance from the specified location.
         
            - parameter anchorType: The type of the anchor.
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A dictionary containing all location data models within the specified distance from the specified location.
    */
    func getNearbyLocations(for anchorType: AnchorType, location: CLLocationCoordinate2D, maxDistance: CLLocationDistance) -> [LocationDataModel] {
        guard let models = allLocationModels[anchorType] else {
            return []
        }
        
        let threshold = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return models.filter { model in
            let locationCoordinate = model.getLocationCoordinate()
            let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            return location.distance(from: threshold) <= maxDistance
        }
    }
     
}

