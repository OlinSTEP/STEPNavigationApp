//
//  AnchorListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI

struct LocalAnchorListView: View {
    @EnvironmentObject private var anchorData: AnchorData
    let anchorType: AnchorDetails.AnchorType
    
    private let listBackgroundColor = AppColor.grey
    private let listTextColor = AppColor.black
    
    @State private var nearbyDistance: Double = 50
    @State private var maxDistance: Double = 200
    @State var showPopup = false
    
    var body: some View {
        VStack {
            HStack {
                Text("\(anchorType.rawValue) Anchors")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 20)
            
            HStack {
                Text("Within \(nearbyDistance, specifier: "%.0f") meters")
                    .font(.title)
                    .padding(.leading)
                if showPopup == false {
                    Image(systemName: "chevron.down")
                } else {
                    Image(systemName: "chevron.up")
                }
                // want to make the chevron bigger/easier to see/etc - not sure how thought??
                Spacer()
            }
            .padding(.bottom, 20)
            .onTapGesture {
                showPopup.toggle()
                // in real life would want to present dropdown popup
                
            }
            
            if showPopup == true {
                HStack {
                    Text("0")
                    Slider(value: $nearbyDistance, in: 0...maxDistance, step: 10)
                    Text("\(maxDistance, specifier: "%.0f")")
                }
                .frame(width: 300)
                .padding(.bottom, 20)
            }
        }
        .background(AppColor.accent)
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
        
        if anchors.isEmpty {
            VStack {
                Spacer()
                Text("Nothing nearby. Try widening your search radius.")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
        } else {
            
            ScrollView {
                VStack {
                    ForEach(anchors) {
                        anchor in
                        NavigationLink (
                            destination: AnchorDetailView(anchorDetails: anchor),
                            label: {
                                HStack {
                                    Text(anchor.name)
                                        .font(.title)
                                        .bold()
                                        .padding(30)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 140)
                                .foregroundColor(AppColor.black)
                            })
                        .background(AppColor.grey)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
    }
    
    private var anchors: [AnchorDetails] {
        anchorData.anchors(for: anchorType)
    }
}

struct AnchorListView_Previews: PreviewProvider {
    static var previews: some View {
        LocalAnchorListView(anchorType: .busStop)
            .environmentObject(AnchorData())
    }
}

class AnchorData: ObservableObject {
    @Published var anchors = AnchorDetails.testAnchors
    
    func anchors(for anchorType: AnchorDetails.AnchorType) -> [AnchorDetails] {
        var filteredAnchors = [AnchorDetails]()
        for anchor in anchors {
            if anchor.anchorType == anchorType {
                filteredAnchors.append(anchor)
            }
        }
        return filteredAnchors
    }
}
