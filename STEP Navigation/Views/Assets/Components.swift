//
//  Components.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/2/23.
//

import SwiftUI

struct TextFieldComponent: View {
    @Binding var entry: String
    let instructions: String?
    let label: String?
    let textBoxSize: TextBoxSize?
    
    @FocusState private var entryIsFocused: Bool
    
    init(entry: Binding<String>, instructions: String? = "", label: String? = nil, textBoxSize: TextBoxSize? = .small) {
        self._entry = entry
        self.instructions = instructions
        self.label = label
        self.textBoxSize = textBoxSize
    }
    
    var body: some View {
        VStack {
            if let label = label {
                HStack {
                    Text(label)
                        .font(.title2)
                        .bold()
                        .foregroundColor(AppColor.foreground)
                    Spacer()
                }
            }
            
            if let instructions = instructions {
                if textBoxSize == .small {
                    TextField("\(instructions)", text: $entry)
                        .foregroundColor(AppColor.foreground)
                        .frame(height: 48)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColor.foreground, lineWidth: 2)
                        )
                        .submitLabel(.done)
                } else {
                    TextField("\(instructions)", text: $entry, axis: .vertical)
                        .foregroundColor(AppColor.foreground)
                        .frame(height: 146)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColor.foreground, lineWidth: 2)
                        )
                        .lineLimit(6, reservesSpace: true)
                        .submitLabel(.done)
                        .focused($entryIsFocused)
                        .onChange(of: entry) { newValue in
                            guard let newValueLastChar = newValue.last else { return }
                            if newValueLastChar == "\n" {
                                entry.removeLast()
                                entryIsFocused = false
                            }
                        }
                }
            }
        }
        .padding(.horizontal)
    }
    
    enum TextBoxSize {
        case small, large
    }
}


/// This struct manages the appearance of the titles for each screen.
struct ScreenTitleComponent: View {
    let titleText: String
    let subtitleText: String?
    
    /// Init Method
    /// - Parameters:
    ///   - titleText: takes a string to create the main header title
    ///   - subtitleText: takes an optional string to create the subheader title
    init(titleText: String, subtitleText: String? = nil) {
        self.titleText = titleText
        self.subtitleText = subtitleText
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(titleText)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.bottom, subtitleText != nil ? 0.5 : 20)
            
            if let subtitleText = subtitleText {
                HStack {
                    Text(subtitleText)
                        .font(.title2)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
        .background(AppColor.accent)
        .foregroundColor(AppColor.text_on_accent)
    }
}

struct CustomHeaderButtonComponent: ToolbarContent {
    let label: String
    let placement: ToolbarItemPlacement
    let onTapGesture: () -> Void
    
    init(label: String, placement: ToolbarItemPlacement, onTapGesture: @escaping () -> Void) {
        self.label = label
        self.placement = placement
        self.onTapGesture = onTapGesture
    }
    
    @ViewBuilder
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Text(label)
                .bold()
                .font(.title2)
                .foregroundColor(AppColor.text_on_accent)
                .onTapGesture {
                    onTapGesture()
                }
        }
    }
}

/// This struct is responsible for the presentation of various types of informational popups based on the type of popup.
struct InformationPopupComponent: View {
    let popupType: PopupType
    
    
    /// Init Method
    /// - Parameter popupType:this is a parameter that shows the type of popup
    init(popupType: PopupType) {
        self.popupType = popupType
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(popupType.messageText)
                    .foregroundColor(AppColor.text_on_accent)
                    .bold()
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            if case .arrived = popupType {
                if let anchorDetails = popupType.additionalAnchorDetails {
                    SmallButtonComponent_NavigationLink(destination: {
                        AnchorDetailView_ArrivedView(feedback: Feedback(), anchorDetails: anchorDetails)
                    }, label: "Go to Destination Details", labelColor: AppColor.accent, backgroundColor: AppColor.text_on_accent)
                }
            }
        
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.accent)
    }
    
    /// This enumeration represents the different types of popups that can be presented.
    ///
    /// - `waitingToLocalize`:The popup type when the app is aligning the route.
    /// - `arrived`: The popup type when the user arrives at the last cloud anchor.
    /// - `direction`: The popup type when the application is providing a direction, which holds a string value                 representing the direction text.
    enum PopupType {
        case waitingToLocalize
        case arrived(destinationAnchorDetails: LocationDataModel)
        case direction(directionText: String)
        case countdown(countdown: Int)
        
        var messageText: String {
            switch self {
            case .arrived:
                return "Arrived. You should be within one cane's length of your destination."
            case . waitingToLocalize:
                return "Trying to align to your route. Scan your phone around to recognize your surroundings."
            case .direction(let directionText):
                return directionText
            case .countdown(let countdown):
                return String(countdown)
            }
        }
        
        var additionalAnchorDetails: LocationDataModel? {
            switch self {
            case .arrived(let destinationAnchorDetails):
                return destinationAnchorDetails
            default:
                return nil
            }
        }
    }
}


/// This struct displays the details of the cloud anchor.
struct AnchorDetailsComponent: View {
    let title: String
    let distanceAway: String
    let locationNotes: String?
    
    /// Init Method
    /// - Parameters:
    ///   - title: Name of the destination.
    ///   - distanceAway: Distance away from the destination.
    ///   - locationNotes: Optional notes for the location.
    init(title: String, distanceAway: String, locationNotes: String? = "No notes available for this location.") {
        self.title = title
        self.distanceAway = distanceAway
        self.locationNotes = locationNotes
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
                    Text("\(distanceAway) meters away")
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
                        if let locationNotes = locationNotes {
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

struct ActionBarButtonComponent: View {
    let action: () -> Void
    let iconSystemName: String
    let color: Color?
    let accessibilityLabel: String
    
    init(action: @escaping () -> Void, iconSystemName: String, color: Color? = AppColor.text_on_accent, accessibilityLabel: String) {
        self.action = action
        self.iconSystemName = iconSystemName
        self.color = color
        self.accessibilityLabel = accessibilityLabel
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconSystemName)
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(color)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

/// This type is used to specify to the ChooseAnchorComponentView whether we are choosing the anchor in the context of indoor or outdoor navigation.  Further, if indoors, we differentiate between the start and end of a route
struct NavigateAnchorListComponent: View {
    var anchors: [LocationDataModel]
    let anchorSelectionType: AnchorSelectionType
    
    @AccessibilityFocusState var focusedOnNavigate
    
    init(anchorSelectionType: AnchorSelectionType,
         anchors: [LocationDataModel]) {
        self.anchorSelectionType = anchorSelectionType
        self.anchors = anchors
    }
    
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

        VStack {
            ScrollView {
                if case .indoorStartingPoint(let destinationAnchor) = anchorSelectionType {
                   if NavigationManager.shared.getReachabilityFromOutdoors(outOf: [destinationAnchor]).first == true {

                       NavigationLink (
                           destination: {
                               NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: destinationAnchor)
                           },
                           label: {
                               HStack {
                                   Text("Start Outside")
                                       .font(.title)
                                       .bold()
                                       .padding(30)
                                       .foregroundColor(AppColor.foreground)
                                       .multilineTextAlignment(.leading)
                                       Spacer()
                               }
                               .frame(maxWidth: .infinity)
                               .frame(minHeight: 140)
                           })
//                       .background(AppColor.background)
                       .cornerRadius(20)
                       .overlay(
                           RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColor.foreground, lineWidth: 5)
                       )
                       .padding(.horizontal)
                       .padding(.top, 5)
                   }
                }
                VStack(spacing: 20) {
                    ForEach(0..<anchors.count, id: \.self) { idx in
                        switch anchorSelectionType {
                        case .indoorStartingPoint(let destinationAnchor):
                            if isReachable[idx] {
                                LargeButtonComponent_NavigationLink(destination: {
                                    AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Navigate", buttonDestination:
                                        NavigatingView(startAnchorDetails: anchors[idx], destinationAnchorDetails: destinationAnchor))
                                }, label: "\(anchors[idx].getName())", labelTextSize: .title, labelTextLeading: true)
                            }
                        case .indoorEndingPoint:
                            if isReachable[idx] {
                                LargeButtonComponent_NavigationLink(destination: {
                                    AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Choose Start Anchor", buttonDestination:
                                        StartAnchorListView(destinationAnchorDetails: anchors[idx]))
                                }, label: "\(anchors[idx].getName())", labelTextSize: .title, labelTextLeading: true)
                            }
                        case .outdoorEndingPoint:
                            LargeButtonComponent_NavigationLink(destination: {
                                AnchorDetailView(anchorDetails: anchors[idx], buttonLabel: "Navigate", buttonDestination:
                                    NavigatingView(startAnchorDetails: nil, destinationAnchorDetails: anchors[idx]))
                            }, label: "\(anchors[idx].getName())", labelTextSize: .title, labelTextLeading: true)
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(.top, 10)
    }
}

//enum AnchorSelectionType {
//    case indoorStartingPoint(selectedDestination: LocationDataModel)
//    case indoorEndingPoint
//    case outdoorEndingPoint
//}

struct NearbyDistanceThresholdComponent: View {
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
            Button {
                nearbyDistance = 1000
                focusOnNearbyDistanceValue.wrappedValue = true
            } label: {
                Text("Expand Search Radius")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: 300)
                    .foregroundColor(AppColor.text_on_accent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .padding(.top, 5)
            .tint(AppColor.accent)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
        }
    }
}
