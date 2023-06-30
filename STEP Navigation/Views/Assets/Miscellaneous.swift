//
//  Miscellaneous.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

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
                    Text("\(String(format: "%.0f", distanceAway)) meters away") //TODO: make this dynamic so it can be imperial or metric
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
                        .font(.title2)
                        .padding(4)
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
    
    init(text: String, textSize: Font = .title, color: Color = AppColor.foreground) {
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
