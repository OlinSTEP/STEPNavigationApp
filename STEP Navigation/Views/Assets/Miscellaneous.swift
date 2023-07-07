//
//  Miscellaneous.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailsText: View {
    let title: String
    let distanceAway: Double
    let locationNotes: String
    let textColor: Color
    
    init(title: String, distanceAway: Double, locationNotes: String = "", textColor: Color = AppColor.foreground) {
        self.title = title
        self.distanceAway = distanceAway
        self.locationNotes = locationNotes
        self.textColor = textColor
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            
            HStack {
                Text("\(distanceAway.metersAsUnitString) away")
                        .font(.title)
                        .padding(.horizontal)
                Spacer()
            }
            VStack {
                HStack {
                    Text("Location Notes")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 1)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                ScrollView {
                    HStack {
                        if locationNotes.isEmpty {
                            Text("No notes available for this location.")
                        } else {
                            Text(locationNotes)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
        }
        .foregroundColor(AppColor.foreground)
    }
}

struct ChecklistItem: View {
    @Binding var toggle: Bool
    let label: String
    let textColor: Color
    
    init(toggle: Binding<Bool>, label: String, textColor: Color = AppColor.foreground) {
            self._toggle = toggle
            self.label = label
            self.textColor = textColor
        }
    
    var body: some View {
        VStack {
            Button(action: {
                toggle.toggle()
            }) {
                HStack {
                    Text(label)
                        .font(.title)
                        .padding(8)
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.leading)
                        .bold(toggle)
                    Spacer()
                    if toggle {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .bold()
                            .foregroundColor(textColor)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ScreenBackground<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            content
                .padding(.bottom, 48)
        }
            .background(AppColor.background)
            .edgesIgnoringSafeArea([.bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExpandSearch: View {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Can't find what you're looking for?")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .foregroundColor(AppColor.foreground)
                Spacer()
            }
            
            SmallButton(action: {
                action()
            }, label: "Expand Search Radius and Remove Filters")
        }
    }
}

//struct ListOfAnchors: View {
//    var anchors: [LocationDataModel]
//    let anchorSelectionType: AnchorSelectionType
//    @State var filteredTypes: [String]?
//
//    func getReachabilityMask(candidateAnchors: [LocationDataModel])->[Bool] {
//        switch anchorSelectionType {
//        case .indoorStartingPoint(let selectedDestination):
//            return NavigationManager.shared.getReachability(from: selectedDestination, outOf: candidateAnchors)
//        case .indoorEndingPoint:
//            return Array(repeating: true, count: anchors.count)
//        case .outdoorEndingPoint:
//            return Array(repeating: true, count: anchors.count)
//        }
//    }
//
//    var body: some View {
//        let isReachable = getReachabilityMask(candidateAnchors: anchors)
//        ScrollView {
//            VStack(spacing: 24) {
////                if case .indoorStartingPoint(let destinationAnchor) = anchorSelectionType {
////                   if NavigationManager.shared.getReachabilityFromOutdoors(outOf: [destinationAnchor]).first == true {
////                       LargeNavigationLink(destination: NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: destinationAnchor), label: "Start Outside", subLabel: "Type: \(destinationAnchor.getAnchorType().rawValue)", invert: true)
////                   }
////                }
//                ForEach(0..<anchors.count, id: \.self) { idx in
//                    if let filteredTypes = filteredTypes, filteredTypes.contains(anchors[idx].getAnchorType().rawValue) {                        switch anchorSelectionType {
//                        case .indoorStartingPoint(let destinationAnchor):
//                            if isReachable[idx] {
//                                LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Navigate", buttonDestination: NavigatingView(startAnchorDetails: anchors[idx], destinationAnchorDetails: destinationAnchor)), label: "\(anchors[idx].getName())", subLabel: "Type: \(anchors[idx].getAnchorType().rawValue)")
//                            }
//                        case .indoorEndingPoint:
//                            if isReachable[idx] {
//                                LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Choose Start Anchor", buttonDestination: StartAnchorListView(destinationAnchorDetails: anchors[idx])), label: "\(anchors[idx].getName())", subLabel: "Type: \(anchors[idx].getAnchorType().rawValue)")
//                            }
//                        case .outdoorEndingPoint:
//                            LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Navigate", buttonDestination: NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: anchors[idx])), label: "\(anchors[idx].getName())", subLabel: "Type: \(anchors[idx].getAnchorType().rawValue)")
//                        }
//                    }
//                }
//            }
//            .padding(.vertical, 12)
//        }
//        .onAppear() {
//            if filteredTypes == nil {
//                filteredTypes = DataModelManager.shared.getAnchorTypes().map { $0.rawValue }
//            }
//        }
//    }
//}

struct ListOfAnchors: View {
    let anchors: [LocationDataModel]
    let anchorSelectionType: AnchorSelectionType
    
    func getReachabilityMask(candidateAnchors: [LocationDataModel]) -> [Bool] {
        switch anchorSelectionType {
        case .indoorStartingPoint(let selectedDestination):
            return NavigationManager.shared.getReachability(from: selectedDestination, outOf: candidateAnchors)
        case .indoorEndingPoint:
            return Array(repeating: true, count: anchors.count)
        case .outdoorEndingPoint:
            return Array(repeating: true, count: anchors.count)
        }
    }
    
    init(anchors: [LocationDataModel], anchorSelectionType: AnchorSelectionType) {
        self.anchors = anchors
        self.anchorSelectionType = anchorSelectionType
    }
    
    var body: some View {
        let isReachable = getReachabilityMask(candidateAnchors: anchors)
        ScrollView {
            VStack(spacing: 24) {
                ForEach(anchors, id: \.self) { anchor in
                    switch anchorSelectionType {
                    case .indoorStartingPoint(let destinationAnchor):
                        if isReachable[anchors.firstIndex(of: anchor)!] {
                            LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchor, buttonLabel: "Navigate", buttonDestination: NavigatingView(startAnchorDetails: anchor, destinationAnchorDetails: destinationAnchor)), label: "\(anchor.getName())", subLabel: "\(anchor.getAnchorType().rawValue)")
                        }
                    case .indoorEndingPoint:
                        if isReachable[anchors.firstIndex(of: anchor)!] {
                            LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchor, buttonLabel: "Choose Start Anchor", buttonDestination: StartAnchorListView(destinationAnchorDetails: anchor)), label: "\(anchor.getName())", subLabel: "\(anchor.getAnchorType().rawValue)")
                        }
                    case .outdoorEndingPoint:
                        LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchor, buttonLabel: "Navigate", buttonDestination: NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: anchor)), label: "\(anchor.getName())", subLabel: "\(anchor.getAnchorType().rawValue)")
                    }
                }
            }
            .padding(.vertical, 12)
        }
    }
}



enum AnchorSelectionType {
    case indoorStartingPoint(selectedDestination: LocationDataModel)
    case indoorEndingPoint
    case outdoorEndingPoint
}

struct LeftLabel: View {
    let text: String
    let textSize: Font
    let color: Color
    
    init(text: String, textSize: Font = .largeTitle, color: Color = AppColor.foreground) {
            self.text = text
            self.textSize = textSize
            self.color = color
        }
    
    var body: some View {
        HStack {
            Text(text)
                .font(textSize)
                .bold()
                .foregroundColor(color)
            Spacer()
        }
    }
}

struct OrderedList: View {
    var listItems: [String]
    var listItemSpacing: CGFloat? = nil
    var toNumber: ((Int) -> String) = { "\($0 + 1)." }
    var bulletWidth: CGFloat? = nil
    var bulletAlignment: Alignment = .leading
    
    var body: some View {
        VStack(alignment: .leading,
               spacing: listItemSpacing) {
            ForEach(listItems.indices, id: \.self) { idx in
                HStack(alignment: .top) {
                    Text(toNumber(idx))
                        .frame(width: bulletWidth,
                               alignment: bulletAlignment)
                    Text(listItems[idx])
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }
            }
        }
       .padding(2)
    }
}

class LocationHelper {
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

struct AnchorListViewWithFiltering: View {
    @Binding var nearbyDistance: Double
    @Binding var showFilterPopup: Bool
    @Binding var selectedOrganization: String
    
    var settingsManager = SettingsManager.shared
    @ObservedObject var positionModel = PositioningModel.shared
    
    @State var allAnchors: [LocationDataModel] = []
    @State var filteredAnchors: [LocationDataModel] = []
    @State var allAnchorTypes: [AnchorType] = []
    @State var selectedAnchorTypes: [AnchorType] = []
    
    @State var lastQueryLocation: CLLocationCoordinate2D?
    
    let bufferDistance: CLLocationDistance
    
    init(nearbyDistance: Binding<Double> = .constant(0.0), showFilterPopup: Binding<Bool>, selectedOrganization: Binding<String> = .constant(""), lastQueryLocation: CLLocationCoordinate2D? = nil) {
        self._nearbyDistance = nearbyDistance
        self._showFilterPopup = showFilterPopup
        self._selectedOrganization = selectedOrganization
        self.lastQueryLocation = lastQueryLocation
        self.bufferDistance = LocationHelper.getBufferDistance(PositioningModel.shared.geoLocalizationAccuracy)
    }
    
    var body: some View {
        Group {
            ZStack {
                VStack {
                    ScrollView {
                        if nearbyDistance != 0.0 {
                            ListOfAnchors(anchors: filteredAnchors, anchorSelectionType: .indoorEndingPoint)
                            Spacer()
                            if nearbyDistance < 1000 {
                                ExpandSearch(action: {
                                    nearbyDistance = 1000
                                    selectedAnchorTypes = allAnchorTypes
                                })
                                    .padding(.bottom, 10)
                            }
                        } else {
                            SmallNavigationLink(destination: RecordAnchorView(), label: "Create New Anchor")
                                .padding(.top, 32)
                            VStack(spacing: 32) {
                                ForEach(0..<filteredAnchors.count, id: \.self) { idx in
                                    if filteredAnchors[idx].cloudAnchorMetadata?.organization == selectedOrganization {
                                        LargeNavigationLink(destination: AnchorDetailView_Manage(anchorDetails: filteredAnchors[idx]), label: "\(filteredAnchors[idx].getName())", subLabel: "\(filteredAnchors[idx].getAnchorType().rawValue)")
                                    }
                                }
                            }
                            .padding(.vertical, 32)
                        }
                    }
                }
                .onReceive(DataModelManager.shared.objectWillChange) {
                    allAnchors = []
                    if let latLon = lastQueryLocation {
                        updateNearbyAnchors(latLon: latLon)
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
                    if nearbyDistance == 0.0 {
                        updateNearbyAnchors(latLon: latLon)
                    } else {
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
    }
    
    private func updateNearbyAnchors(latLon: CLLocationCoordinate2D) {
        allAnchors = Array(
            DataModelManager.shared.getNearbyIndoorLocations(
                location: latLon,
                maxDistance: CLLocationDistance(Double.infinity),
                withBuffer: 0.0
            )
        )
        .sorted(by: {
            $0.getName() < $1.getName()
        })
    }
}
