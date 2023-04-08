//
//  AnchorDetailView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI

struct AnchorDetailView: View {
    let anchorDetails: AnchorDetails
    
    var body: some View {
            VStack {
                HStack {
                    Text(anchorDetails.locationAddress)
                        .font(.title)
                        .padding(.horizontal)
                        .padding(.bottom)
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Location Notes")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top)
                            .foregroundColor(AppColor.black)
                        Spacer()
                    }
                    HStack {
                        Text(anchorDetails.notes)
                            .padding(.horizontal)
                            .padding(.bottom)
                            .foregroundColor(AppColor.black)
                        Spacer()
                    }
                }
                .background(AppColor.grey)
                Spacer()
                Button (action: {
                    print("Pressed navigate")
                }, label: {
                    Text("Navigate")
                        .font(.title)
                        .frame(maxWidth: 300)
                        .foregroundColor(AppColor.black)
                })
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
            .navigationTitle(anchorDetails.name)
    }
}

struct AnchorDetailView_Previews: PreviewProvider {
    @State static var anchorDetails = AnchorDetails.testAnchors[0]

    
    static var previews: some View {
            AnchorDetailView(anchorDetails: anchorDetails)
    }
}
