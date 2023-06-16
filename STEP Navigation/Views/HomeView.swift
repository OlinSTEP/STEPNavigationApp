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
    
    @AccessibilityFocusState var focusOnPopup
    
    var body: some View {
        if authHandler.currentUID == nil {
            SignInWithApple()
                .frame(width: 280, height: 60)
                .onTapGesture(perform: authHandler.startSignInWithAppleFlow)
        } else {
            NavigationStack {
                ScreenTitleComponent(titleText: "Clew Maps 2", subtitleText: "Precise Short Distance Navigation for the Blind and Visually Impaired")
                    .navigationBarBackButtonHidden()
                    .padding(.top, 60)
                    .background(AppColor.accent)
                
                VStack {
                    if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                        if positionModel.currentLatLon == nil {
                            GPSLocalizationPopup()
                        } else {
                            VStack(spacing: 20) {
                                LargeButtonComponent_NavigationLink(destination: {
                                    DestinationTypesView()
                                }, label: "Navigate")
                                LargeButtonComponent_NavigationLink(destination: {
                                    RadarMapView()
                                }, label: "Explore")
                                LargeButtonComponent_NavigationLink(destination: {
                                    ManageAnchorsListView()
                                }, label: "Manage")
                                Spacer()
                                SmallButtonComponent_NavigationLink(destination: {
                                    SettingsView()
                                }, label: "Settings")
                            }
                            .padding(.top, 20)
                        }
                    }
                }
                .onAppear() {
                    positionModel.startCoarsePositioning()
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation") // Forcing the rotation back to portrait
                    AppDelegate.orientationLock = .portrait // And making sure it stays that way
                }
                Spacer()
            }
            .accentColor(AppColor.light)
        }
    }
}
