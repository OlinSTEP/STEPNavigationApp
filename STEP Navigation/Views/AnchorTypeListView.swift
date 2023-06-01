//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI
import CoreLocation

struct NearbyDistanceThresholdView: View {
//    var nearbyDistance: Binding<Double>
    
    @Binding var nearbyDistance: Double
    var focusOnNearbyDistanceValue: AccessibilityFocusState<Bool>.Binding
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Can't find what you're looking for?")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                Spacer()
            }
            Button {
                nearbyDistance = 1000
                focusOnNearbyDistanceValue.wrappedValue = true
            } label: {
                Text("Expand Search Radius")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: 300)
                    .foregroundColor(AppColor.black)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 5)
            .tint(AppColor.accent)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        }
        
//        HStack {
//            Text("Within \(nearbyDistance.wrappedValue, specifier: "%.0f") meters")
//                .font(.title)
//                .padding(.leading)
//            if showPopup == false {
//                Image(systemName: "chevron.down")
//                    .accessibilityLabel("Open Slider")
//            } else {
//                Image(systemName: "chevron.up")
//                    .accessibilityLabel("Close Slider")
//            }
//            Spacer()
//        }
//        .padding(.bottom, 20)
//        .onTapGesture {
//            showPopup.toggle()
//        }
//
//        if showPopup == true {
//            HStack {
//                Text("0").accessibility(hidden: true)
//                Slider(value: nearbyDistance, in: 0...1000, step: 10)
//                    .accessibility(value: Text("\(Int(nearbyDistance.wrappedValue)) meters"))
//                Text("1000").accessibility(hidden: true)
//            }
//            .frame(width: 300)
//            .padding(.bottom, 20)
//        }
    }
}

struct AnchorTypeListView: View {        
    @State var nearbyDistance: Double = 50
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
            VStack {
                // Sets the title text
                HStack {
                    Text("Destinations")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 0.5)
                
                HStack {
                    Text("Within \($nearbyDistance.wrappedValue, specifier: "%.0f") meters")
                        .font(.title)
                        .padding(.leading)
                        .accessibilityFocused($focusOnNearbyDistanceValue)
                    Spacer()
                }
                .padding(.bottom, 20)

            }
            .background(AppColor.accent)
            
            
            // The scroll view contains the main body of text
            ScrollView {
                VStack {
                    // Creates a navigation button for each anchor type
                    ForEach(anchorTypes, id: \.self) {
                        anchorType in
                        if anchorType != .indoorDestination {
                            NavigationLink (
                                destination: LocalAnchorListView(anchorType:  anchorType, nearbyDistance: nearbyDistance),
                                label: {
                                    Text("\(anchorType.rawValue)s")
                                        .font(.largeTitle)
                                        .bold()
                                        .padding(30)
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 140)
                                        .foregroundColor(AppColor.black)
                                })
                            .background(AppColor.accent)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                }
                Spacer()
                if nearbyDistance < 1000 {
                    NearbyDistanceThresholdView(nearbyDistance: $nearbyDistance, focusOnNearbyDistanceValue: $focusOnNearbyDistanceValue)
                }
            }
        }
    }
}
