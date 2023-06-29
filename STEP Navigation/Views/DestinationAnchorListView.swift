//
//  DestinationsListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct DestinationAnchorListView: View {
    @ObservedObject var positionModel = PositioningModel.shared
    let anchorType: AnchorType
        
    @State var lastQueryLocation: CLLocationCoordinate2D?
    @State var nearbyDistance: Double
    @State var chosenStart: LocationDataModel?
    @State var chosenEnd: LocationDataModel?
    @State var outdoorsSelectedAsStart = false
    @State var anchors: [LocationDataModel] = []
    
    var body: some View {
<<<<<<< HEAD
        VStack {
            ScreenTitleComponent(titleText: "\(anchorType.rawValue)s")
                .onReceive(positionModel.$currentLatLon) { latLon in
                    guard let latLon = latLon else {
                        return
                    }
                    guard lastQueryLocation == nil || lastQueryLocation!.distance(from: latLon) > 5.0 else {
                        return
                    }
                    lastQueryLocation = latLon
                    anchors = Array(
                        DataModelManager.shared.getNearbyLocations(
                            for: anchorType,
                            location: latLon,
                            maxDistance: CLLocationDistance(nearbyDistance),
                            withBuffer: Self.getBufferDistance(positionModel.geoLocalizationAccuracy)
                        )
                    )
                    .sorted(by: {
                        $0.getName() < $1.getName()         // sort in alphabetical order (could also do by distance as we have done in another branch)
                    })
=======
        ScreenBackground {
            VStack {
                ScreenHeader(title: "\(anchorType.rawValue)s")
                ListOfAnchors(anchors: anchors, anchorSelectionType: anchorType.isIndoors ? .indoorEndingPoint : .outdoorEndingPoint)
            }
            .onReceive(positionModel.$currentLatLon) { latLon in
                guard let latLon = latLon else {
                    return
>>>>>>> frontend-refactor-2-electric-boogaloo
                }
                guard lastQueryLocation == nil || lastQueryLocation!.distance(from: latLon) > 5.0 else {
                    return
                }
                lastQueryLocation = latLon
                anchors = Array(
                    DataModelManager.shared.getNearbyLocations(
                        for: anchorType,
                        location: latLon,
                        maxDistance: CLLocationDistance(nearbyDistance),
                        withBuffer: Self.getBufferDistance(positionModel.geoLocalizationAccuracy)
                    )
                )
                .sorted(by: {
                    $0.getName() < $1.getName()         // sort in alphabetical order (could also do by distance as we have done in another branch)
                })
            }
        }
    }
    /// Compute the notion of "close enough" to display to the user.  This is a buffer distance added on top of the distance the user has already selected from the UI
    /// - Parameter accuracy: the current localization accuracy
    /// - Returns: the buffer distance to use
    static func getBufferDistance(_ accuracy: GeoLocationAccuracy)->CLLocationDistance {
        switch accuracy {
        case .none:
            return 100.0
        case .coarse:
            return 200.0
        case .low:
            return 200.0
        case .medium:
            return 50.0
        case .high:
            return 10.0
        }
    }
}
