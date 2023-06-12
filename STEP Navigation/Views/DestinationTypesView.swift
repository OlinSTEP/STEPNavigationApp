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
    // Sets the appearance of the Navigation Bar using UIKit
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor(AppColor.accent)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        let anchorTypes = PositioningModel.shared.currentLatLon != nil ? DataModelManager.shared.getNearbyDestinationCategories(location: PositioningModel.shared.currentLatLon!, maxDistance: nearbyDistance) : []
        
        // Navigation Stack determines the Navigation Bar
        NavigationStack {
            let nearbyDistanceString = String(format: "%.0f", $nearbyDistance.wrappedValue) //calculating the nearbyDistance and turning it into a string to pass into ScreenTitleComponent
            ScreenTitleComponent(titleText: "Destinations", subtitleText: "Within \(nearbyDistanceString) meters")
            
            // The scroll view contains the main body of text
            ScrollView {
                VStack(spacing: 20) {
                    // Creates a navigation button for each anchor type
                    ForEach(anchorTypes, id: \.self) {
                        anchorType in
                        LargeButtonComponent_NavigationLink(destination: {
                            DestinationAnchorListView(anchorType: anchorType, nearbyDistance: nearbyDistance)
                        }, label: "\(anchorType.rawValue)s")
                    }
                }
                .padding(.top, 10)
                Spacer()
                if nearbyDistance < 1000 {
                    NearbyDistanceThresholdComponent(nearbyDistance: $nearbyDistance, focusOnNearbyDistanceValue: $focusOnNearbyDistanceValue)
                }
            }
        }
    }
}
