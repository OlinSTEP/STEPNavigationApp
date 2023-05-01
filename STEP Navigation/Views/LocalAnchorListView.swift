//
//  AnchorListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct LocalAnchorListView: View {
//    @EnvironmentObject private var anchorData: AnchorData
//    let anchorType: AnchorDetails.AnchorType
    let anchorType: AnchorType
    let location: CLLocationCoordinate2D? = PositioningModel.shared.currentLatLon
    
    private let listBackgroundColor = AppColor.grey
    private let listTextColor = AppColor.black
    
    @State var nearbyDistance: Double
    @State var chosenStart: LocationDataModel?
    @State var chosenEnd: LocationDataModel?
    @State var outdoorsSelectedAsStart = false
    @ObservedObject var positionModel = PositioningModel.shared
    @State var anchors: [LocationDataModel] = []
    @State var allAnchors: [LocationDataModel] = []
    
    var body: some View {
        VStack {
            HStack {
                Text("\(anchorType.rawValue) Anchors")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.vertical, 20)
        }.onReceive(positionModel.$currentLatLon) { latLon in
            guard let latLon = latLon else {
                return
            }
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
        
        if anchorType == .indoorDestination {
            Section(header: Text("FROM").font(.title).fontWeight(.heavy)) {
                ChooseAnchorComponentView(anchorSelectionType: .startOfIndoorRoute,
                                          anchors: $anchors,
                                          allAnchors: $allAnchors,
                                          chosenAnchor: $chosenStart, outdoorsSelected: $outdoorsSelectedAsStart,
                                          otherAnchor: $chosenEnd)
            }
            Section(header: Text("TO").font(.title).fontWeight(.heavy)) {
                ChooseAnchorComponentView(anchorSelectionType: .endOfIndoorRoute,
                                          anchors: $anchors,
                                          allAnchors: $allAnchors,
                                          chosenAnchor: $chosenEnd,
                                          outdoorsSelected: $outdoorsSelectedAsStart,
                                          otherAnchor: $chosenStart)
            }
            if let chosenStart = chosenStart, let chosenEnd = chosenEnd {
                NavigationLink (destination: CloudAnchorsDetailView(startAnchorDetails: chosenStart, destinationAnchorDetails: chosenEnd), label: {
                    Text("Next")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: 300)
                        .foregroundColor(AppColor.black)
                })
                .padding(.bottom, 20)
                .padding(.top, 20)
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            } else if outdoorsSelectedAsStart, let chosenEnd = chosenEnd {
                // TODO: need to figure out the detail view for this
                NavigationLink (destination: NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: chosenEnd), label: {
                    Text("Navigate")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: 300)
                        .foregroundColor(AppColor.black)
                })
                .padding(.bottom, 20)
                .padding(.top, 20)
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
        } else {
            ChooseAnchorComponentView(anchorSelectionType: .destinationOutdoors,
                                      anchors: $anchors,
                                      allAnchors: $allAnchors,
                                      chosenAnchor: $chosenEnd,
                                      outdoorsSelected: $outdoorsSelectedAsStart,
                                      otherAnchor: $chosenStart)
        }
    }
    /// Compute the notion of "close enough" to display to the user.  This is a buffer distance added on top of the distance the user has already selected from the UI
    /// - Parameter accuracy: the current localization accuracy
    /// - Returns: the buffer distance to use
    static func getBufferDistance(_ accuracy: GeoLocationAccuracy)->CLLocationDistance {
        switch accuracy {
        case .none:
            return 100.0
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
        if candidateAnchors.isEmpty {
            VStack {
                Spacer()
                Text("Nothing nearby. Try widening your search radius.")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
        } else {
            ScrollView {
                VStack {
                    // TODO: this is pretty unwieldy (code sharing is pretty low here).  Maybe we should create a separate view type?
                    if anchorSelectionType == .startOfIndoorRoute {
                        Button(action: {
                            outdoorsSelected.wrappedValue.toggle()
                            chosenAnchor.wrappedValue = nil
                        }) {
                            HStack {
                                Text("Outside")
                                    .font(.title)
                                    .bold()
                                    .padding(30)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 100)
                            .background(outdoorsSelected.wrappedValue ? AppColor.accent : AppColor.grey)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .accessibilityAddTraits(outdoorsSelected.wrappedValue ? [.isSelected] : [])
                        }
                    }
                    ForEach(0..<candidateAnchors.count, id: \.self) { idx in
                        if anchorSelectionType == .destinationOutdoors {
                            NavigationLink (
                                destination: AnchorDetailView(anchorDetails: candidateAnchors[idx]),
                                label: {
                                    HStack {
                                        Text(candidateAnchors[idx].getName())
                                            .font(.title)
                                            .bold()
                                            .padding(30)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(minHeight: 140)
                                    .foregroundColor(AppColor.black)
                                })
                            .background(AppColor.accent)
                            .cornerRadius(20)
                            .padding(.horizontal)
                            
                        } else {
                            if isReachable[idx] {
                                VStack {
                                    Button {
                                        if anchorSelectionType == .startOfIndoorRoute {
                                            outdoorsSelected.wrappedValue = false
                                        }
                                        if chosenAnchor.wrappedValue == candidateAnchors[idx] {
                                            chosenAnchor.wrappedValue = nil
                                        } else {
                                            chosenAnchor.wrappedValue = candidateAnchors[idx]
                                        }
                                    } label: {
                                        HStack {
                                            Text(candidateAnchors[idx].getName())
                                                .font(.title)
                                                .bold()
                                                .padding(30)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 100)
                                        .background(chosenAnchor.wrappedValue == candidateAnchors[idx] ? AppColor.accent : AppColor.grey)
                                    }
                                }
                                .cornerRadius(20)
                                .padding(.horizontal)
                                .accessibilityAddTraits(chosenAnchor.wrappedValue == candidateAnchors[idx] ? [.isSelected] : [])

                            }
                        }
                    }
                    
                    //
                    //                        anchor in
                    //                        Toggle("test", isOn: anchor.isSelected)
                    //                        NavigationLink (
                    //                            destination: AnchorDetailView(anchorDetails: anchor),
                    //                            label: {
                    //                                HStack {
                    //                                    Text(anchor.getName())
                    //                                        .font(.title)
                    //                                        .bold()
                    //                                        .padding(30)
                    //                                        .multilineTextAlignment(.leading)
                    //                                    Spacer()
                    //                                }
                    //                                .frame(maxWidth: .infinity)
                    //                                .frame(minHeight: 140)
                    //                                .foregroundColor(AppColor.black)
                    //                            })
                    //                        .background(AppColor.grey)
                    //                        .cornerRadius(20)
                    //                        .padding(.horizontal)
                    //                    }
                    //                    .padding(.top, 20)
                }
                Spacer()
            }
        }
    }
}

struct AnchorListView_Previews: PreviewProvider {
    static var previews: some View {
        LocalAnchorListView(anchorType: .busStop, nearbyDistance: 100)
    }
}
