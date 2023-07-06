//
//  Header.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct HeaderButton: ToolbarContent {
    let label: String
    let placement: ToolbarItemPlacement
    let color: Color
    let action: () -> Void
    
    init(label: String, placement: ToolbarItemPlacement, color: Color = AppColor.background, action: @escaping () -> Void) {
        self.label = label
        self.placement = placement
        self.color = color
        self.action = action
    }
    
    @ViewBuilder
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button {
                action()
            } label: {
                Text(label)
                    .bold()
                    .font(.title2)
                    .foregroundColor(color)
            }
        }
    }
}

struct HeaderNavigationLink<Destination: View>: ToolbarContent {
    let label: String
    let placement: ToolbarItemPlacement
    let color: Color
    let destination: Destination
    
    init(label: String, placement: ToolbarItemPlacement, color: Color = AppColor.background, destination: Destination) {
        self.label = label
        self.placement = placement
        self.color = color
        self.destination = destination
    }
    
    @ViewBuilder
    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            NavigationLink(destination: destination, label: {
                Text(label)
                    .bold()
                    .font(.title2)
                    .foregroundColor(color)
            })
        }
    }
}

struct CustomBackButton<Destination: View>: ToolbarContent {
    let destination: Destination
    
    init(destination: Destination) {
        self.destination = destination
    }
    
    @ViewBuilder
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            NavigationLink(destination: destination, label: {
                HStack {
                    Image(systemName: "chevron.backward")
                        .bold()
                        .accessibilityHidden(true)
                    Text("Back")
                        .foregroundColor(AppColor.background)
                }
            })
        }
    }
}

struct ScreenHeader: View {
    let title: String
    let subtitle: String
    let backButtonHidden: Bool
                    
    init(title: String = "", subtitle: String = "", backButtonHidden: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.backButtonHidden = backButtonHidden
    }
    
    var body: some View {
        VStack {
            if !title.isEmpty {
                HStack {
                    Text(title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.bottom, subtitle != "" ? 0.5 : 20)
            }
            
            if !subtitle.isEmpty {
                HStack {
                    Text(subtitle)
                        .font(.title2)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            
            if title.isEmpty && subtitle.isEmpty {
                HStack {
                    Spacer()
                    Rectangle()
                        .frame(height: 0)
                        .background(AppColor.foreground)
                    Spacer()
                }
            }
        }
        .padding(.top, backButtonHidden ? 40 : 0)
        .navigationBarBackButtonHidden(backButtonHidden)
        .background(AppColor.foreground)
        .foregroundColor(AppColor.background)
    }
}
