//
//  DestinationsTypeView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI
import CoreLocation


struct DestinationTypesView: View {
    @State var nearbyDistance: Double = 100
    @State var hasLocalized = false
    @State var anchorTypes: [String] = []

    @AccessibilityFocusState var focusOnNearbyDistanceValue

    var body: some View {
        ScreenBackground {
            let anchorTypes = PositioningModel.shared.currentLatLon != nil ? DataModelManager.shared.getNearbyDestinationCategories(location: PositioningModel.shared.currentLatLon!, maxDistance: nearbyDistance) : []
            
            VStack {
                ScreenHeader(title: "Destinations", subtitle: "Within \(nearbyDistance.metersAsUnitString)")
                
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(anchorTypes, id: \.self) {
                            anchorType in
                            LargeNavigationLink(destination: DestinationAnchorListView(anchorType: anchorType, nearbyDistance: nearbyDistance), label: "\(anchorType.rawValue)s")
                        }
                    }
                    .padding(.top, 12)
                    Spacer()
                    if nearbyDistance < 1000 {
                        NearbyDistanceThreshold(nearbyDistance: $nearbyDistance, focusOnNearbyDistanceValue: $focusOnNearbyDistanceValue)
                            .padding(.bottom, 10)
                    }
                }
            }
        }
    }
}
