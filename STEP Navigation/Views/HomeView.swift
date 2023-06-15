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
                
                //TODO: add a component here that dispalys "adjusting to portrait mode" or something like that for a few seconds while the phone adjusts, then disappear to display the home view
                ScrollView {
                    if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                        if positionModel.currentLatLon == nil {
                            GPSLocalizationPopup()
                        } else {
                            VStack(spacing: 20) {
                                LargeButtonComponent_NavigationLink(destination: {
                                    DestinationTypesView()
                                }, label: "Navigate a Route")
                                LargeButtonComponent_NavigationLink(destination: {
                                    RadarMapView()
                                }, label: "Explore your Surroundings")
                                LargeButtonComponent_NavigationLink(destination: {
                                    ManageAnchorsListView()
                                }, label: "Manage Anchors")
                                LargeButtonComponent_NavigationLink(destination: {
                                    SettingsView()
                                }, label: "Settings")
                                LargeButtonComponent_NavigationLink(destination: {
                                    AnchorDetailView_ArrivedView(anchorDetails: LocationDataModel(anchorType: .frontdesk, coordinates: CLLocationCoordinate2D(latitude: 42.0, longitude: -71.0), name: "Sample Destination", id: UUID().uuidString)
)
                                }, label: "Skip to Arrived View")
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
            .accentColor(AppColor.dark)
        }
    }
}
