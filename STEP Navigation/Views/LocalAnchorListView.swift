//
//  AnchorListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct LocalAnchorListView: View {
    @ObservedObject var positionModel = PositioningModel.shared

    let anchorType: AnchorType
    
    private let listBackgroundColor = AppColor.grey
    private let listTextColor = AppColor.dark
    
    @State var lastQueryLocation: CLLocationCoordinate2D?
    @State var nearbyDistance: Double
    @State var chosenStart: LocationDataModel?
    @State var chosenEnd: LocationDataModel?
    @State var outdoorsSelectedAsStart = false
    @State var anchors: [LocationDataModel] = []
    @State var allAnchors: [LocationDataModel] = []
    
    var body: some View {
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
            

            allAnchors = Array(
                DataModelManager.shared.getNearbyLocations(
                    for: anchorType,
                    location: latLon,
                    maxDistance: CLLocationDistance.infinity
                )
            )
            .sorted(by: {
                $0.getName() < $1.getName()         // sort in alphabetical order (could also do by distance as we have done in another branch)
            })
        }
        .background(AppColor.accent)
        
        ChooseAnchorComponentView(anchorSelectionType: .destinationOutdoors,
                                  anchors: $anchors,
                                  allAnchors: $allAnchors,
                                  chosenAnchor: $chosenEnd,
                                  outdoorsSelected: $outdoorsSelectedAsStart,
                                  otherAnchor: $chosenStart)
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

struct LocationDataModelWrapper: Hashable {
    var model: LocationDataModel
    var isSelected: Bool
}

enum AnchorSelectionType {
    case startOfIndoorRoute
    case endOfIndoorRoute
    case destinationOutdoors
}

/// This type is used to specify to the ChooseAnchorComponentView whether we are choosing the anchor in the context of indoor or outdoor navigation.  Further, if indoors, we differentiate between the start and end of a route
struct ChooseAnchorComponentView: View {
    var anchors: Binding<[LocationDataModel]>
    var allAnchors: Binding<[LocationDataModel]>
    let anchorSelectionType: AnchorSelectionType
    var chosenAnchor : Binding<LocationDataModel?>
    var otherAnchor : Binding<LocationDataModel?>
    var outdoorsSelected: Binding<Bool>
    
    @AccessibilityFocusState var focusedOnNavigate
    
    init(anchorSelectionType: AnchorSelectionType,
         anchors: Binding<[LocationDataModel]>,
         allAnchors: Binding<[LocationDataModel]>,
         chosenAnchor: Binding<LocationDataModel?>,
         outdoorsSelected: Binding<Bool>,
         otherAnchor: Binding<LocationDataModel?>) {
        self.anchorSelectionType = anchorSelectionType
        self.anchors = anchors
        self.allAnchors = allAnchors
        self.chosenAnchor = chosenAnchor
        self.outdoorsSelected = outdoorsSelected
        self.otherAnchor = otherAnchor
    }
    
    func getReachabilityMask(candidateAnchors: [LocationDataModel])->[Bool] {
        let isReachable: [Bool]
        if anchorSelectionType == .endOfIndoorRoute && outdoorsSelected.wrappedValue {
            isReachable = NavigationManager.shared.getReachabilityFromOutdoors(outOf: candidateAnchors)
        } else {
            isReachable = otherAnchor.wrappedValue == nil ? Array(repeating: true, count: anchors.count) : NavigationManager.shared.getReachability(from: otherAnchor.wrappedValue!, outOf: candidateAnchors)
        }
        return isReachable
    }
    
    var body: some View {
        let candidateAnchors: [LocationDataModel] = otherAnchor.wrappedValue != nil ? allAnchors.wrappedValue : anchors.wrappedValue
        let isReachable = getReachabilityMask(candidateAnchors: candidateAnchors)

        VStack {
            ScrollView {
                if anchorSelectionType == .startOfIndoorRoute,
                   let otherAnchor = otherAnchor.wrappedValue,
                   NavigationManager.shared.getReachabilityFromOutdoors(outOf: [otherAnchor]).first == true {
                    LargeButtonComponent_Button(label: "Start Outside", labelColor: outdoorsSelected.wrappedValue ? AppColor.dark : AppColor.grey, backgroundColor: outdoorsSelected.wrappedValue ? AppColor.accent : AppColor.dark, action: {
                        outdoorsSelected.wrappedValue.toggle()
                        chosenAnchor.wrappedValue = nil
                    })
                        .accessibilityAddTraits(outdoorsSelected.wrappedValue ? [.isSelected] : [])
                        .padding(.vertical, 10)

                    }
                
                ForEach(0..<candidateAnchors.count, id: \.self) { idx in
                    if anchorSelectionType == .destinationOutdoors {
                        LargeButtonComponent_NavigationLink(destination: {
                                AnchorDetailView(anchorDetails: candidateAnchors[idx])
                        }, label: "\(candidateAnchors[idx].getName())", labelTextSize: .title, labelTextLeading: true)
                        .padding(.vertical, 10)

                        } else {
                            if isReachable[idx] {
                                VStack {
                                    LargeButtonComponent_Button(label: "\(candidateAnchors[idx].getName())", backgroundColor: chosenAnchor.wrappedValue == candidateAnchors[idx] ? AppColor.accent : AppColor.grey, action: {
                                        if anchorSelectionType == .startOfIndoorRoute {
                                            outdoorsSelected.wrappedValue = false
                                        }
                                        if chosenAnchor.wrappedValue == candidateAnchors[idx] {
                                            chosenAnchor.wrappedValue = nil
                                        } else {
                                            chosenAnchor.wrappedValue = candidateAnchors[idx]
                                        }
                                    })
                                    .accessibilityAddTraits(chosenAnchor.wrappedValue == candidateAnchors[idx] ? [.isSelected] : [])
                                    .padding(.vertical, 10)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.top, 10)
    }
}
