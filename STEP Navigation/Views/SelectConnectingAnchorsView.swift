//
//  SelectConnectingAnchorsView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/14/23.
//

import SwiftUI
import CoreLocation

struct SelectConnectingAnchorsView: View {
    let anchorID1: String
    
    @ObservedObject var positionModel = PositioningModel.shared
    @ObservedObject var dataModelManager = DataModelManager.shared
    @State var anchors: [LocationDataModel] = []
    @State var lastQueryLocation: CLLocationCoordinate2D?

    
    @State var anchorName: String
    let metadata: CloudAnchorMetadata
    
    init(anchorID1: String) {
        self.anchorID1 = anchorID1
        metadata = FirebaseManager.shared.getCloudAnchorMetadata(byID: anchorID1)!
        anchorName = metadata.name
    }

    
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Select Second Anchor")
            Text("Connect \(anchorName) to:")
            
            ScrollView {
                //TODO: make it so that the anchor you are connecting from doesn't show up in the list
                VStack(spacing: 20) {
                    ForEach(0..<anchors.count, id: \.self) { idx in
                        if anchors[idx].id != anchorID1 {
                            LargeButtonComponent_NavigationLink(destination: {
                                ConnectingView(anchorID1: anchorID1, anchorID2: anchors[idx].id)
                            }, label: "\(anchors[idx].getName())", labelTextSize: .title, labelTextLeading: true)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            Spacer()
        }
        .onReceive(positionModel.$currentLatLon) { latLon in
            guard let latLon = latLon else {
                return
            }
            guard lastQueryLocation == nil || lastQueryLocation!.distance(from: latLon) > 5.0 else {
                return
            }
            lastQueryLocation = latLon
            anchors = Array(
                DataModelManager.shared.getNearbyIndoorLocations(
                    location: latLon,
                    maxDistance: CLLocationDistance(Double.infinity),
                    withBuffer: 0.0
                )
            )
            .sorted(by: {
                $0.getName() < $1.getName()         // sort in alphabetical order (could also do by distance as we have done in another branch)
            })
        }
        
    }
}

