//
//  AnchorDetailEditView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI

struct AnchorDetailEditView<Destination: View>: View {
    let anchorDetails: LocationDataModel
    let buttonLabel: String
    let buttonDestination: () -> Destination
    
    @State var hideBackButton: Bool

    @State var showAnchorTypeMenu: Bool = false
    @State var showCorrespondingExitMenu: Bool = false
    
    @State var editing: Bool = false
    @FocusState var editingOrg: Bool
    @State var allOrganizations: [String] = DataModelManager.shared.getAllNearbyOrganizations().sorted(by: { $0 < $1 })
    
//    @State var allCategories: [String] = AnchorType.allCases.map { $0.rawValue}
    
    @State var allCategories: [String] = AnchorType.allCases
        .filter { ![.busStop, .externalDoor, .path].contains($0) }
        .map { $0.rawValue }
//    @State var allCorrespondingExits: [String] = DataModelManager.shared.getLocationsByType(anchorType: .externalDoor)
//        .sorted(by: { $0.getName() < $1.getName() })
//        .map { $0.getName() }
    @State var inputText: String = ""
    
    @State var newAnchorName: String
    @State var newOrganization: String
    @State var newCategory: String
    @State var newNotes: String
    @State var newAssociatedOutdoorFeature: String
    @State var newIsReadable: Bool
    let metadata: CloudAnchorMetadata
    
    init(anchorDetails: LocationDataModel, buttonLabel: String, buttonDestination: @escaping () -> Destination, hideBackButton: Bool = false) {
        metadata = FirebaseManager.shared.getCloudAnchorMetadata(byID: anchorDetails.getCloudAnchorID()!)! //TODO: lots of force unwrapping happening here; can we get rid of this?
        newAnchorName = metadata.name
        newAssociatedOutdoorFeature = metadata.associatedOutdoorFeature
        newCategory = metadata.type.rawValue
        newIsReadable = metadata.isReadable
        newOrganization = metadata.organization
        newNotes = metadata.notes
        self.anchorDetails = anchorDetails
        self.buttonLabel = buttonLabel
        self.buttonDestination = buttonDestination
        self.hideBackButton = hideBackButton
    }
    
    var body: some View {
        ZStack {
            ScreenBackground {
                VStack {
                    ScreenHeader(title: "Edit Anchor", backButtonHidden: hideBackButton)
                    VStack {
                        ScrollView {
                            VStack(spacing: 12) {
                                VStack {
                                    LeftLabel(text: "Name", textSize: .title2)
                                    CustomTextField(entry: $newAnchorName)
                                        .accessibilityLabel("Name")
                                }
                                //Commenting out organization for the co-designers (until the new address based organization system is ready)
//                                VStack {
//                                    LeftLabel(text: "Organization", textSize: .title2)
//                                    ComboBox(allOptions: allOrganizations, editing: $editing, inputText: $newOrganization)
//                                        .focused($editingOrg)
//                                }
                                
                                VStack {
                                    LeftLabel(text: "Type", textSize: .title2)
                                    PickerButton(selection: $newCategory, showPage: $showAnchorTypeMenu)
                                }
                                //Commenting out corresponding exit for co-designers (until the new indoor-outdoor feature is ready)
//                                if newCategory == "Exit" {
//                                    VStack {
//                                        LeftLabel(text: "Corresponding Exit", textSize: .title2)
//                                        PickerButton(selection: $newAssociatedOutdoorFeature, showPage: $showCorrespondingExitMenu)
//                                    }
//                                }
                                
                                VStack {
                                    LeftLabel(text: "Location Notes", textSize: .title2)
                                    CustomTextField(entry: $newNotes, textBoxSize: .large)
                                        .accessibilityLabel("Location Notes")
                                }
                                //Commenting out visibility for co-designers until properly implemented
//                                VStack {
//                                    LeftLabel(text: "Visibility", textSize: .title2)
//                                    SegmentedToggle(toggle: $newIsReadable, trueLabel: "Public", falseLabel: "Private")
//                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    SmallNavigationLink(destination: buttonDestination(), label: buttonLabel) {
                        self.updateMetadata()
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .navigationBarBackButtonHidden(hideBackButton || showAnchorTypeMenu)
            
            if showAnchorTypeMenu {
                PickerPage(allOptions: allCategories, selection: $newCategory, showPage: $showAnchorTypeMenu)
                    .onAppear() {
                        editingOrg = false
                    }
            }
//            if showCorrespondingExitMenu {
//                PickerPage(allOptions: allCorrespondingExits, selection: $newAssociatedOutdoorFeature, showPage: $showCorrespondingExitMenu)
//                    .onAppear() {
//                        editingOrg = false
//                    }
//            }
        }
    }

    
    func updateMetadata() {
        let newMetadata =
        CloudAnchorMetadata(name: newAnchorName,
                            type: AnchorType(rawValue: newCategory) ?? .other,
                                associatedOutdoorFeature: newAssociatedOutdoorFeature,
                                geospatialTransform: metadata.geospatialTransform, creatorUID: metadata.creatorUID,
                            isReadable: newIsReadable,
                            organization: newOrganization,
                            notes: newNotes)
        FirebaseManager.shared.updateCloudAnchor(identifier: anchorDetails.getCloudAnchorID()!, metadata: newMetadata) //TODO: additional forced unwrapping to get rid of
    }
}
