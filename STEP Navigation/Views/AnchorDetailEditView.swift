//
//  AnchorDetailEditView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI

struct AnchorDetailEditView<Destination: View>: View {
    let buttonLabel: String
    let buttonDestination: () -> Destination
        
    @State var showAnchorTypeMenu: Bool = false
    @State var showCorrespondingExitMenu: Bool = false

    
    @State var editing: Bool = false
    @FocusState var editingOrg: Bool
    @State var allOrganizations: [String] = DataModelManager.shared.getAllNearbyOrganizations().sorted(by: { $0 < $1 })
    
    @State var allCategories: [String] = AnchorType.allCases.map { $0.rawValue}
    @State var allCorrespondingExits: [String] = DataModelManager.shared.getLocationsByType(anchorType: .externalDoor)
        .sorted(by: { $0.getName() < $1.getName() })
        .map { $0.getName() }
    @State var inputText: String = ""
    
    let anchorID: String
    @State var newAnchorName: String
    @State var newOrganization: String
    @State var newCategory: String
    @State var newNotes: String
    @State var newAssociatedOutdoorFeature: String
    @State var newIsReadable: Bool
    let metadata: CloudAnchorMetadata
    
    init(anchorID: String, buttonLabel: String, buttonDestination: @escaping () -> Destination) {
        self.anchorID = anchorID
        metadata = FirebaseManager.shared.getCloudAnchorMetadata(byID: anchorID)!
        newAnchorName = metadata.name
        newAssociatedOutdoorFeature = metadata.associatedOutdoorFeature
        newCategory = metadata.type.rawValue
        newIsReadable = metadata.isReadable
        newOrganization = metadata.organization
        newNotes = metadata.notes
        self.buttonLabel = buttonLabel
        self.buttonDestination = buttonDestination
    }
    
    var body: some View {
        ScreenBackground {
            ZStack {
                VStack {
                    ScreenHeader(title: "Edit Anchor", backButtonHidden: true)
                    VStack {
                        ScrollView {
                            VStack(spacing: 12) {
                                VStack {
                                    LeftLabel(text: "Name", textSize: .title2)
                                    CustomTextField(entry: $newAnchorName)
                                }
                                
                                VStack {
                                    LeftLabel(text: "Organization", textSize: .title2)
                                    ComboBox(allOptions: allOrganizations, editing: $editing, inputText: $newOrganization)
                                        .focused($editingOrg)
                                }
                                
                                VStack {
                                    LeftLabel(text: "Type", textSize: .title2)
                                    PickerButton(selection: $newCategory, showPage: $showAnchorTypeMenu)
                                }
                                
                                if newCategory == "Exit" {
                                    VStack {
                                        LeftLabel(text: "Corresponding Exit", textSize: .title2)
                                        PickerButton(selection: $newAssociatedOutdoorFeature, showPage: $showCorrespondingExitMenu)
                                    }
                                }
                                
                                VStack {
                                    LeftLabel(text: "Location Notes", textSize: .title2)
                                    CustomTextField(entry: $newNotes, textBoxSize: .large)
                                }
                                
                                VStack {
                                    LeftLabel(text: "Visibility", textSize: .title2)
                                    SegmentedToggle(toggle: $newIsReadable, trueLabel: "Public", falseLabel: "Private")
                                }
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
                
                if showAnchorTypeMenu == true {
                    PickerPage(allOptions: allCategories, selection: $newCategory, showPage: $showAnchorTypeMenu)
                        .onAppear() {
                            editingOrg = false
                        }
                }
                if showCorrespondingExitMenu == true {
                    PickerPage(allOptions: allCorrespondingExits, selection: $newAssociatedOutdoorFeature, showPage: $showCorrespondingExitMenu)
                        .onAppear() {
                            editingOrg = false
                        }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
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
        FirebaseManager.shared.updateCloudAnchor(identifier: anchorID, metadata: newMetadata)
    }
}
