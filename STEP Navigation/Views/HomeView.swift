//
//  HomeView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/7/23.
//

import SwiftUI
import AuthenticationServices
import CoreLocation

struct HomeView: View {
    @ObservedObject var authHandler = AuthHandler.shared
    @ObservedObject var positionModel = PositioningModel.shared
    let minimumGeoLocationAccuracy: GeoLocationAccuracy = .coarse
    
    var body: some View {
        if authHandler.currentUID == nil {
            SignInWithApple()
                .frame(width: 280, height: 60)
                .onTapGesture(perform: authHandler.startSignInWithAppleFlow) //TODO: make sure this works properly with screen readers
        } else {
            NavigationStack {
                ScreenBackground {
                    VStack {
                        ScreenHeader(title: "Clew Maps 2", subtitle: "Precise Short Distance Navigation for the Blind and Visually Impaired", backButtonHidden: true)
                        
                        ScrollView {
                            if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                                if positionModel.currentLatLon == nil {
                                    LoadingPopup(text: "Finding Destinations Near You")
                                } else {
                                    VStack {
                                        LargeNavigationLink(destination: DestinationTypesView(), label: "Navigate", alignment: .center)
                                            .padding(.vertical, 12)
                                        LargeNavigationLink(destination: ManageAnchorsListView(), label: "Manage", alignment: .center)
                                            .padding(.vertical, 12)
                                    }
                                    .padding(.top, 6)
                                }
                            } else {
                                LoadingPopup(text: "Trying to Geo Localize")
                            }
                        }
                        Spacer()
                        SmallNavigationLink(destination: SettingsView(), label: "Settings")
                    }
                    .onAppear() {
                        positionModel.startCoarsePositioning()
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                        AppDelegate.orientationLock = .portrait
                    }
                }
            }
        }
    }
}


