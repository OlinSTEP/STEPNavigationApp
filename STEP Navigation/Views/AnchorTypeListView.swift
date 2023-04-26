//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI

struct AnchorTypeListView: View {    
    @ObservedObject var database = FirebaseManager.shared
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
        // Navigation Stack determines the Navigation Bar
        NavigationStack {
            VStack {
                // Sets the title text
                HStack {
                    Text("Anchor Groups")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.vertical, 20)
            }
            .background(AppColor.accent)
            
            // The scroll view contains the main body of text
            ScrollView {
                VStack {
                    // Creates a navigation button for each anchor type
                    ForEach(anchorTypes, id: \.self) {
                        anchorType in
                        NavigationLink (
                            destination: LocalizingView(anchorType: .indoorDestination),
                            label: {
                                Text(anchorType)
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
                    .padding(.top, 20)
                }
                Spacer()
            }
        }.onReceive(PositioningModel.shared.$geoLocalizationAccuracy) { newValue in
            if newValue != .none && anchorTypes.isEmpty {
                anchorTypes = DataModelManager.shared.getNearbyDestinationCategories(location: PositioningModel.shared.currentLatLon!, maxDistance: 100.0)
            }
        }
    }
}

struct AnchorTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorTypeListView()
    }
}
