//
//  AnchorDetailView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView<Destination: View>: View {
    @State var startAnchorDetails: LocationDataModel?
    @State var destinationAnchorDetails: LocationDataModel
    let buttonLabel: String
    let buttonDestination: Destination
    
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Anchor Details")
                FromToAnchorDetails(startAnchorDetails: $startAnchorDetails, destinationAnchorDetails: $destinationAnchorDetails)
                Spacer()
                VStack(spacing: 28) {
                    //Attempt to implement Switch Anchors Button; commented out because of unresolved bugs; will continue working on implementation
//                    SmallButton(action: {
//                        if startAnchorDetails != nil {
//                            self.startAnchorDetails! = self.destinationAnchorDetails
//                            self.destinationAnchorDetails = self.startAnchorDetails!
//                        }
//                    }, label: "Switch Anchors", invert: true)
                    SmallNavigationLink(destination: buttonDestination, label: buttonLabel)
                }
            }
        }
    }
}
