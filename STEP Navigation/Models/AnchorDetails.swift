//
//  AnchorDetails.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/6/23.
//

import Foundation

struct AnchorDetails: Identifiable {
    var id = UUID()
    
    var name: String
    var notes: String
    var locationCoordinates: String //what format are we storing the location in??
    var distanceAway: Double //in meters
    var anchorType: AnchorType
    
    init(name: String, notes: String, locationCoordinates: String, distanceAway: Double, anchorType: AnchorType) {
        self.name = name
        self.notes = notes
        self.locationCoordinates = locationCoordinates
        self.distanceAway = distanceAway
        self.anchorType = anchorType
    }
    
    /// A default initializer that fills in default values for each field
    init() {
        self.init(name: "", notes: "", locationCoordinates: "", distanceAway: 0.0, anchorType: .busStop)
    }
}
