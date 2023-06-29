//
//  ManageAnchorsListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import CoreLocation

struct ManageAnchorsListView: View {
    @ObservedObject var positionModel = PositioningModel.shared
    @ObservedObject var dataModelManager = DataModelManager.shared
    @State var anchors: [LocationDataModel] = []
    @State var lastQueryLocation: CLLocationCoordinate2D?
    
    @State var selectedOrganization = ""
    
    var body: some View {
        ScreenBackground {
            VStack {
                //Custom Header Component for Select Organization Picker integration
                VStack {
                    HStack {
                        Text("Anchors")
                            .font(.largeTitle)
                            .bold()
                            .padding(.horizontal)
                            .foregroundColor(AppColor.text_on_accent)
                        Spacer()
                    }
                    .padding(.bottom, 0.5)
                    HStack {
                        Text("At")
                            .font(.title2)
                            .padding(.leading)
                            .foregroundColor(AppColor.background)
                        OrganizationPicker(selectedOrganization: $selectedOrganization)
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
                .background(AppColor.foreground)
                
                ScrollView {
                    SmallNavigationLink(destination: RecordAnchorView(), label: "Create New Anchor")
                        .padding(.top, 32)
                    
                    VStack(spacing: 32) {
                        ForEach(0..<anchors.count, id: \.self) { idx in
                            if anchors[idx].cloudAnchorMetadata?.organization == selectedOrganization {
                                LargeNavigationLink(destination: AnchorDetailView_Manage(anchorDetails: anchors[idx]), label: "\(anchors[idx].getName())")
                            }
                        }
                    }
                    .padding(.vertical, 32)
                }
            }
            .onReceive(DataModelManager.shared.objectWillChange) {
                anchors = []
                if let latLon = lastQueryLocation {
                    updateNearbyAnchors(latLon: latLon)
                }
            }
            .onReceive(positionModel.$currentLatLon) { latLon in
                guard let latLon = latLon else {
                    return
                }
                guard lastQueryLocation == nil || lastQueryLocation!.distance(from: latLon) > 5.0 else {
                    return
                }
                lastQueryLocation = latLon
                updateNearbyAnchors(latLon: latLon)
            }
        }
    }
    
    private func updateNearbyAnchors(latLon: CLLocationCoordinate2D) {
        anchors = Array(
            DataModelManager.shared.getNearbyIndoorLocations(
                location: latLon,
                maxDistance: CLLocationDistance(Double.infinity),
                withBuffer: 0.0
            )
        )
        .sorted(by: {
            $0.getName() < $1.getName()
        })
    }
}

struct OrganizationPicker: View {
    @ObservedObject var dataModelManager = DataModelManager.shared
    @Binding var selectedOrganization: String
    
    var body: some View {
        Menu {
            Button(action: {
                selectedOrganization = ""
            }) {
                Text("Organization Field Blank - option included for testing purposes")
            }
            
            ForEach(dataModelManager.getAllNearbyOrganizations(), id: \.self) { organization in
                Button(action: {
                    selectedOrganization = organization
                }) {
                    Text(organization)
                }
            }
        } label: {
            HStack {
                Text(selectedOrganization.isEmpty ? "Select Organization" : selectedOrganization)
                    .font(.title2)
                Image(systemName: "chevron.down")
            }
        }
    }
}
