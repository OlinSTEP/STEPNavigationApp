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
    let subLabel: String
    let foregroundColor: Color
    let backgroundColor: Color
    let invert: Bool
    let alignment: LargeTextAlignment
    let secondaryAction: () -> Void
    @State private var pressed: Bool = false

    
    init(destination: Destination, label: String, subLabel: String = "", foregroundColor: Color = AppColor.foreground, backgroundColor: Color = AppColor.background, invert: Bool = false, alignment: LargeTextAlignment = .left, secondaryAction: @escaping () -> Void = {}) {
        self.destination = destination
        self.label = label
        self.subLabel = subLabel
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
                VStack {
                    HStack {
                        Text(label)
                            .font(alignment == .left ? .title : .largeTitle)
                            .bold()
                        if alignment == .left {
                            Spacer()
                        }
                    }
                    HStack {
                        if !subLabel.isEmpty {
                            Text(subLabel)
                                .font(alignment == .left ? .title2 : .title)
                        }
                        if alignment == .left {
                            Spacer()
                        }
                    }
                }
                .foregroundColor(invert ? foregroundColor : backgroundColor)
                .multilineTextAlignment(alignment == .left ? .leading : .center)
                .padding(30)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 130)
                .background(invert ? backgroundColor : foregroundColor)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(foregroundColor, lineWidth: 5)
                )
            })
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
            .frame(maxWidth: .infinity)
            .frame(minHeight: 130)
            .background(invert ? backgroundColor : foregroundColor)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(foregroundColor, lineWidth: 5)
            )
        }
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
                        .padding(6)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 54)
                .background(invert ? backgroundColor : foregroundColor)
                .cornerRadius(54)
                .overlay(
                    RoundedRectangle(cornerRadius: 54)
                        .stroke(foregroundColor, lineWidth: 3)
                )
            })
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
                    .padding(6)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .background(invert ? backgroundColor : foregroundColor)
            .cornerRadius(54)
            .overlay(
                RoundedRectangle(cornerRadius: 54)
                    .stroke(foregroundColor, lineWidth: 3)
            )
        }
        .padding(.horizontal)
    }
}

struct SmallButton_Settings: View {
    let action: () -> Void
    let label: String
    let selected: Bool
    let color1: Color
    let color2: Color
    
    init(action: @escaping () -> Void, label: String, selected: Bool, color1: Color, color2: Color) {
        self.action = action
        self.label = label
        self.selected = selected
        self.color1 = color1
        self.color2 = color2
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.title2)
                    .bold()
                    .foregroundColor(selected ? color2 : AppColor.foreground)
                    .multilineTextAlignment(.center)
                    .padding(6)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 54)
            .background(selected ? color1 : AppColor.background)
            .cornerRadius(54)
            .overlay(
                RoundedRectangle(cornerRadius: 54)
                    .strokeBorder(selected ? (color1 == AppColor.background ? AppColor.foreground : color1) : AppColor.foreground, style: StrokeStyle(lineWidth: 3, dash: [selected ? (color1 == AppColor.background ? 8 : .infinity) : .infinity]))
            )
        }
        .padding(.horizontal)
    }
}
