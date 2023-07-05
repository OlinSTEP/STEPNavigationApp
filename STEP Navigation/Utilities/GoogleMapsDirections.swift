//
//  GoogleMapsDirections.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 7/3/23.
//

import Foundation
import CoreLocation
import Polyline

/// This series of structs is used to decode data from the Google directions API
struct GoogleMapsDirections: Decodable {
    struct GoogleMapsRoute: Decodable {
        struct GoogleMapsLeg: Decodable {
            struct GoogleMapsStep: Decodable {
                struct GoogleMapsPolyline: Decodable {
                    let points: String
                }
                struct GoogleMapsLatLon: Decodable {
                    let lat: Double
                    let lng: Double
                }
                let start_location : GoogleMapsLatLon
                let polyline: GoogleMapsPolyline
            }
            let steps: [GoogleMapsStep]
        }
        let legs: [GoogleMapsLeg]
    }
    let routes: [GoogleMapsRoute]
    
    func toLatLonWaypoints()->[CLLocationCoordinate2D]? {
        // for now, choose the first route
        guard let route = routes.first else {
            return nil
        }
        // the route should always have exactly one leg
        guard let leg = route.legs.first else {
            return nil
        }
        var latLons: [CLLocationCoordinate2D] = []
        for step in leg.steps {
            latLons.append(CLLocationCoordinate2D(latitude: step.start_location.lat, longitude: step.start_location.lng))
            let polyline = Polyline(encodedPolyline: step.polyline.points)
            if let decodedCoordinates = polyline.coordinates {
                // the polyline gives a better definition to the route legs, but it is not accurate enough to follow exactly.  We're probably better off just omitting the polyline points and instead giving directions that reference the specific step (e.g., head south on Olin Way)
                latLons += decodedCoordinates
            }
        }
        return latLons
    }
}
