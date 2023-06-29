//
//  Miscellaneous.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct AnchorDetailsText: View {
    let title: String
    let distanceAway: Double
    let locationNotes: String
    let textColor: Color
    
    init(title: String, distanceAway: Double, locationNotes: String = "", textColor: Color = AppColor.foreground) {
        self.title = title
        self.distanceAway = distanceAway
        self.locationNotes = locationNotes
        self.textColor = textColor
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
            
            HStack {
                    Text("\(String(format: "%.0f", distanceAway)) meters away") //TODO: make this dynamic so it can be imperial or metric
                        .font(.title)
                        .padding(.horizontal)
                Spacer()
            }
            VStack {
                HStack {
                    Text("Location Notes")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 1)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                ScrollView {
                    HStack {
                        if locationNotes.isEmpty {
                            Text("No notes available for this location.")
                        } else {
                            Text(locationNotes)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
        }
        .foregroundColor(AppColor.foreground)
    }
}

struct ChecklistItem: View {
    @Binding var toggle: Bool
    let label: String
    let textColor: Color
    
    init(toggle: Binding<Bool>, label: String, textColor: Color = AppColor.foreground) {
            self._toggle = toggle
            self.label = label
            self.textColor = textColor
        }
    
    var body: some View {
        VStack {
            Button(action: {
                toggle.toggle()
            }) {
                HStack {
                    Text(label)
                        .font(.title2)
                        .padding(4)
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    if toggle {
                        Image(systemName: "checkmark")
                            .font(.system(size: 26))
                            .foregroundColor(textColor)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
