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
                            notes: newNotes)
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
        if inputText == "" {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<allOrganizations.count, id: \.self) { idx in
                            Text(allOrganizations[idx])
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
                                    inputText = allOrganizations[idx]
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
            .frame(height: (editing == false ? 0 : (50 * CGFloat((allOrganizations.count > 3 ? 3 : allOrganizations.count)) + (editing == true ? verticalOffset : 0))))
        } else {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredTexts.wrappedValue, id: \.self) { textSearched in
                            Text(textSearched)
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
                                    inputText = textSearched
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
                       maxHeight: 50 * CGFloat((filteredTexts.wrappedValue.count > 3 ? 3: filteredTexts.wrappedValue.count))
                )
                .offset(x: horizontalOffset, y: verticalOffset)
                .isHidden(!editing, remove: !editing)
                
                Spacer()
            }
            .frame(height: (50 * CGFloat((filteredTexts.wrappedValue.count > 3 ? 3 : filteredTexts.wrappedValue.count)) + (editing == true ? verticalOffset : 0)))
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
