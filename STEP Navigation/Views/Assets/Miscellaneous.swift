//
//  Miscellaneous.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct AnchorDetailsText: View {
    let anchorDetails: LocationDataModel
    let textColor: Color
    
    @State var distanceAway: Double = 0.0
    
    @State var locationNotes: String
    @State var anchorName: String
    @State var anchorCategory: String

    let metadata: CloudAnchorMetadata

    init(anchorDetails: LocationDataModel, textColor: Color = AppColor.foreground, distanceAway: Double = 0.0) {
        metadata = FirebaseManager.shared.getCloudAnchorMetadata(byID: anchorDetails.getCloudAnchorID()!)! //TODO: lots of force unwrapping happening here; can we get rid of this?
        anchorName = metadata.name
        anchorCategory = metadata.type.rawValue
        locationNotes = metadata.notes
        self.anchorDetails = anchorDetails
        self.textColor = textColor
        self.distanceAway = distanceAway
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(anchorDetails.getName())
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
//            HStack {
//                Text("Type: \(anchorCategory)")
//                    .font(.title)
//                    .padding(.horizontal)
//                Spacer()
//            }
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
        .onAppear() {
            if let currentLocation = PositioningModel.shared.currentLatLon {
                distanceAway = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
            }
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

struct NearbyDistanceThreshold: View {
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
                    .foregroundColor(AppColor.foreground)
                Spacer()
            }
            
            SmallButton(action: {
                nearbyDistance = 1000
                focusOnNearbyDistanceValue.wrappedValue = true
            }, label: "Expand Search Radius")
        }
    }
}

struct ListOfAnchors: View {
    var anchors: [LocationDataModel]
    let anchorSelectionType: AnchorSelectionType
    
    @AccessibilityFocusState var focusedOnNavigate
    
    func getReachabilityMask(candidateAnchors: [LocationDataModel])->[Bool] {
        switch anchorSelectionType {
        case .indoorStartingPoint(let selectedDestination):
            return NavigationManager.shared.getReachability(from: selectedDestination, outOf: candidateAnchors)
        case .indoorEndingPoint:
            return Array(repeating: true, count: anchors.count)
        case .outdoorEndingPoint:
            return Array(repeating: true, count: anchors.count)
        }
    }
    
    var body: some View {
        let isReachable = getReachabilityMask(candidateAnchors: anchors)
        ScrollView {
            VStack(spacing: 24) {
                if case .indoorStartingPoint(let destinationAnchor) = anchorSelectionType {
                   if NavigationManager.shared.getReachabilityFromOutdoors(outOf: [destinationAnchor]).first == true {
                       LargeNavigationLink(destination: NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: destinationAnchor), label: "Start Outside", invert: true)
                       
                   }
                }
                ForEach(0..<anchors.count, id: \.self) { idx in
                    switch anchorSelectionType {
                    case .indoorStartingPoint(let destinationAnchor):
                        if isReachable[idx] {
                            LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Navigate", buttonDestination: NavigatingView(startAnchorDetails: anchors[idx], destinationAnchorDetails: destinationAnchor)), label: "\(anchors[idx].getName())")
                        }
                    case .indoorEndingPoint:
                        if isReachable[idx] {
                            LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Choose Start Anchor", buttonDestination: StartAnchorListView(destinationAnchorDetails: anchors[idx])), label: "\(anchors[idx].getName())")
                        }
                    case .outdoorEndingPoint:
                        LargeNavigationLink(destination: AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Navigate", buttonDestination: NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: anchors[idx])), label: "\(anchors[idx].getName())")
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
                        .font(.title3)
                        .bold()
                }
                .foregroundColor(AppColor.foreground)
            }
        }
       .padding()
    }
}

struct UnorderedList: View {
    var listItems: [String]
    var listItemSpacing: CGFloat? = nil
    var bulletWidth: CGFloat? = 14
    var bulletAlignment: Alignment = .leading
    
    var body: some View {
        VStack(alignment: .leading,
               spacing: listItemSpacing) {
            ForEach(listItems, id: \.self) { item in
                HStack(alignment: .top) {
                    Circle()
                        .frame(width: bulletWidth, height: bulletWidth, alignment: bulletAlignment)
                        .padding(.trailing, 4)
                        .padding(.top, 10)
                        .accessibilityHidden(true)
                    Text(item)
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                        .font(.title)
                        .bold()
                }
                .foregroundColor(AppColor.foreground)
            }
        }
               .padding()
    }
}

