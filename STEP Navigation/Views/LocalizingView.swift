//
//  LocalizingView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import AVFoundation
import CoreLocation

struct LocalizingView: View {
    @ObservedObject var positionModel = PositioningModel.shared
    @State var highAccuracy = false

    let anchorType: AnchorType
    var minimumGeoLocationAccuracy: GeoLocationAccuracy {
        return .coarse
    }
    
    var body: some View {
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
                        
//                        NavigationLink(destination: LocalAnchorListView(anchorType: anchorType, location: currentLatLon)) {
//                            Text("Go to nearby locations")
//                                .font(.title2)
//                                .bold()
//                                .frame(maxWidth: 300)
//                                .foregroundColor(AppColor.black)
//                        }
//                        .padding(.bottom, 50)
//                        .tint(AppColor.accent)
//                        .buttonStyle(.borderedProminent)
//                        .buttonBorderShape(.capsule)
//                        .controlSize(.large)
                    }
                } else {
                    Text("Inconsistent State.  Contact your developer")
                }
            } else  {
                VStack {
                    HStack {
                        Text("Localizing")
                            .foregroundColor(AppColor.white)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        Spacer()
                    }
                    HStack {
                        switch positionModel.geoLocalizationAccuracy {
                        case .none:
                            Text("Current Accuracy: None (No Location)")
                                .foregroundColor(AppColor.white)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        case .coarse:
                            Text("Current Accuracy: Coarse (GPS Only)")
                                .foregroundColor(AppColor.white)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        case .low:
                            Text("Current Accuracy: Low")
                                .foregroundColor(AppColor.white)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)

                        case .medium:
                            Text("Current Accuracy: Medium")
                                .foregroundColor(AppColor.white)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                            
                        case .high:
                            Text("Current Accuracy: High")
                                .foregroundColor(AppColor.white)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        }
                        Spacer()
                    }
                    HStack {
                        Text("Move your phone around with the camera facing out.")
                            .foregroundColor(AppColor.white)
                            .bold()
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
}

struct LocalizingView_Previews: PreviewProvider {
    static var previews: some View {
        LocalizingView(anchorType: .externalDoor)
    }
}
