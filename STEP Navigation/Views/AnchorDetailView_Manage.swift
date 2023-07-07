//
//  AnchorDetailView_MultipleButtons.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView_Manage: View {
    let anchorDetails: LocationDataModel
    @State var showingConfirmation = false
    @AccessibilityFocusState var focusOnPopup
    
    var body: some View {
        ScreenBackground {
            ZStack {
                VStack {
                    ScreenHeader(title: "Manage Anchor")
                    if let currentLocation = PositioningModel.shared.currentLatLon {
                        let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                        AnchorDetailsText(title: anchorDetails.getName(), distanceAway: distance)
                            .padding(.top)
                    }
                    Spacer()
                    VStack(spacing: 18) {
                        SmallNavigationLink(destination: AnchorDetailEditView(anchorDetails: anchorDetails, buttonLabel: "Save", buttonDestination: {
                            HomeView()
                        }), label: "Edit")
                        SmallNavigationLink(destination: SelectConnectingAnchorsView(anchorID1: anchorDetails.id), label: "Connect")
                        SmallButton(action: {
                            showingConfirmation = true
                            focusOnPopup = true
                        }, label: "Delete", invert: true)
                    }
                }
                
                if showingConfirmation {
                    ConfirmationPopup(showingConfirmation: $showingConfirmation, titleText: "Are you sure you want to delete this anchor?", subtitleText: "This action cannot be undone.", confirmButtonLabel: "Delete", confirmButtonDestination: HomeView()) {
                        FirebaseManager.shared.deleteCloudAnchor(id: anchorDetails.id)
                    }
                    .accessibilityFocused($focusOnPopup)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            CustomBackButton(destination: ManageAnchorsListView())
        }
    }
}
