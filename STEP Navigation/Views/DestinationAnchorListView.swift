//
//  DestinationsListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//
import SwiftUI
import CoreLocation

struct DestinationAnchorListView: View {
    var settingsManager = SettingsManager.shared

    @State var nearbyDistance: Double = 100
    @ObservedObject var positionModel = PositioningModel.shared
    @State var showFilterPopup: Bool = false
    
    @State var allAnchors: [LocationDataModel] = []
    @State var filteredAnchors: [LocationDataModel] = []
    @State var allAnchorTypes: [AnchorType] = []
    @State var selectedAnchorTypes: [AnchorType] = []
    
    @State var lastQueryLocation: CLLocationCoordinate2D?
    @State var chosenStart: LocationDataModel?
    @State var chosenEnd: LocationDataModel?
    @State var outdoorsSelectedAsStart = false
    
    var body: some View {
        ScreenBackground {
            ZStack {
                VStack {
                    ScreenHeader(title: "Anchors", subtitle: "Within \(nearbyDistance.metersAsUnitString)")
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
                            withBuffer: Self.getBufferDistance(positionModel.geoLocalizationAccuracy)
                        )
                    )
                    .sorted(by: {
                        $0.getName() < $1.getName() // TODO: can we sort by nearby distance instead of A to Z
                    })
                    print("anchors at list view: \(allAnchors)")
                }
                if showFilterPopup {
                    AnchorTypeFilter(allAnchorTypes: allAnchorTypes, showPage: $showFilterPopup)
                        .onDisappear() {
                            filteredAnchors = allAnchors.filter { anchor in
                                selectedAnchorTypes.contains(anchor.getAnchorType())
                            }
                        }
                }
            }
        }
        .onAppear() {
            allAnchorTypes = Array(DataModelManager.shared.getAnchorTypes()).sorted(by: {
                $0.rawValue < $1.rawValue
            })
            selectedAnchorTypes = settingsManager.loadfilteredTypes()
            filteredAnchors = allAnchors
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
    
    /// Compute the notion of "close enough" to display to the user.  This is a buffer distance added on top of the distance the user has already selected from the UI
    /// - Parameter accuracy: the current localization accuracy
    /// - Returns: the buffer distance to use
    static func getBufferDistance(_ accuracy: GeoLocationAccuracy) -> CLLocationDistance {
        switch accuracy {
        case .none:
            return 100.0
        case .coarse, .low:
            return 200.0
        case .medium:
            return 50.0
        case .high:
            return 10.0
        }
    }
}

struct AnchorTypeFilter: View {
    var settingsManager = SettingsManager.shared
    var allAnchorTypes: [AnchorType]
    @State var selectedAnchorTypes: [AnchorType] = []
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
