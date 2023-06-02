//
//  Components.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/2/23.
//

import SwiftUI

struct ScreenTitleComponent: View {
    let titleText: String
    let subtitleText: String?

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
    }
}

struct CustomHeaderButtonComponent: View {
    var body: some View {
        Text("Blank")
    }
}


struct SmallButtonComponent_NavigationLink<Destination: View>: View {
    let destination: () -> Destination
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    
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
                    .frame(maxWidth: 300)
                    .foregroundColor(labelColor)
            })
            .tint(backgroundColor)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
    }
}

struct SmallButtonComponent_Button: View {
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    @Binding var popupTrigger: Bool
    let role: ButtonRole?
    
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
                .frame(maxWidth: 300)
                .foregroundColor(labelColor)
        }
        .tint(backgroundColor)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
    }
}

struct LargeButtonComponent_NavigationLink<Destination: View>: View {
    let destination: () -> Destination
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    let labelTextSize: Font?
    let labelTextLeading: Bool?
    
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

struct LargeButtonComponent_Button: View {
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    let action: () -> Void
    
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

struct InformationPopupComponent: View {
    var body: some View {
        Text("Blank")
    }
}


struct AnchorDetailsComponent: View {
    var body: some View {
        Text("Blank")
    }
}

struct ActionBarComponent: View {
    var body: some View {
        Text("Blank")
    }
}
