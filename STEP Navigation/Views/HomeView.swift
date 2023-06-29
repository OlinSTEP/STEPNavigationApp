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
    let minimumGeoLocationAccuracy: GeoLocationAccuracy = .coarse //TODO: investigate: if I set this to anything other than coarse it doesn't work
    
    var body: some View {
        if authHandler.currentUID == nil {
            SignInWithApple()
                .frame(width: 280, height: 60)
                .onTapGesture(perform: authHandler.startSignInWithAppleFlow) //TODO: make sure this works properly with screen readers
        } else {
            NavigationStack {
<<<<<<< HEAD
                VStack {
                ScreenTitleComponent(titleText: "Clew Maps 2", subtitleText: "Precise Short Distance Navigation for the Blind and Visually Impaired")
                    .navigationBarBackButtonHidden()
                    .padding(.top, 60)
                    .background(AppColor.accent)
                
                    ScrollView {
                        if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                            if positionModel.currentLatLon == nil {
                                GPSLocalizationPopup()
                            } else {
                                VStack(spacing: 20) {
                                    LargeButtonComponent_NavigationLink(destination: {
                                        DestinationTypesView()
                                    }, label: "Navigate")
                                    //removed explore feature until it is complete
//                                    LargeButtonComponent_NavigationLink(destination: {
//                                        RadarMapView()
//                                    }, label: "Explore")
                                    LargeButtonComponent_NavigationLink(destination: {
                                        ManageAnchorsListView()
                                    }, label: "Manage")
                                    
                                    Spacer()
                                    
                                    SmallButtonComponent_NavigationLink(destination: {
                                        SettingsView()
                                    }, label: "Settings")
                                    .padding(.bottom, 32)
                                    .padding(.top, 190)
=======
                ScreenBackground {
                    VStack {
                        ScreenHeader(title: "Clew Maps 2", subtitle: "Precise Short Distance Navigation for the Blind and Visually Impaired", backButtonHidden: true)
                        
                        ScrollView {
                            if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                                if positionModel.currentLatLon == nil {
                                    GPSLocalizationPopup()
                                } else {
                                    VStack {
                                        LargeNavigationLink(destination: DestinationTypesView(), label: "Navigate", alignment: .center)
                                            .padding(.vertical, 12)
                                        LargeNavigationLink(destination: ManageAnchorsListView(), label: "Manage", alignment: .center)
                                            .padding(.vertical, 12)
                                    }
                                    .padding(.top, 6)
>>>>>>> frontend-refactor-2-electric-boogaloo
                                }
                            } else {
                                Text("Unable to Geo Localize")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(AppColor.foreground)
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
            .accentColor(AppColor.text_on_accent)
        }
    }
}


