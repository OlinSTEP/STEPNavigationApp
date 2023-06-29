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
<<<<<<< HEAD
        let anchorTypes = PositioningModel.shared.currentLatLon != nil ? DataModelManager.shared.getNearbyDestinationCategories(location: PositioningModel.shared.currentLatLon!, maxDistance: nearbyDistance) : []

        VStack {
            let nearbyDistanceString = String(format: "%.0f", $nearbyDistance.wrappedValue)
            ScreenTitleComponent(titleText: "Destinations", subtitleText: "Within \(nearbyDistanceString) meters")

            ScrollView {
                VStack(spacing: 20) {
                    // Creates a navigation button for each anchor type
                    ForEach(anchorTypes, id: \.self) {
                        anchorType in
                        LargeButtonComponent_NavigationLink(destination: {
                            DestinationAnchorListView(anchorType: anchorType, nearbyDistance: nearbyDistance)
                        }, label: "\(anchorType.rawValue)s")
=======
        ScreenBackground {
            let anchorTypes = PositioningModel.shared.currentLatLon != nil ? DataModelManager.shared.getNearbyDestinationCategories(location: PositioningModel.shared.currentLatLon!, maxDistance: nearbyDistance) : []
            
            VStack {
                let nearbyDistanceString = String(format: "%.0f", $nearbyDistance.wrappedValue)
                ScreenHeader(title: "Destinations", subtitle: "Within \(nearbyDistanceString) meters")
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(anchorTypes, id: \.self) {
                            anchorType in
                            LargeNavigationLink(destination: DestinationAnchorListView(anchorType: anchorType, nearbyDistance: nearbyDistance), label: "\(anchorType.rawValue)s")
                        }
                    }
                    .padding(.top, 10)
                    Spacer()
                    if nearbyDistance < 1000 {
                        NearbyDistanceThreshold(nearbyDistance: $nearbyDistance, focusOnNearbyDistanceValue: $focusOnNearbyDistanceValue)
                            .padding(.bottom, 10)
>>>>>>> frontend-refactor-2-electric-boogaloo
                    }
                }
            }
        }
    }
}


