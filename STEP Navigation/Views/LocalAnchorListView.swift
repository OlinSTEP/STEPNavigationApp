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
    let location: CLLocationCoordinate2D
    
    private let listBackgroundColor = AppColor.grey
    private let listTextColor = AppColor.black
    
    @State private var nearbyDistance: Double = 10
    @State var showPopup = false
    @State var chosenStart: LocationDataModel?
    @State var chosenEnd: LocationDataModel?
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
            .padding(.top, 20)
            HStack {
                Text("Within \(nearbyDistance, specifier: "%.0f") meters")
                    .font(.title)
                    .padding(.leading)
                if showPopup == false {
                    Image(systemName: "chevron.down")
                } else {
                    Image(systemName: "chevron.up")
                }
                // want to make the chevron bigger/easier to see/etc - not sure how thought??
                Spacer()
            }
            .padding(.bottom, 20)
            .onTapGesture {
                showPopup.toggle()
                // in real life would want to present dropdown popup
            }
            
            if showPopup == true {
                HStack {
                    Text("0")
                    Slider(value: $nearbyDistance, in: 0...100, step: 10)
                    Text("100")
                }
                .frame(width: 300)
                .padding(.bottom, 20)
            }
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
        .navigationBarItems(
            trailing:
                Button(action: {
                    print("pressed settings")
                }) {
                    Image(systemName: "gearshape.fill")
                        .scaleEffect(1.5)
                        .foregroundColor(AppColor.black)
                }
        )
        if anchorType == .indoorDestination {
            Section(header: Text("Choose Start").font(.title).fontWeight(.heavy)) {
                ChooseAnchorComponentView(isStart: true,
                                          anchors: $anchors,
                                          allAnchors: $allAnchors,
                                          chosenAnchor: $chosenStart,
                                          otherAnchor: $chosenEnd)
            }
            Section(header: Text("Choose Destination").font(.title).fontWeight(.heavy)) {
                ChooseAnchorComponentView(isStart: false,
                                          anchors: $anchors,
                                          allAnchors: $allAnchors,
                                          chosenAnchor: $chosenEnd,
                                          otherAnchor: $chosenStart)
            }
            if let chosenStart = chosenStart, let chosenEnd = chosenEnd {
                NavigationLink (destination: NavigatingView(startAnchorDetails: chosenStart, destinationAnchorDetails: chosenEnd), label: {
                    Text("Navigate")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: 300)
                        .foregroundColor(AppColor.black)
                })
                .padding(.bottom, 20)
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
        } else {
            ChooseAnchorComponentView(isStart: false,
                                      anchors: $anchors,
                                      allAnchors: $allAnchors,
                                      chosenAnchor: $chosenEnd,
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

struct ChooseAnchorComponentView: View {
    var anchors: Binding<[LocationDataModel]>
    var allAnchors: Binding<[LocationDataModel]>
    let isStart: Bool
    var chosenAnchor : Binding<LocationDataModel?>
    var otherAnchor : Binding<LocationDataModel?>
    
    init(isStart: Bool,
         anchors: Binding<[LocationDataModel]>,
         allAnchors: Binding<[LocationDataModel]>,
         chosenAnchor: Binding<LocationDataModel?>,
         otherAnchor: Binding<LocationDataModel?>) {
        self.isStart = isStart
        self.anchors = anchors
        self.allAnchors = allAnchors
        self.chosenAnchor = chosenAnchor
        self.otherAnchor = otherAnchor
    }
    
    var body: some View {
        let candidateAnchors: [LocationDataModel] = otherAnchor.wrappedValue != nil ? allAnchors.wrappedValue : anchors.wrappedValue
        
        let isReachable: [Bool] = otherAnchor.wrappedValue == nil ? Array(repeating: true, count: anchors.count) : NavigationManager.shared.getReachability(from: otherAnchor.wrappedValue!, outOf: candidateAnchors)
        if candidateAnchors.isEmpty {
            VStack {
                Spacer()
                Text("Nothing nearby. Try widening your search radius.")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
                Text("\(anchors)" as String)
            }
            
        } else {
            ScrollView {
                VStack {
                    ForEach(0..<candidateAnchors.count, id: \.self) { idx in
                        if isReachable[idx] {
                            Button(action: {
                                if chosenAnchor.wrappedValue == candidateAnchors[idx] {
                                    chosenAnchor.wrappedValue = nil
                                } else {
                                    chosenAnchor.wrappedValue = candidateAnchors[idx]
                                }
                            }){
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
                            }
                            .foregroundColor(chosenAnchor.wrappedValue == candidateAnchors[idx] ? .yellow : .black)
                            .accessibilityAddTraits(chosenAnchor.wrappedValue == candidateAnchors[idx] ? [.isSelected] : [])
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
        LocalAnchorListView(anchorType: .busStop, location: CLLocationCoordinate2D(latitude: 42, longitude: -71))
    }
}
