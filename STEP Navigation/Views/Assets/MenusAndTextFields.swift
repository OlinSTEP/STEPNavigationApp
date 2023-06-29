//
//  MenusAndTextFields.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct SegmentedToggle: View {
    @Binding var toggle: Bool
    let trueLabel: String
    let falseLabel: String
    let foregroundColor: Color
    let backgroundColor: Color
    
    init(toggle: Binding<Bool>, trueLabel: String, falseLabel: String, foregroundColor: Color = AppColor.foreground, backgroundColor: Color = AppColor.background) {
        self._toggle = toggle
        self.trueLabel = trueLabel
        self.falseLabel = falseLabel
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(backgroundColor)
                Rectangle()
                    .fill(foregroundColor)
                   .cornerRadius(10)
                   .opacity(toggle ? 1 : 0.01)
                   .onTapGesture {
                           withAnimation(.interactiveSpring()) {
                               toggle = true
                           }
                       }
            }
            .overlay(
               Text(trueLabel)
                   .foregroundColor(toggle ? backgroundColor : foregroundColor)
                   .bold()
                   .accessibilityAction {
                          withAnimation(.interactiveSpring()) {
                              toggle = true
                          }
                      }
                .accessibilityAddTraits(toggle ? .isSelected : [])
           )
            
            ZStack {
                Rectangle()
                    .fill(backgroundColor)
                Rectangle()
                    .fill(foregroundColor)
                   .cornerRadius(10)
                   .opacity(!toggle ? 1 : 0.01)
                   .onTapGesture {
                           withAnimation(.interactiveSpring()) {
                               toggle = false
                           }
                       }
            }
            .overlay(
               Text(falseLabel)
                   .foregroundColor(!toggle ? backgroundColor : foregroundColor)
                   .bold()
                   .accessibilityAction {
                          withAnimation(.interactiveSpring()) {
                              toggle = false
                          }
                      }
                .accessibilityAddTraits(!toggle ? .isSelected : [])
           )
        }
        .frame(height: 40)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(foregroundColor, lineWidth: 2)
        )
    }
}

struct CustomTextField: View {
    @Binding var entry: String
    let textBoxSize: TextBoxSizes
    let foregroundColor: Color

    @FocusState private var entryIsFocused: Bool

    init(entry: Binding<String>, textBoxSize: TextBoxSizes = .small, foregroundColor: Color = AppColor.foreground) {
        self._entry = entry
        self.textBoxSize = textBoxSize
        self.foregroundColor = foregroundColor
    }

    var body: some View {
        VStack {
            if textBoxSize == .small {
                TextField("", text: $entry)
                    .foregroundColor(foregroundColor)
                    .frame(height: 48)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(foregroundColor, lineWidth: 2)
                    )
                    .submitLabel(.done)
            } else if textBoxSize == .large {
                TextField("", text: $entry, axis: .vertical)
                    .foregroundColor(foregroundColor)
                    .frame(height: 146)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(foregroundColor, lineWidth: 2)
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
}

enum TextBoxSizes {
    case small, large
}

struct ComboBoxMenu: View {
    let allOptions: [String]
    @Binding var editing: Bool
    @Binding var inputText: String
    let verticalOffset: CGFloat
    let horizontalOffset: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    
    public init(allOptions: [String], editing: Binding<Bool>, text: Binding<String>, verticalOffset: CGFloat, horizontalOffset: CGFloat, foregroundColor: Color, backgroundColor: Color) {
        self.allOptions = allOptions
        self._editing = editing
        self._inputText = text
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }

    private var filteredTexts: Binding<[String]> {
        Binding(
            get: {
                let lowercasedInputText = inputText.lowercased()
                return allOptions.filter { $0.lowercased().localizedCaseInsensitiveContains(lowercasedInputText) }
            },
            set: { _ in }
        )
    }
    
    public var body: some View {
        if inputText == "" {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<allOptions.count, id: \.self) { idx in
                            Text(allOptions[idx])
                                .foregroundColor(foregroundColor)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 25)
                                .frame(minWidth: 0,
                                       maxWidth: .infinity,
                                       minHeight: 0,
                                       maxHeight: 50,
                                       alignment: .leading)
                                .contentShape(Rectangle())
                                .onTapGesture(perform: {
                                    inputText = allOptions[idx]
                                    editing = false
                                    self.endTextEditing()
                                })
                            Divider()
                                .overlay(foregroundColor)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .background(backgroundColor)
                .cornerRadius(15)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity,
                       minHeight: 0,
                       maxHeight: 50 * CGFloat((allOptions.count > 3 ? 3: allOptions.count))
                )
                .offset(x: horizontalOffset, y: verticalOffset)
                .isHidden(!editing, remove: !editing)
                Spacer()
            }
            .frame(height: (editing == false ? 0 : (50 * CGFloat((allOptions.count > 3 ? 3 : allOptions.count)) + (editing == true ? verticalOffset : 0))))
        } else {
            VStack {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredTexts.wrappedValue, id: \.self) { textSearched in
                            Text(textSearched)
                                .foregroundColor(foregroundColor)
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
                                .overlay(foregroundColor)
                                .padding(.horizontal, 10)
                        }
                    }
                }
                .background(backgroundColor)
                .cornerRadius(15)
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

struct ComboBox: View {
    let allOptions: [String]
    @Binding var editing: Bool
    @Binding var inputText: String
    let verticalOffset: CGFloat
    let horizontalOffset: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    @FocusState var editingFocus: Bool
    
    init(allOptions: [String], editing: Binding<Bool>, inputText: Binding<String>, verticalOffset: CGFloat = 52, horizontalOffset: CGFloat = 0, foregroundColor: Color = AppColor.background, backgroundColor: Color = AppColor.foreground) {
        self.allOptions = allOptions
        self._editing = editing
        self._inputText = inputText
        self.verticalOffset = verticalOffset
        self.horizontalOffset = horizontalOffset
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }


    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            Group {
                TextField("", text: $inputText, onEditingChanged: {edit in
                    self.editing = edit
                })
                .padding(.horizontal, 10)
                .focused($editingFocus)
            }
            .foregroundColor(backgroundColor)
            .frame(height: 48)
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(backgroundColor, lineWidth: 2)
            )
            ComboBoxMenu(allOptions: allOptions, editing: $editing, text: $inputText, verticalOffset: verticalOffset, horizontalOffset: horizontalOffset, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
            Spacer()
        }
    }
}

struct PickerPage: View {
    let allOptions: [String]
    @Binding var selection: String
    @Binding var showPage: Bool
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScrollView {
                    Divider()
                        .overlay(AppColor.foreground)
                    ForEach(allOptions, id: \.self) { option in
                        Button(action: {
                            selection = option
                            showPage = false
                        }, label: {
                            
                            HStack {
                                Text(option)
                                    .font(.title2)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                if selection == option {
                                    Image(systemName: "checkmark")
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
            .toolbar {
                HeaderButton(label: "Done", placement: .navigationBarLeading, action:  {
                    showPage = false
                })
            }
            .navigationTitle("")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(AppColor.foreground, for: .navigationBar)
        }
    }
}

struct PickerButton: View {
    @Binding var selection: String
    @Binding var showPage: Bool

    var body: some View {
        Group {
            Button(action: {
                withAnimation {
                    showPage = true
                }
            }, label: {
                HStack {
                    Text(selection)
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
    }
}
