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
            Text(label)
                .bold()
                .font(.title2)
                .foregroundColor(color)
                .onTapGesture {
                    action()
                }
                .accessibilityAction {
                    action()
                }
        }
    }
}

struct ScreenHeader: View {
    let title: String
    let subtitle: String
    let backButtonHidden: Bool
                    
    init(title: String, subtitle: String = "", backButtonHidden: Bool = false) {
        self.title = title
        self.subtitle = subtitle
        self.backButtonHidden = backButtonHidden
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.bottom, subtitle != "" ? 0.5 : 20)
            
            if subtitle != "" {
                HStack {
                    Text(subtitle)
                        .font(.title2)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.top, backButtonHidden ? 40 : 0)
        .navigationBarBackButtonHidden(backButtonHidden)
        .background(AppColor.foreground)
        .foregroundColor(AppColor.background)
    }
}
