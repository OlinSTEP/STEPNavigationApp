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
                //need to add in 20 units of spacing colored spacing here
                
                HStack {
                    Text(anchorDetails.name)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 2)
                    Spacer()
                }
                
                HStack {
                    let formattedDistance = String(format: "%g", anchorDetails.distanceAway)

                    Text("\(formattedDistance) meters away")
                        .font(.title)
                        .padding(.horizontal)
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Location Notes")
                            .font(.title2)
                            .bold()
                            .padding(.bottom, 5)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    HStack {
                        Text(anchorDetails.notes)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
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
            .navigationBarItems(
                trailing:
                    Button(action: {
                        print("pressed settings")
                    }) {
                        Image(systemName: "gearshape.fill")
                            .scaleEffect(1.5)
                            .foregroundColor(AppColor.black)
                    }
            )
    }
}

struct AnchorDetailView_Previews: PreviewProvider {
    @State static var anchorDetails = AnchorDetails.testAnchors[0]

    
    static var previews: some View {
            AnchorDetailView(anchorDetails: anchorDetails)
    }
}
