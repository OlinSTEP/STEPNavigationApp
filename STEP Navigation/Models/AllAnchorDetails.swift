//
//  AllAnchorDetails.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import Foundation

extension AnchorDetails {
    static let testAnchors: [AnchorDetails] = [
        AnchorDetails(name: "Test Anchor 1 - Bus Stop This is a long title", notes: "Notes about this location. Lots of notes here. okjasdf asdlfk;hjsad gja awerio s adhf sajksh asdkjfah dfweqrkjg hadsfkawds fadsf.", locationCoordinates: "coordinates here", anchorType: .busStop),
        AnchorDetails(name: "Test 2", notes: "Notes about this location", locationCoordinates: "coordinates here", anchorType: .busStop),
        AnchorDetails(name: "Test Anchor 3 - Door", notes: "Notes about this location", locationCoordinates: "coordinates here", anchorType: .externalDoor),
        AnchorDetails(name: "Test Anchor 4 - Bathroom", notes: "Notes about this location", locationCoordinates: "coordinates here", anchorType: .bathroom),
    ]
}
