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

class DataModelManager: ObservableObject {
    public static var shared = DataModelManager()
    
    @Published var nearbyLocations: [LocationDataModel] = []
    // Dictionary that stores all the location models
    private var allLocationModels = [AnchorType: Set<LocationDataModel>]()
    
    private init() {
        do {
            let doors = try LocationDataModelParser.parse(from: "Olin_College_Doors", fileType: "geojson", anchorType: .externalDoor)
            multiAddDataModel(doors, anchorType: .externalDoor)
        }
        catch {
            print("Error parsing Olin_College_Doors")
        }
        
        do {
            let busStops = try LocationDataModelParser.parse(from: "mbtaBusStops", fileType: "json", anchorType: .busStop)
            multiAddDataModel(busStops, anchorType: .busStop)
        }
        catch {
            print("Error parsing mbtaBusStops")
        }
    }
    
   
    
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
     Returns a set of all AnchorTypes currently in the system
     */
    func getAnchorTypes() -> Set<AnchorType> {
        return Set(allLocationModels.keys + [.indoorDestination])
    }
    
    func getLocationDataModel(byName name: String)->LocationDataModel? {
        // TODO: this is very wasteful
        for (_, models) in allLocationModels {
            for model in models {
                if model.getName() == name {
                    return model
                }
            }
        }
        return nil
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
            Returns a set containing all outdoor within the specified distance from the specified location.
         
            - parameter model: the models to search through
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A list of all possible anchor categories
    */
    private func getNearbyOutdoorDestinationCategories(type: AnchorType, models: Set<LocationDataModel>, location: CLLocationCoordinate2D, maxDistance: CLLocationDistance, withBuffer: CLLocationDistance = 0.0) -> [String] {
        for model in models {
            if model.getLocationCoordinate().distance(from: location) <= maxDistance + withBuffer {
                return [type.rawValue]
            }
        }
        return []
    }
    
    /**
            Returns a set containing all indoor categories within the specified distance from the specified location.
         
            - parameter model: the models to search through
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A list of all possible anchor categories
    */
    private func getNearbyIndoorDestinationCategories(type: AnchorType, models: Set<LocationDataModel>, location: CLLocationCoordinate2D, maxDistance: CLLocationDistance, withBuffer: CLLocationDistance = 0.0) -> [String] {
        var categoriesAsSet = Set<String>()
        var startingLocations: [LocationDataModel] = []
        for model in models {
            if model.getLocationCoordinate().distance(from: location) <= maxDistance + withBuffer {
                // possible start location
                startingLocations.append(model)
            }
        }
        let reachableSet = NavigationManager.shared.getReachability(from: startingLocations, outOf: models)
        let _ = reachableSet.map({
            categoriesAsSet.insert($0.getAnchorCategory())
        })
        categoriesAsSet.remove("")
        return Array(categoriesAsSet).sorted()
    }

    
    /**
            Returns a set containing all location data models within the specified distance from the specified location.
         
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A list of all possible anchor categories
    */
    func getNearbyDestinationCategories(location: CLLocationCoordinate2D, maxDistance: CLLocationDistance, withBuffer: CLLocationDistance = 0.0) -> [String] {
        var allCategories: [String] = []
        for (type, models) in allLocationModels {
            if type == .indoorDestination {
                allCategories += getNearbyIndoorDestinationCategories(type: type, models: models, location: location, maxDistance: maxDistance, withBuffer: withBuffer)
            } else {
                allCategories += getNearbyOutdoorDestinationCategories(type: type, models: models, location: location, maxDistance: maxDistance, withBuffer: withBuffer)
            }
        }
        return allCategories
    }
    
    /**
            Returns a set containing all location data models within the specified distance from the specified location.
         
            - parameter anchorType: The type of the anchor.
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A set containing all location data models within the specified distance from the specified location.
    */
    func getNearbyLocations(for anchorType: AnchorType, location: CLLocationCoordinate2D, maxDistance: CLLocationDistance, withBuffer: CLLocationDistance = 0.0) -> Set<LocationDataModel> {
        guard let models = allLocationModels[anchorType] else {
            print("in the guard let")
            return Set<LocationDataModel>()
        }
        
        let threshold = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        return models.filter { model in
            let locationCoordinate = model.getLocationCoordinate()
            let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
            return location.distance(from: threshold) <= maxDistance + withBuffer
        }
    }
     
}

extension CLLocationCoordinate2D {
    func distance(from other: CLLocationCoordinate2D)->Double {
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: CLLocation(latitude: other.latitude,
                                                                                       longitude: other.longitude))
    }
}
