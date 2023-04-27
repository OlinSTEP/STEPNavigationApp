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
    
    func getAllIndoorLocationModels() -> Set<LocationDataModel> {
        var indoorLocations = Set<LocationDataModel>()
        for anchorType in AnchorType.allCases {
            if anchorType.isIndoors, let anchorsOfThistype = allLocationModels[anchorType] {
                indoorLocations.formUnion(anchorsOfThistype)
            }
        }
        return indoorLocations
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
    private func getNearbyOutdoorDestinationTypes(models: Set<LocationDataModel>, location: CLLocationCoordinate2D, maxDistance: CLLocationDistance, withBuffer: CLLocationDistance = 0.0) -> [AnchorType] {
        var reachableTypesAsSet = Set<AnchorType>()
        for model in models {
            if model.getLocationCoordinate().distance(from: location) <= maxDistance + withBuffer &&
                !model.getAnchorType().isIndoors {
                reachableTypesAsSet.insert(model.getAnchorType())
            }
        }
        return Array(reachableTypesAsSet)
    }
    
    /**
            Returns a set containing all indoor categories within the specified distance from the specified location.
         
            - parameter model: the models to search through
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A list of all possible anchor categories
    */
    private func getNearbyIndoorDestinationTypes(models: Set<LocationDataModel>, location: CLLocationCoordinate2D, maxDistance: CLLocationDistance, withBuffer: CLLocationDistance = 0.0) -> [AnchorType] {
        var anchorTypesAsSet = Set<AnchorType>()
        var startingLocations: [LocationDataModel] = []
        for model in models {
            if model.getLocationCoordinate().distance(from: location) <= maxDistance + withBuffer {
                // possible start location
                startingLocations.append(model)
            }
        }
        let reachableSet = NavigationManager.shared.getReachability(from: startingLocations, outOf: models)
        let _ = reachableSet.map({
            anchorTypesAsSet.insert($0.getAnchorType())
        })
        return Array(anchorTypesAsSet)
    }

    
    /**
            Returns a set containing all location data models within the specified distance from the specified location.
         
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
         
            - returns: A list of all possible anchor categories
    */
    func getNearbyDestinationCategories(location: CLLocationCoordinate2D, maxDistance: CLLocationDistance, withBuffer: CLLocationDistance = 0.0) -> [AnchorType] {
        var allCategories: [AnchorType] = []
        let allModels = getAllDataModels()
        allCategories += getNearbyIndoorDestinationTypes(models: allModels, location: location, maxDistance: maxDistance, withBuffer: withBuffer)
        allCategories += getNearbyOutdoorDestinationTypes(models: allModels, location: location, maxDistance: maxDistance, withBuffer: withBuffer)
        return allCategories
    }
    
    private func getAllDataModels()->Set<LocationDataModel> {
        // TODO is this slow?
        let start = Date()
        var allModels = Set<LocationDataModel>()
        for (_, models) in allLocationModels {
            allModels.formUnion(models)
        }
        
        print("time \(-start.timeIntervalSinceNow)")
        return allModels
    }
    
    /**
            Returns a set containing all location data models within the specified distance from the specified location.
         
            - parameter anchorType: The type of the anchor.  If the anchorType is the special value
                    .indoorDestination, then any anchorType that has isIndoor set to true is okay
            - parameter location: The location to use as the center point for the distance calculation.
            - parameter maxDistance: The maximum distance in meters.
            - returns: A set containing all location data models within the specified distance from the specified location.
    */
    func getNearbyLocations(for anchorType: AnchorType,
                            location: CLLocationCoordinate2D,
                            maxDistance: CLLocationDistance,
                            withBuffer: CLLocationDistance = 0.0) -> Set<LocationDataModel> {
        var models = Set<LocationDataModel>()
        if anchorType == .indoorDestination {
            for anchorTypeCase in AnchorType.allCases.filter({ $0.isIndoors }) {
                models.formUnion(allLocationModels[anchorTypeCase] ?? [])
            }
        } else {
            models.formUnion(allLocationModels[anchorType] ?? [])
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
