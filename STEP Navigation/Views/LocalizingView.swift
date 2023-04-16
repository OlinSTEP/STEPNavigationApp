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
    var minimumGeoLocationAccuracy: GeoLocationAccuracy {
        return anchorType == .indoorDestination ? .low : .high
    }
    
    var body: some View {
        ZStack {
            ARViewContainer()
            if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                if let currentLatLon = positionModel.currentLatLon {
                    NavigationLink(destination: LocalAnchorListView(anchorType: anchorType, location: currentLatLon), label: {
                        Text("My nearby locations")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: 300)
                            .foregroundColor(AppColor.black)
                    })
                    .padding(.bottom, 20)
                    .tint(AppColor.accent)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                } else {
                    Text("Inconsistent State.  Contact your developer")
                }
            } else  {
                switch positionModel.geoLocalizationAccuracy {
                case .none:
                    Text("No Location")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                case .low:
                    Text("Low accuracy")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    
                case .medium:
                    Text("Medium accuracy")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                case .high:
                    Text("High accuracy")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct LocalizingView_Previews: PreviewProvider {
    static var previews: some View {
        LocalizingView(anchorType: .externalDoor)
    }
}
