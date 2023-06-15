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
    
    let visibilityOptions = [true, false]
    
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
        newPlace = "Placeholder Place - Do not edit, doesn't work yet"
        newNotes = "Placeholder Notes - Do not edit, doesn't work yet"
        self.buttonLabel = buttonLabel
        self.buttonDestination = buttonDestination
        
//        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 171/255, green: 236/255, blue: 220/255, alpha: 1)
//        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: AppColor.dark], for: .selected)
//        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: AppColor.dark], for: .normal)
    }
    
    
    var body: some View {
        VStack {
            VStack {
                ScrollView {
                    TextFieldComponent(entry: $newAnchorName, label: "Name")
//                    TextFieldComponent(entry: $newPlace, label: "Organization")
                    VStack {
                        HStack {
                            Text("Type")
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
                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(AppColor.grey, lineWidth: 2)
                        )
                    }
                    .padding(.horizontal)
                    
                    if newCategory == .exit {
                        VStack {
                            HStack {
                                Text("Corresponding Exit")
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
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColor.grey, lineWidth: 2)
                            )
                        }
                        .padding(.horizontal)
                        
                    }
//                    TextFieldComponent(entry: $newNotes, label: "Location Notes", textBoxSize: .large)
//                    VStack {
//                        HStack {
//                            Text("Visibility")
//                                .font(.title2)
//                                .bold()
//                            Spacer()
//                        }
//                        HStack {
//                            Toggle("Public Anchor", isOn: $newIsReadable)
//                                .bold()
//                                .tint(AppColor.dark)
//                        }
//                        .frame(height: 48)
//                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(AppColor.grey, lineWidth: 2)
//                        )
//                    }
//                    .padding(.horizontal)
                    
                    VStack {
                        HStack {
                            Text("Visibility")
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        Picker("Anchor Visibility", selection: $newIsReadable) {
                            ForEach(visibilityOptions, id: \.self) {
                                if $0 == true {
                                    Text("Public")
                                } else {
                                    Text("Private")
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .colorMultiply(AppColor.accent)
                    }
                    .padding(.horizontal)

                    
                }
                Spacer()
            }
            .padding(.top, 20)
            
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
