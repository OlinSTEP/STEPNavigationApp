//
//  AnchorListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI

struct AnchorListView: View {
    @EnvironmentObject private var anchorData: AnchorData
    let anchorType: AnchorDetails.AnchorType
    
    private let listBackgroundColor = AppColor.grey
    private let listTextColor = AppColor.black
    
    var body: some View {
        NavigationView {
            List {
                ForEach(anchors) {
                    anchor in Text("\(anchor.name)")
                }
                .listRowBackground(listBackgroundColor)
                .foregroundColor(listTextColor)
            }
            .navigationTitle("Nearby Anchors")
        }
    }
    
    private var anchors: [AnchorDetails] {
        anchorData.anchors(for: anchorType)
    }
}

struct AnchorListView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorListView(anchorType: .busStop)
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
