//
//  ButtonComponents.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/6/23.
//

import SwiftUI

// Components in this file:
//  - Small Button _ Navigation Link
//  - Small Button _ Button
//  - Large Button _ Navigation Link
//  - Large Button _ Button

/// This struct manages the appearance of small button components that are navigation links. Their visual appearance is identical to the small button components that are buttons.
struct SmallButtonComponent_NavigationLink<Destination: View>: View {
    let destination: () -> Destination
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    
    /// Init Method
    /// - Parameters:
    ///   - destination: the destination screen for the navigation link
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    init(destination: @escaping () -> Destination, label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent) {
        self.destination = destination
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
    }
    
    
    var body: some View {
            NavigationLink(destination: destination, label: {
                Text(label)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(labelColor)
            })
            .tint(backgroundColor)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .padding(.horizontal)
    }
}

/// This struct manages the appearance of small button components that are buttons. Their visual appearance is identical to the small button components that are navigation links.
struct SmallButtonComponent_PopupTrigger: View {
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    @Binding var popupTrigger: Bool
    let role: ButtonRole?
    
    /// Init Method
    /// - Parameters:
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    ///   - popupTrigger: a boolean that is toggled by pressing the button
    ///   - role: an optional specifier for the role of the button, can take values such as .cancel, .destructive, and more
    init(label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent, popupTrigger: Binding<Bool>, role: ButtonRole? = nil){
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
        self._popupTrigger = popupTrigger
        self.role = role
    }
    
    
    var body: some View {
        
        Button(role: role) {
            popupTrigger.toggle()
        } label: {
            Text(label)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .foregroundColor(labelColor)
        }
        .tint(backgroundColor)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .padding(.horizontal)
    }
}

struct SmallButtonComponent_Button: View {
    let label: String
    let action: () -> Void
    let labelColor: Color?
    let backgroundColor: Color?
    
    
    init(label: String, action: @escaping () -> Void, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent){
        self.label = label
        self.action = action
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
    }
    
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .foregroundColor(labelColor)
        }
        .tint(backgroundColor)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .padding(.horizontal)
    }
}

/// This struct manages the appearance of large button components that are navigation links. Their visual appearance is identical to the large button components that are buttons.
struct LargeButtonComponent_NavigationLink<Destination: View>: View {
    let destination: () -> Destination
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    let labelTextSize: Font?
    let labelTextLeading: Bool?
    
    /// Init Method
    /// - Parameters:
    ///   - destination: the destination screen for the navigation link
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    ///   - labelTextSize: an optional specifier to change the text size of the label; if not text size is specified, the default is .largeTitle
    ///   - labelTextLeading: an optional boolean to make the text leading (left-aligned); by default the boolean is set to false and the text is centered
    init(destination: @escaping () -> Destination, label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent, labelTextSize: Font? = .largeTitle, labelTextLeading: Bool? = false) {
        self.destination = destination
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
        self.labelTextSize = labelTextSize
        self.labelTextLeading = labelTextLeading
    }
    
    var body: some View {
        NavigationLink (
            destination: destination,
            label: {
                HStack {
                    Text(label)
                        .font(labelTextSize)
                        .bold()
                        .padding(30)
                        .foregroundColor(labelColor)
                        .multilineTextAlignment(.leading)
                    if labelTextLeading == true {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 140)
            })
        .background(backgroundColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

/// This struct manages the appearance of large button components that are buttons Their visual appearance is identical to the large button components that are navigation links.
struct LargeButtonComponent_Button: View {
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    let action: () -> Void
    
    /// Init Method
    /// - Parameters:
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    ///   - action: the action for the button to perform, can take any length of code
    init(label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent, action: @escaping () -> Void ) {
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.title)
                    .bold()
                    .padding(30)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(labelColor)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 140)
        }
        .background(backgroundColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}
