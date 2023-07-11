//
//  AnchorDetailEditView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI

struct TestAnchorLocalizationView: View {
    let anchorDetails: LocationDataModel
    @State var hideBackButton = false
    @State var showInstructions = true
    @State var localized = false
    
    var body: some View {
        ZStack {
            if !showInstructions {
                ARViewContainer()
                if !localized {
                    ARViewTextOverlay(text: "Trying to localize \(anchorDetails.getName()). Scan your phone around to recognize your surroundings.")
                        .onAppear() {
                            PositioningModel.shared.startPositioning()
                            PositioningModel.shared.resolveCloudAnchor(byID: anchorDetails.getCloudAnchorID()!)
                        }
                } else {
                    ARViewTextOverlay(text: "\(anchorDetails.getName()) successfully localized.")
                }
            } else {
                ScreenBackground {
                    VStack {
                        ScreenHeader(title: "Test Anchor Localization", backButtonHidden: hideBackButton)
                        VStack {
                            ScrollView {
                                UnorderedList(listItems:
                                                ["Localizing to an anchor point is required for starting a route.",
                                                 "Make sure you are in the area around \(anchorDetails.getName()).",
                                                 "When you are ready tap \"Find the Anchor\" to try to localize.",
                                                 "When localizing, make sure to sweep your phone around so it can match your current environment to the anchor."]
                                )
                            }
                            SmallButton(action: {
                                showInstructions = false
                            }, label: "Find the Anchor")
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }
            }
        }
        .onDisappear() {
            PositioningModel.shared.stopPositioning()
        }.padding(.bottom, 48)
            .background(AppColor.foreground)
            .edgesIgnoringSafeArea([.bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onReceive(PositioningModel.shared.$resolvedCloudAnchors) { newValue in
            if newValue.contains(anchorDetails.getCloudAnchorID()!) {
                localized = true
            }
        }
    }
}
