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
        ZStack {
            VStack {
                if let currentLocation = PositioningModel.shared.currentLatLon {
                    let distance = currentLocation.distance(from: anchorDetails.getLocationCoordinate())
                    let formattedDistance = String(format: "%.0f", distance)
                    AnchorDetailsComponent(title: anchorDetails.getName(), distanceAway: formattedDistance)
                        .padding(.top)
                }
                Spacer()
                VStack(spacing: 15) {
                    SmallButtonComponent_NavigationLink(destination: {
                        AnchorDetailEditView(anchorID: anchorDetails.id, buttonLabel: "Save") {
                            HomeView()
                        }
                    }, label: "Edit")
                    SmallButtonComponent_NavigationLink(destination: {
                        ConnectingView()
                    }, label: "Connect")
                    
                    
                    //                Button("Delete") {
                    //                    FirebaseManager.shared.deleteCloudAnchor(id: anchorID)
                    //                    MainUIStateContainer.shared.currentScreen = .createAnchor
                    //                }
                    SmallButtonComponent_Button(label: "Delete", action: {                 showingConfirmation = true
                    }, labelColor: AppColor.dark, backgroundColor: AppColor.lightred)
                    
                }
            }
            
            if showingConfirmation {
                ConfirmationPopup(showingConfirmation: $showingConfirmation, titleText: "Are you sure you want to delete this anchor?", subtitleText: "This action cannot be undone.", confirmButtonLabel: "Delete", confirmButtonDestination: { HomeView() }, simultaneousAction: {                FirebaseManager.shared.deleteCloudAnchor(id: anchorDetails.id)
                })
                .accessibilityFocused($focusOnPopup)
                .accessibilityAddTraits(.isModal)
            }
        }
    }
}
