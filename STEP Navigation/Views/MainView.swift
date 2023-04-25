//
//  MainView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/24/23.
//

import SwiftUI

import SwiftUI

struct MainView: View {
    @ObservedObject var positionModel = PositioningModel.shared
    let minimumGeoLocationAccuracy: GeoLocationAccuracy = .low
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("STEP Navigation")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 70)
                .padding(.bottom, 0.25)
                
                HStack {
                    Text("Precise Short Distance Navigation for the Blind and Visually Impaired")
                        .font(.title2)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .navigationBarBackButtonHidden()
            .background(AppColor.accent)

        ZStack {
            ARViewContainer()

            if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                if let currentLatLon = positionModel.currentLatLon {
                    VStack {
                        Spacer()
                        HStack {
                            Text("Succesfully Localized")
                                .bold()
                                .foregroundColor(AppColor.white)
                                .font(.title2)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColor.black)
    
                        Spacer()
                        
                        NavigationLink(destination: AnchorTypeListView(), label: {
                            Text("Go to nearby locations")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: 300)
                                .foregroundColor(AppColor.black)
                        })
                        .padding(.bottom, 50)
                        .tint(AppColor.accent)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                    }
                } else {
                    Text("Inconsistent State.  Contact your developer")
                }
            } else  {
                VStack {
                    HStack {
                        Text("Finding Anchors Near You")
                            .foregroundColor(AppColor.white)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColor.black)
            }
        }
        .background(AppColor.accent)
    }
    .accentColor(AppColor.black)
    }
}
        
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
