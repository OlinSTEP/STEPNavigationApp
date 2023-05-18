//
//  GeospatialData.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 5/1/23.
//

import Foundation
import CoreLocation
import ARKit
import ARCoreGeospatial


/// Geospatial data gathered from a `GARGeospatialTransform`.
struct GeospatialData {
    /// The location of the pose
    let location: CLLocationCoordinate2D
    /// The altitude of the pose
    let altitude: Double
    /// the accuracy in the altitude direction
    let verticalAccuracy: Double
    /// The accuracy in the ground plane
    let horizontalAccuracy: Double
    /// The accuracy in the yaw directino
    let yawAccuracy: Double
    /// The orientation relative to the East-Up-South coordinate system
    let eastUpSouthQTarget: simd_quatf
    
    /// Initialize this object from a `GARGeospatialTransform`
    /// - Parameter arCoreGeospatial: the data used for initialization
    init(arCoreGeospatial: GARGeospatialTransform) {
        location = arCoreGeospatial.coordinate
        altitude = arCoreGeospatial.altitude
        verticalAccuracy = arCoreGeospatial.verticalAccuracy
        horizontalAccuracy = arCoreGeospatial.horizontalAccuracy
        yawAccuracy = arCoreGeospatial.orientationYawAccuracy
        eastUpSouthQTarget = arCoreGeospatial.eastUpSouthQTarget
    }
    
    /// Initialize the object from key-value pairs.  This is useful when data is fetched from a database.
    /// - Parameter keyValues: the data that will be decoded to create the object.
    init?(fromDict keyValues: [String: Any]) {
        guard let location = keyValues["location"] as? [String: Double],
              let latitude = location["latitude"],
              let longitude = location["longitude"],
              let horizontalAccuracy = keyValues["horizontalAccuracy"] as? Double,
              let altitude = keyValues["altitude"] as? Double,
              let verticalAccuracy = keyValues["verticalAccuracy"] as? Double,
              let eastUpSouthQTarget = keyValues["eastUpSouthQTarget"] as? [String: Any],
              let axis = eastUpSouthQTarget["axis"] as? [Double],
              axis.count == 3,
              let angle = eastUpSouthQTarget["angle"] as? Double,
              let yawAccuracy = keyValues["yawAccuracy"] as? Double else {
            return nil
        }
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.horizontalAccuracy = horizontalAccuracy
        self.altitude = altitude
        self.yawAccuracy = yawAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.eastUpSouthQTarget = simd_quatf(angle: Float(angle), axis: simd_float3(x: Float(axis[0]), y: Float(axis[1]), z: Float(axis[2])))
    }
    
    /// Convert to a dictionary representation.  This is useful for storing in a database or logging/
    /// - Returns: The key-value pairs of the dictionary containing the relevant data.
    func asDict()->[String: Any] {
        return [
            "location": ["latitude": location.latitude,
                         "longitude": location.longitude],
            "altitude": altitude,
            "verticalAccuracy": verticalAccuracy,
            "horizontalAccuracy": horizontalAccuracy,
            "yawAccuracy": yawAccuracy,
            "eastUpSouthQTarget": ["axis": [eastUpSouthQTarget.axis.x,
                                            eastUpSouthQTarget.axis.y,
                                            eastUpSouthQTarget.axis.z],
                                   "angle": eastUpSouthQTarget.angle]
        ]
    }
}
