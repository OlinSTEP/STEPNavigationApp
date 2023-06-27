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
            ScreenTitleComponent(titleText: "Select Anchor to Connect to \(anchorName)")
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(ConnectionStatus.allCases, id: \.self) { status in
                        if connectionStatuses.contains(status) {
                            VStack {
                                HStack {
                                    Text(status.connectionText)
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
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
                                NavigationLink (
                                    destination: {ConnectingView(anchorID1: anchorID1, anchorID2: anchors[idx].id)},
                                    label: {
                                        HStack {
                                            Text("\(anchors[idx].getName())")
                                                .font(.title)
                                                .bold()
                                                .padding(30)
                                                .foregroundColor(status == .connectedDirectly ? AppColor.foreground: AppColor.background)
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 140)
                                    })
                                .background(status == .connectedDirectly ? AppColor.background: AppColor.foreground)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                     .stroke(status == .connectedDirectly ? AppColor.foreground: AppColor.background, lineWidth: 5)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
            }
            Spacer()
        }
        .background(AppColor.background)
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
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
            print(connectionStatuses)
        }
        
    }
}


//struct sortByConnectionStatus: View {
//
//    var body: some View {
//        ForEach(0..<ConnectionStatus.self, id: \.self) { status in
//            Text(status.connectionText)
//        }
//        ForEach(0..<anchors.count, id: \.self) { idx in
//            if anchors[idx].id != anchorID1 {
//                NavigationLink (
//                    destination: {ConnectingView(anchorID1: anchorID1, anchorID2: anchors[idx].id)},
//                    label: {
//                        VStack {
//                            HStack {
//                                Text("\(anchors[idx].getName())")
//                                    .font(.title)
//                                    .bold()
//                                    .padding(.top, 30)
//                                    .padding(.horizontal, 30)
//                                    .foregroundColor(AppColor.background)
//                                    .multilineTextAlignment(.leading)
//                                Spacer()
//                            }
//                            HStack {
//                                Text(connectionStatuses[idx].connectionText)
//                                    .font(.title2)
//                                    .padding(.bottom, 30)
//                                    .padding(.horizontal, 30)
//                                    .foregroundColor(AppColor.background)
//                                    .multilineTextAlignment(.leading)
//                                Spacer()
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                        .frame(minHeight: 140)
//                    })
//                .background(connectionStatuses[idx].connectionColor)
//                .cornerRadius(20)
//                .padding(.horizontal)
//            }
//        }
//    }
//}
