//
//  AllAnchorDetails.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation

extension AnchorDetails {
    static let testAnchors: [AnchorDetails] = [
        AnchorDetails(name: "Test Anchor 1", notes: "Notes about this location", locationAddress: "1000 Test Way", locationCoordinates: "coordinates here", anchorType: .busStop),
        AnchorDetails(name: "Test Anchor 2", notes: "Notes about this location", locationAddress: "1002 Test Way", locationCoordinates: "coordinates here", anchorType: .busStop),
        AnchorDetails(name: "Test Anchor 3", notes: "Notes about this location", locationAddress: "1003 Test Way", locationCoordinates: "coordinates here", anchorType: .externalDoor),
    ]
}
