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
    
    var body: some View {
        VStack {
            HStack {
                Text("Nearby \(anchorType.rawValue)s")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 20)
            HStack {
                Text("Within 0.5 miles")
                    .font(.title)
                    .padding(.leading)
                Image(systemName: "chevron.down")
                // want to make the chevron bigger/easier to see/etc - not sure how thought??
                    .onTapGesture {
                        print("Tapped chevron to change distance")
                        // in real life would want to present dropdown popup
                    }
                Spacer()
            }
            .padding(.bottom, 20)
        }
        .background(AppColor.accent)
        
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
