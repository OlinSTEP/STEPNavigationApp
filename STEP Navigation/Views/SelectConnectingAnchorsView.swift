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
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Select Anchor to Connect to \(anchorName)")
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(ConnectionStatus.allCases, id: \.self) { status in
                            if connectionStatuses.contains(status) {
                                VStack {
                                    LeftLabel(text: status.connectionText)
                                    if status == .connectedDirectly {
                                        HStack {
                                            Text("Selecting one of these anchors will override the existing connection.")
                                                .font(.title3)
                                            Spacer()
                                        }
                                    }
                                }
                                .foregroundColor(AppColor.foreground)
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                            ForEach(0..<anchors.count, id: \.self) { idx in
                                if connectionStatuses[idx] == status {
                                    LargeNavigationLink(destination: ConnectingView(anchorID1: anchorID1, anchorID2: anchors[idx].id), label: anchors[idx].getName(), invert: status == .connectedDirectly)
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
                anchors.removeAll{$0.id == anchorID1}
                connectionStatuses = FirebaseManager.shared.mapGraph.getConnectionStatus(from: anchorID1, to: anchors)
            }
        }
    }
}
