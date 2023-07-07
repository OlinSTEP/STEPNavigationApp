//
//  DestinationsListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//
import SwiftUI
import CoreLocation

struct DestinationAnchorListView: View {
    @State var nearbyDistance: Double = 100
    @State var chosenStart: LocationDataModel?
    @State var chosenEnd: LocationDataModel?
    @State var outdoorsSelectedAsStart = false
    @State var showFilterPopup: Bool = false

    var body: some View {
        ScreenBackground {
            VStack {
                if showFilterPopup == false {
                    ScreenHeader(title: "Anchors", subtitle: "Within \(nearbyDistance.metersAsUnitString)")
                }
                AnchorListViewWithFiltering(nearbyDistance: $nearbyDistance, showFilterPopup: $showFilterPopup)
            }
        }
        .toolbar {
            if showFilterPopup == false {
                HeaderButton(label: "Filter", placement: .navigationBarTrailing) {
                    showFilterPopup = true
                }
            }
        }
        .navigationBarBackButtonHidden(showFilterPopup)
    }
}
