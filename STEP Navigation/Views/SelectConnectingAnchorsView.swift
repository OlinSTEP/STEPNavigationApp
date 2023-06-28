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
    @State var connectionStatuses: [ConnectionStatus] = []
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
                .foregroundColor(AppColor.foreground)
            
            ScrollView {
                VStack(spacing: 20) {
//                    ForEach(0..<anchors.count, id: \.self) { idx in
//                        if anchors[idx].id != anchorID1 {
//                            LargeButtonComponent_NavigationLink(destination: {
//                                ConnectingView(anchorID1: anchorID1, anchorID2: anchors[idx].id)
//                            }, label: "\(anchors[idx].getName())", labelColor: connectionStatuses[idx].connectionColor, labelTextSize: .title, labelTextLeading: true)
//                        }
//                    }
                    ForEach(0..<anchors.count, id: \.self) { idx in
                        if anchors[idx].id != anchorID1 {
                            VStack {
                                LargeButtonComponent_NavigationLink(destination: {
                                    ConnectingView(anchorID1: anchorID1, anchorID2: anchors[idx].id)
                                }, label: "\(anchors[idx].getName())", labelColor: connectionStatuses[idx].connectionColor, labelTextSize: .title, labelTextLeading: true)

                                if connectionStatuses[idx] == .notConnected {
                                    Text("Not connected to any other anchors")
                                        .foregroundColor(.red)
                                }
                            }
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
            connectionStatuses = FirebaseManager.shared.mapGraph.getConnectionStatus(from: anchorID1, to: anchors)
        }
        
    }
}

