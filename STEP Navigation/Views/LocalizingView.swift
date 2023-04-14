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
    let anchorType: AnchorType
    
    @State var highAccuracy = false
        
    var body: some View {
        ZStack {
            ARViewContainer()
            if positionModel.geoLocalizationAccuracy == .high {
                if let currentLatLon = positionModel.currentLatLon {
                    VStack {
                        HStack {
                            Text("Successfully Localized")
                                .foregroundColor(AppColor.white)
                                .bold()
                                .font(.title)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        }
                        .padding(.vertical)
                        
                        NavigationLink(destination: LocalAnchorListView(anchorType: anchorType, location: currentLatLon)) {
                            Text("Go to nearby locations")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: 300)
                                .foregroundColor(AppColor.black)
                        }
                        .padding(.bottom, 20)
                        .tint(AppColor.accent)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColor.black)
                    
                } else {
                    Text("Inconsistent State.  Contact your developer")
                }
                    
            } else {
                VStack {
                    HStack {
                        Text("Localizing...")
                            .foregroundColor(AppColor.white)
                            .bold()
                            .font(.title2)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
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
    }
}

struct LocalizingView_Previews: PreviewProvider {
    static var previews: some View {
        LocalizingView(anchorType: .externalDoor)
    }
}
