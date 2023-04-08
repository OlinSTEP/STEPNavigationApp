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
                    Text(anchorDetails.name)
                        .navigationBarTitleDisplayMode(.inline)
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Location Notes")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                            .padding(.top)
                            .padding(.bottom, 5)
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
                .padding()
                Spacer()
                Button (action: {
                    print("Pressed navigate")
                }, label: {
                    Text("Navigate")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: 300)
                        .foregroundColor(AppColor.black)
                })
                .padding(.bottom, 20)
                .tint(AppColor.accent)
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
            }
    }
}

struct AnchorDetailView_Previews: PreviewProvider {
    @State static var anchorDetails = AnchorDetails.testAnchors[0]

    
    static var previews: some View {
            AnchorDetailView(anchorDetails: anchorDetails)
    }
}
