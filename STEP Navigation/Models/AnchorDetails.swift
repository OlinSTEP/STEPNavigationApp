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
    var anchorType: AnchorType
    
    init(name: String, notes: String, locationCoordinates: String, anchorType: AnchorType) {
        self.name = name
        self.notes = notes
        self.locationCoordinates = locationCoordinates
        self.anchorType = anchorType
    }
    
    init() {
        self.init(name: "", notes: "", locationCoordinates: "", anchorType: .busStop)
    }
    
    enum AnchorType: String, CaseIterable {
        case busStop = "Bus Stop"
        case externalDoor = "External Door"
        case bathroom = "Bathroom"
        case frontdesk = "Front Desk"
        case elevator = "Elevator"
        case stairs = "Stairs"
        case room = "Room"
    }
}
