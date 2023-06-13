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
    
    @State var confirmPressed: Bool = false
    
    let anchorID: String
    @State var newAnchorName: String
    @State var newPlace: String
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
        newPlace = "Placeholder Place"
        newNotes = "Placeholder Notes"
        self.buttonLabel = buttonLabel
        self.buttonDestination = buttonDestination
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TextFieldComponent(entry: $newAnchorName, label: "Name")
                //TODO: add popup to warn if you set the name as the same as another nearby anchor/another anchor in the same organization (not me accidentally naming two anchors MAC Elevators (2nd Floor))
                TextFieldComponent(entry: $newPlace, label: "Organization")
                VStack {
                    HStack {
                        Text("Anchor Type")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        Picker(selection: $newCategory) {
                            ForEach(AnchorType.allCases.sorted(by: {$0.rawValue < $1.rawValue}), id: \.self) { category in
                                Text(category.rawValue)
                            }
                        } label: {
                            Text("AnchorType")
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }
                    .frame(height: 48)
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(AppColor.grey, lineWidth: 2)
                    )
                }
                .padding(.horizontal)
                
                if newCategory == .exit {
                    VStack {
                        HStack {
                            Text("Select Corresponding Exit")
                                .font(.title2)
                                .bold()
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
                    }
                    .padding(.horizontal)
                    
                }
                TextFieldComponent(entry: $newNotes, label: "Location Notes", textBoxSize: .large)
                Toggle("Public Anchor", isOn: $newIsReadable)
                    .padding(.horizontal)
                    .bold()
                
            }
            .padding(.top, 16)
            
            Spacer()
            //fix this so that it is actually stuck to the bottom: since it is a scrollview the spacer doesn't do anything, but if you make it not a scrollview then when the keyboard appears it moves the save button up weirdly
            NavigationLink(destination: buttonDestination(), isActive: $confirmPressed, label: {
                Text("\(buttonLabel)")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(AppColor.dark)
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
            
        }
    }
    
    func updateMetadata() {
        let newMetadata =
        CloudAnchorMetadata(name: newAnchorName,
                                type: newCategory,
                                associatedOutdoorFeature: newAssociatedOutdoorFeature,
                                geospatialTransform: metadata.geospatialTransform, creatorUID: metadata.creatorUID,
                                isReadable: newIsReadable)
        FirebaseManager.shared.updateCloudAnchor(identifier: anchorID, metadata: newMetadata)
    }
}
