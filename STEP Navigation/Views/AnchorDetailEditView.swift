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
    
    @State var editing: Bool = false
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
        VStack {
            VStack {
                ScrollView {
                    TextFieldComponent(entry: $newAnchorName, label: "Name")
                    
                    VStack {
                        HStack {
                            Text("Organization")
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            Group {
                                TextField("", text: $newOrganization, onEditingChanged: { edit in
                                            self.editing = edit}).padding(.horizontal, 10)
                            }
                            .frame(height: 48)
                            .background(AppColor.light)
                            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColor.dark, lineWidth: 2)
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
                                .stroke(AppColor.dark, lineWidth: 2)
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
                                    .stroke(AppColor.dark, lineWidth: 2)
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
            NavigationLink(destination: buttonDestination(), isActive: $confirmPressed, label: {
                Text("\(buttonLabel)")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(AppColor.light)
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
                            isReadable: newIsReadable,
                            organization: newOrganization,
                            notes: newNotes)
        FirebaseManager.shared.updateCloudAnchor(identifier: anchorID, metadata: newMetadata)
    }
}

struct OrganizationComboBox: View {
    @ObservedObject var dataModelManager = DataModelManager.shared
    @State var allOrganizations: [String] = []

    @Binding var editing: Bool
    @Binding var inputText: String
    @State var verticalOffset: CGFloat
    @State var horizontalOffset: CGFloat
    
    public init(editing: Binding<Bool>, text: Binding<String>, verticalOffset: CGFloat, horizontalOffset: CGFloat) {
        self._editing = editing
        self._inputText = text
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
        self._allOrganizations = State(initialValue: dataModelManager.getAllNearbyOrganizations())
    }

    private var filteredTexts: Binding<[String]> {
        Binding(
            get: {
                let lowercasedInputText = inputText.lowercased()
                return allOrganizations.filter { $0.lowercased().localizedCaseInsensitiveContains(lowercasedInputText) }
            },
            set: { _ in }
        )
    }
    
    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredTexts.wrappedValue, id: \.self) { textSearched in
                        Text(textSearched)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 25)
                            .frame(minWidth: 0,
                                   maxWidth: .infinity,
                                   minHeight: 0,
                                   maxHeight: 50,
                                   alignment: .leading)
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                inputText = textSearched
                                editing = false
                                print(editing)
                                self.endTextEditing()
                            })
                        Divider()
                            .padding(.horizontal, 10)
                    }
                }
            }
            .background(AppColor.light)
            .cornerRadius(15)
            .foregroundColor(AppColor.dark)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity,
                   minHeight: 0,
                   maxHeight: 50 * CGFloat( (filteredTexts.wrappedValue.count > 3 ? 3: filteredTexts.wrappedValue.count)))
            .shadow(color: AppColor.dark, radius: 4)
            .offset(x: horizontalOffset, y: verticalOffset)
            .isHidden(!editing, remove: !editing)
            
            Spacer()
        }
        .frame(height: (50 * CGFloat((filteredTexts.wrappedValue.count > 3 ? 3 : filteredTexts.wrappedValue.count)) + (editing == true ? verticalOffset : 0)))
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
