//
//  AnchorDetailEditView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import GooglePlaces

struct TextFieldClearButton: ViewModifier {
    @Binding var fieldText: String

    func body(content: Content) -> some View {
        content
            .overlay {
                if !fieldText.isEmpty {
                    HStack {
                        Spacer()
                        Button {
                            fieldText = ""
                        } label: {
                            Image(systemName: "multiply.circle.fill")
                        }
                        .foregroundColor(.secondary)
                        .padding(.trailing, 4)
                    }
                }
            }
    }
}

extension View {
    func showClearButton(_ text: Binding<String>) -> some View {
        self.modifier(TextFieldClearButton(fieldText: text))
    }
}

struct AnchorDetailEditView<Destination: View>: View {
    let buttonLabel: String
    let buttonDestination: () -> Destination
    
    let visibilityOptions = [true, false]
    
    @State var confirmPressed: Bool = false
    @State var showAnchorTypeMenu: Bool = false
    
    @State var editing: Bool = false
    @FocusState var editingOrg: Bool
    @State var inputText: String = ""
    @State var vOffset: CGFloat = 52
    @State var hOffset: CGFloat = 0
    
    let anchorID: String
    @State var newAnchorName: String
    @State var newOrganization: String
    @State var newCategory: AnchorType
    @State var newNotes: String
    @State var newAssociatedOutdoorFeature: String
    @State var newIsReadable: Bool
    let metadata: CloudAnchorMetadata
    
    init(anchorID: String, buttonLabel: String, buttonDestination: @escaping () -> Destination) {
        self.anchorID = anchorID
        metadata = FirebaseManager.shared.getCloudAnchorMetadata(byID: anchorID)!
        newAnchorName = metadata.name
        newAssociatedOutdoorFeature = metadata.associatedOutdoorFeature
        newCategory = metadata.type
        newIsReadable = metadata.isReadable
        newOrganization = metadata.organization
        newNotes = metadata.notes
        self.buttonLabel = buttonLabel
        self.buttonDestination = buttonDestination
    }
    
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    ScrollView {
                        TextFieldComponent(entry: $newAnchorName, label: "Name")
                        
                        VStack {
                            HStack {
                                Text("Organization")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(AppColor.foreground)
                                Spacer()
                            }
                            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                Group {
                                    TextField("", text: $newOrganization, onEditingChanged: {edit in
                                        self.editing = edit
                                    })
                                    .showClearButton($newOrganization)
                                    .padding(.horizontal, 10)
                                    .focused($editingOrg)
                                }
                                .foregroundColor(AppColor.foreground)
                                .frame(height: 48)
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(AppColor.foreground, lineWidth: 2)
                                )
                                
                                OrganizationComboBox(editing: $editing, text: $newOrganization, verticalOffset: vOffset, horizontalOffset: hOffset)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                Text("Type")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(AppColor.foreground)
                                Spacer()
                            }
                            
                            Button(action: {
                                withAnimation {
                                    showAnchorTypeMenu = true
                                }
                            }, label: {
                                HStack {
                                    Text("\(newCategory.rawValue)")
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .foregroundColor(AppColor.foreground)
                                .padding()
                            })
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColor.foreground, lineWidth: 2)
                            )
                        }
                        .padding(.horizontal)
                        
                        if newCategory == .exit {
                            VStack {
                                HStack {
                                    Text("Corresponding Exit")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(AppColor.foreground)
                                    Spacer()
                                }
                                HStack {
                                    Picker("Select Corresponding Exit", selection: $newAssociatedOutdoorFeature) {
                                        Text("").tag("")
                                        ForEach(DataModelManager.shared.getLocationsByType(anchorType: .externalDoor).sorted(by: { $0.getName() < $1.getName() })) { outdoorFeature in
                                            Text(outdoorFeature.getName()).tag(outdoorFeature.id)
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(height: 48)
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(AppColor.foreground, lineWidth: 2)
                                )
                            }
                            .padding(.horizontal)
                            
                        }
                        TextFieldComponent(entry: $newNotes, label: "Location Notes", textBoxSize: .large)
                        
                        VStack {
                            HStack {
                                Text("Visibility")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(AppColor.foreground)
                                Spacer()
                            }
                            
                            CustomSegmentedControl(isReadable: $newIsReadable)
                        }
                        .padding(.horizontal)
                        
                        
                    }
                    Spacer()
                }
                .padding(.top, 20)
                
                Spacer()
                NavigationLink(destination: buttonDestination(), isActive: $confirmPressed, label: {
                    Text("\(buttonLabel)")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(AppColor.text_on_accent)
                })
                .onChange(of: confirmPressed) {
                    newValue in
                    if newValue {
                        print("simultaneous action completed")
                        self.updateMetadata()
                    }
                }
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            
            if showAnchorTypeMenu == true {
                AnchorTypeMenu(newCategory: $newCategory, showAnchorTypeMenu: $showAnchorTypeMenu)
                    .onAppear() {
                        editingOrg = false
                    }
            }
        }
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden()
        .toolbar {
            Text("")
        }
    }
    
    func updateMetadata() {
        let newMetadata =
        CloudAnchorMetadata(name: newAnchorName,
                                type: newCategory,
                                associatedOutdoorFeature: newAssociatedOutdoorFeature,
                                geospatialTransform: metadata.geospatialTransform, creatorUID: metadata.creatorUID,
                            isReadable: newIsReadable,
                            organization: newOrganization,
                            notes: newNotes, outdoorPositioning: metadata.outdoorPositioning)
        FirebaseManager.shared.updateCloudAnchor(identifier: anchorID, metadata: newMetadata)
    }
}

struct CustomSegmentedControl: View {
    @Binding var isReadable: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(AppColor.background)
                Rectangle()
                    .fill(AppColor.foreground)
                   .cornerRadius(10)
                   .opacity(isReadable ? 1 : 0.01)
                   .onTapGesture {
                           withAnimation(.interactiveSpring()) {
                               isReadable = true
                           }
                       }
            }
            .overlay(
               Text("Public")
                   .foregroundColor(isReadable ? AppColor.background : AppColor.foreground)
                   .bold()
                   .accessibilityAction {
                          withAnimation(.interactiveSpring()) {
                              isReadable = true
                          }
                      }
                .accessibilityAddTraits(isReadable ? .isSelected : [])
           )
            
            ZStack {
                Rectangle()
                    .fill(AppColor.background)
                Rectangle()
                    .fill(AppColor.foreground)
                   .cornerRadius(10)
                   .opacity(isReadable ? 0.01 : 1)
                   .onTapGesture {
                           withAnimation(.interactiveSpring()) {
                               isReadable = false
                           }
                       }
            }
            .overlay(
               Text("Private")
                   .foregroundColor(isReadable ? AppColor.foreground : AppColor.background)
                   .bold()
                   .accessibilityAction {
                          withAnimation(.interactiveSpring()) {
                              isReadable = false
                          }
                      }
                .accessibilityAddTraits(!isReadable ? .isSelected : [])
           )
        }
        .frame(height: 40)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColor.foreground, lineWidth: 2)
        )
    }
}

struct PlaceIDNamePair {
    let placeID: String
    let name: String
}

struct OrganizationComboBox: View {
    @ObservedObject var dataModelManager = DataModelManager.shared
    @State var allOrganizations: [PlaceIDNamePair] = []
    @ObservedObject var positioningModel = PositioningModel.shared
    @State var geoCoder = GMSPlacesClient()
    @State var sessionToken = GMSAutocompleteSessionToken()

    @Binding var editing: Bool
    @Binding var inputText: String
    @State var verticalOffset: CGFloat
    @State var horizontalOffset: CGFloat
    
    public init(editing: Binding<Bool>, text: Binding<String>, verticalOffset: CGFloat, horizontalOffset: CGFloat) {
        self._editing = editing
        self._inputText = text
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
        //self._allOrganizations = State(initialValue: dataModelManager.getAllNearbyOrganizations())
    }
    
    /// A utility to function to get the Earth's radius at a particular latitude
    /// See:  http://en.wikipedia.org/wiki/Earth_radius
    ///
    /// - Parameter lat: the latitude
    /// - Returns: the radius at that latitude
    private static func WGS84EarthRadius(lat: Double)->Double {
        let WGS84_a = 6378137.0  // Major semiaxis [m]
        let WGS84_b = 6356752.3  // Minor semiaxis [m]
        let An = WGS84_a*WGS84_a * cos(lat)
        let Bn = WGS84_b*WGS84_b * sin(lat)
        let Ad = WGS84_a * cos(lat)
        let Bd = WGS84_b * sin(lat)
        return sqrt( (An*An + Bn*Bn)/(Ad*Ad + Bd*Bd) )
    }
    
    /// This is a utility method to compute a bounding box around a specific latitude / longitude point
    /// - Parameters:
    ///   - center: the center of the bounding box
    ///   - sideLength: the side length of the bounding box in meters
    /// - Returns: the location bias, which contains the Northeast and Southwest corners
    private static func getLocationBias(from center: CLLocationCoordinate2D, withSideLength sideLength: Double)->GMSPlaceLocationBias {
        let halfSide = sideLength/2.0

        let radius = WGS84EarthRadius(lat: center.latitude * .pi / 180.0)
        let pradius = radius*cos(center.latitude * .pi / 180.0)
        print("radius \(radius) pradius \(pradius)")
        let latMin = center.latitude - halfSide/radius
        let latMax = center.latitude + halfSide/radius
        let lonMin = center.longitude - halfSide/pradius * 180.0 / .pi
        let lonMax = center.longitude + halfSide/pradius * 180.0 / .pi
        let northeast = CLLocationCoordinate2D(latitude: latMax, longitude: lonMax)
        let southwest = CLLocationCoordinate2D(latitude: latMin, longitude: lonMin)
        return GMSPlaceRectangularLocationOption(northeast, southwest)
    }
    
    /// Use the data entered into the text box so far to suggest possible places
    private func checkForNearbyPlaces() {
        if let currentLatLon = positioningModel.currentLatLon {
            let filter = GMSAutocompleteFilter()
            let locationBias = Self.getLocationBias(from: currentLatLon, withSideLength: 10000.0)
            filter.locationBias = locationBias
            geoCoder.findAutocompletePredictions(fromQuery: inputText, filter: filter, sessionToken: sessionToken) { predictions, error in
                guard let predictions = predictions else {
                    print("error \(error!.localizedDescription)")
                    return
                }
                allOrganizations = predictions.map({
                    PlaceIDNamePair(placeID: $0.placeID, name: $0.attributedFullText.string)
                })
                print("allOrgs: \(allOrganizations)")
            }
        }
    }

    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(allOrganizations, id: \.placeID) { textSearched in
                        Text(textSearched.name)
                            .foregroundColor(AppColor.background)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 25)
                            .frame(minWidth: 0,
                                   maxWidth: .infinity,
                                   minHeight: 0,
                                   maxHeight: 50,
                                   alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                // TODO: this should probably be storing place ID instead of the name (or maybe both)
                                inputText = textSearched.name
                                editing = false
                                self.endTextEditing()
                            })
                        Divider()
                            .overlay(AppColor.background)
                            .padding(.horizontal, 10)
                    }
                }
            }
            .background(AppColor.foreground)
            .cornerRadius(15)
            .foregroundColor(AppColor.background)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity,
                   minHeight: 0,
                   maxHeight: 50 * CGFloat((allOrganizations.count > 3 ? 3: allOrganizations.count))
            )
            .offset(x: horizontalOffset, y: verticalOffset)
            .isHidden(!editing, remove: !editing)
            
            Spacer()
        }
        .frame(height: (50 * CGFloat((allOrganizations.count > 3 ? 3 : allOrganizations.count)) + (editing == true ? verticalOffset : 0)))
        .onChange(of: inputText) { newValue in
            print("new", inputText)
            checkForNearbyPlaces()
        }
    }
}

public extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct AnchorTypeMenu: View {
    @Binding var newCategory: AnchorType
    @Binding var showAnchorTypeMenu: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                Divider()
                    .overlay(AppColor.foreground)
                ForEach(AnchorType.allCases.sorted(by: {$0.rawValue < $1.rawValue}), id: \.self) { category in
                    Button(action: {
                        newCategory = category
                        showAnchorTypeMenu = false
                    }, label: {
                        if newCategory == category {
                            HStack {
                                Text(category.rawValue)
                                    .font(.title2)
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        } else {
                            HStack {
                                Text(category.rawValue)
                                    .font(.title2)
                                Spacer()
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
        }
        .accessibilityAddTraits(.isModal)
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Image(systemName: "chevron.left")
                        .bold()
                        .accessibilityHidden(true)
                    Text("Back")
                        .foregroundColor(AppColor.text_on_accent)
                        .onTapGesture {
                            showAnchorTypeMenu = false
                        }
                    Spacer()
                }
            }
        }
    }
}
