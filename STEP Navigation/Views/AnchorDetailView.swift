//
//  AnchorDetailView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI

struct AnchorDetailView: View {
    let anchorDetails: AnchorDetails
    
    private let listBackgroundColor = AppColor.grey
    private let listTextColor = AppColor.black
    
    var body: some View {
        VStack {
            HStack {
                Text(anchorDetails.locationAddress)
                    .font(.title)
                    .padding()
                Spacer()
            }
            VStack {
                HStack {
                    Text("Location Notes")
                        .font(.title)
                        .padding()
                    Spacer()
                }
                HStack {
                    Text(anchorDetails.notes)
                        .padding()
                    Spacer()
                }
            }
            Spacer()
            Button (action: {
                print("Pressed navigate")
            }, label: {
                Text("Navigate")
            })
            Button (action: {
                print("Pressed cancel")
            }, label: {
                Text("Cancel")
            })
        }
        .navigationTitle(anchorDetails.name)
    }
}

struct AnchorDetailView_Previews: PreviewProvider {
    @State static var anchorDetails = AnchorDetails.testAnchors[0]

    
    static var previews: some View {
        NavigationView {
            AnchorDetailView(anchorDetails: anchorDetails)
        }
    }
}
