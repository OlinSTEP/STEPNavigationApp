//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI
import CoreLocation

struct NearbyDistanceThresholdView: View {
    var nearbyDistance: Binding<Double>
    @State var showPopup = false
    var body: some View {
        HStack {
            Text("Within \(nearbyDistance.wrappedValue, specifier: "%.0f") meters")
                .font(.title)
                .padding(.leading)
            if showPopup == false {
                Image(systemName: "chevron.down")
                    .accessibilityLabel("Open Slider")
            } else {
                Image(systemName: "chevron.up")
                    .accessibilityLabel("Close Slider")
            }
            Spacer()
        }
        .padding(.bottom, 20)
        .onTapGesture {
            showPopup.toggle()
        }
        
        if showPopup == true {
            HStack {
                Text("0").accessibility(hidden: true)
                Slider(value: nearbyDistance, in: 0...1000, step: 10)
                    .accessibility(value: Text("\(Int(nearbyDistance.wrappedValue)) meters"))
                Text("1000").accessibility(hidden: true)
            }
            .frame(width: 300)
            .padding(.bottom, 20)
        }
    }
}

struct AnchorTypeListView: View {        
    @State var nearbyDistance: Double = 300
    @State var hasLocalized = false
    @State var anchorTypes: [String] = []
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
                
                NearbyDistanceThresholdView(nearbyDistance: $nearbyDistance)
            }
            .background(AppColor.accent)
            
            
            // The scroll view contains the main body of text
            ScrollView {
                VStack {
                    // Creates a navigation button for each anchor type
                    ForEach(anchorTypes, id: \.self) {
                        anchorType in
                        if anchorType != .indoorDestination {
                            //currently pass .bathroom into the navigationLink; need to pass in the anchorType instead, but since the anchor type is currently a string (I think?) it can't be passed through
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
            }
        }
    }
}

//struct AnchorTypeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnchorTypeListView()
//    }
//}
