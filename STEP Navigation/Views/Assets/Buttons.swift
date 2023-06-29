//
//  Buttons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct LargeNavigationLink<Destination: View>: View {
    let destination: Destination
    let label: String
    let foregroundColor: Color
    let backgroundColor: Color
    let invert: Bool
    let alignment: LargeTextAlignment
    let secondaryAction: () -> Void
    @State private var pressed: Bool = false

    
    init(destination: Destination, label: String, foregroundColor: Color = AppColor.foreground, backgroundColor: Color = AppColor.background, invert: Bool = false, alignment: LargeTextAlignment = .left, secondaryAction: @escaping () -> Void = {}) {
        self.destination = destination
        self.label = label
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.invert = invert
        self.alignment = alignment
        self.secondaryAction = secondaryAction
    }
    
    var body: some View {
        NavigationLink (
            destination: destination,
            isActive: $pressed,
            label: {
                HStack {
                    Text(label)
                        .font(alignment == .left ? .title : .largeTitle)
                        .bold()
                        .padding(30)
                        .foregroundColor(invert ? foregroundColor : backgroundColor)
                        .multilineTextAlignment(alignment == .left ? .leading : .center)
                    if alignment == .left {
                        Spacer()
                    }
                }
            })
        .frame(maxWidth: .infinity)
        .frame(minHeight: 130)
        .background(invert ? backgroundColor : foregroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(foregroundColor, lineWidth: 5)
        )
        .padding(.horizontal)
        .onChange(of: pressed) {
            newValue in
            if newValue {
                secondaryAction()
            }
        }
    }
}

struct LargeButton: View {
    let action: () -> Void
    let label: String
    let foregroundColor: Color
    let backgroundColor: Color
    let invert: Bool
    let alignment: LargeTextAlignment
    
    init(action: @escaping () -> Void, label: String, foregroundColor: Color = AppColor.foreground, backgroundColor: Color = AppColor.background, invert: Bool = false, alignment: LargeTextAlignment = .left) {
        self.action = action
        self.label = label
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.invert = invert
        self.alignment = alignment
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(alignment == .left ? .title : .largeTitle)
                    .bold()
                    .padding(30)
                    .foregroundColor(invert ? foregroundColor : backgroundColor)
                    .multilineTextAlignment(alignment == .left ? .leading : .center)
                if alignment == .left {
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 130)
        .background(invert ? backgroundColor : foregroundColor)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(foregroundColor, lineWidth: 5)
        )
        .padding(.horizontal)
    }
}

enum LargeTextAlignment {
    case left, center
}

struct SmallNavigationLink<Destination: View>: View {
    let destination: Destination
    let label: String
    let foregroundColor: Color
    let backgroundColor: Color
    let invert: Bool
    let secondaryAction: () -> Void
    @State private var pressed: Bool = false

    
    init(destination: Destination, label: String, foregroundColor: Color = AppColor.foreground, backgroundColor: Color = AppColor.background, invert: Bool = false, secondaryAction: @escaping () -> Void = {}) {
        self.destination = destination
        self.label = label
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.invert = invert
        self.secondaryAction = secondaryAction
    }
    
    var body: some View {
        NavigationLink (
            destination: destination,
            isActive: $pressed,
            label: {
                HStack {
                    Text(label)
                        .font(.title2)
                        .bold()
                        .foregroundColor(invert ? foregroundColor : backgroundColor)
                        .multilineTextAlignment(.center)
                }
            })
        .frame(maxWidth: .infinity)
        .frame(minHeight: 54)
        .background(invert ? backgroundColor : foregroundColor)
        .cornerRadius(54)
        .overlay(
            RoundedRectangle(cornerRadius: 54)
                .stroke(foregroundColor, lineWidth: 3)
        )
        .padding(.horizontal)
        .onChange(of: pressed) {
            newValue in
            if newValue {
                secondaryAction()
            }
        }
    }
}

struct SmallButton: View {
    let action: () -> Void
    let label: String
    let foregroundColor: Color
    let backgroundColor: Color
    let invert: Bool
    
    init(action: @escaping () -> Void, label: String, foregroundColor: Color = AppColor.foreground, backgroundColor: Color = AppColor.background, invert: Bool = false) {
        self.action = action
        self.label = label
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.invert = invert
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.title2)
                    .bold()
                    .foregroundColor(invert ? foregroundColor : backgroundColor)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 54)
        .background(invert ? backgroundColor : foregroundColor)
        .cornerRadius(54)
        .overlay(
            RoundedRectangle(cornerRadius: 54)
                .stroke(foregroundColor, lineWidth: 3)
        )
        .padding(.horizontal)
    }
}
