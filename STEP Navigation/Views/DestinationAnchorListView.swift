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


struct AnchorListViewWithFiltering: View {
    @Binding var nearbyDistance: Double
    @Binding var showFilterPopup: Bool
    
    var settingsManager = SettingsManager.shared
    @ObservedObject var positionModel = PositioningModel.shared
    
    @State var allAnchors: [LocationDataModel] = []
    @State var filteredAnchors: [LocationDataModel] = []
    @State var allAnchorTypes: [AnchorType] = []
    @State var selectedAnchorTypes: [AnchorType] = []
    
    @State var lastQueryLocation: CLLocationCoordinate2D?
    
    let bufferDistance = LocationHelper.getBufferDistance(PositioningModel.shared.geoLocalizationAccuracy)
    
    var body: some View {
        Group {
            ZStack {
                VStack {
//                    ScreenHeader(title: "Anchors", subtitle: "Within \(nearbyDistance.metersAsUnitString)")
                    ScrollView {
                        ListOfAnchors(anchors: filteredAnchors, anchorSelectionType: .indoorEndingPoint)
                        Spacer()
                        if nearbyDistance < 1000 {
                            ExpandSearch(action: {
                                nearbyDistance = 1000
                                selectedAnchorTypes = allAnchorTypes
                            })
                                .padding(.bottom, 10)
                        }
                    }
                }
                .onReceive(positionModel.$currentLatLon) { latLon in
                    guard let latLon = latLon else {
                        return
                    }
                    guard lastQueryLocation == nil || lastQueryLocation!.distance(from: latLon) > 5.0 else {
                        return
                    }
                    lastQueryLocation = latLon
                    allAnchors = Array(
                        DataModelManager.shared.getNearbyIndoorLocations(
                            location: latLon,
                            maxDistance: CLLocationDistance(nearbyDistance),
                            withBuffer: bufferDistance
                        )
                    )
                    .sorted(by: {
                        $0.getName() < $1.getName() // TODO: can we sort by nearby distance instead of A to Z
                    })
                }
                if showFilterPopup {
                    AnchorTypeFilter(allAnchorTypes: allAnchorTypes, selectedAnchorTypes: $selectedAnchorTypes, showPage: $showFilterPopup)
                        .onDisappear() {
                            selectedAnchorTypes = settingsManager.loadfilteredTypes()
                        }
                }
            }
        }
        .onAppear() {
            allAnchorTypes = Array(DataModelManager.shared.getAnchorTypes()).sorted(by: {
                $0.rawValue < $1.rawValue
            })
            selectedAnchorTypes = settingsManager.loadfilteredTypes()
            filteredAnchors = allAnchors.filter {
                anchor in
                selectedAnchorTypes.contains(anchor.getAnchorType())
            }
        }
        .onChange(of: selectedAnchorTypes) { newAnchorTypes in
            filteredAnchors = allAnchors.filter { anchor in
                newAnchorTypes.contains(anchor.getAnchorType())
            }
        }
//        .toolbar {
//            if showFilterPopup == false {
//                HeaderButton(label: "Filter", placement: .navigationBarTrailing) {
//                    showFilterPopup = true
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(showFilterPopup)
    }
}

struct AnchorTypeFilter: View {
    var settingsManager = SettingsManager.shared
    var allAnchorTypes: [AnchorType]
    @Binding var selectedAnchorTypes: [AnchorType]
    @Binding var showPage: Bool
    
    var body: some View {
        VStack {
            ScreenHeader()
            ScrollView {
                Divider()
                    .overlay(AppColor.foreground)
                ForEach(allAnchorTypes, id: \.self) { option in
                    Button(action: {
                        if selectedAnchorTypes.contains(option) {
                            selectedAnchorTypes.removeAll(where: { $0 == option })
                        } else {
                            selectedAnchorTypes.append(option)
                        }
                    }, label: {
                        HStack {
                            Text(option.rawValue)
                                .font(.title2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if selectedAnchorTypes.contains(option) {
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                    .foregroundColor(AppColor.foreground)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    Divider()
                        .overlay(AppColor.foreground)
                }
            }
            Spacer()
            SmallButton(action: {
                showPage = false
                settingsManager.savefilteredTypes(filteredTypes: selectedAnchorTypes)
            }, label: "Apply Filters")
            SmallButton(action: {
                showPage = false
                settingsManager.resetfilteredTypes()
            }, label: "Reset Filters", invert: true)
        }
        .onAppear() {
            selectedAnchorTypes = settingsManager.loadfilteredTypes()
        }
        .accessibilityAddTraits(.isModal)
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
