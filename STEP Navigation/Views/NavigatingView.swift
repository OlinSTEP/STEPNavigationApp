//
//  NavigatingView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct NavigatingView: View {
    let anchorDetails: LocationDataModel
    var body: some View {
        ZStack {
            ARViewContainer()
            VStack {
                Spacer()
                VStack {
                    InformationPopup(popupEntry: "7", popupType: .arrived, units: .none)
                    Spacer()
                    HStack {
                        Image(systemName: "pause.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 140)
                    .background(AppColor.black)
                }
                .padding(.vertical, 100)
            }
        }.onAppear() {
            // plan path
            PathPlanner.shared.navigate(to: anchorDetails)
        }
    }
}

struct InformationPopup: View {
    let popupEntry: String
    let popupType: PopupType
    let units: Units

    var body: some View {
        VStack {
//            HStack {
//                Text("\(popupType.rawValue)")
//                    .foregroundColor(AppColor.white)
//                    .bold()
//                    .font(.title2)
//                    .multilineTextAlignment(.leading)
//                Spacer()
//            }
            
            switch popupType {
            case .userNote:
                HStack {
                    Text("User Note")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                HStack {
                    Text(popupEntry)
                        .foregroundColor(AppColor.white)
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
            case .distanceAway:
                HStack {
                    Text("\(popupEntry) \(units.rawValue) away")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
            case .arrived:
                HStack {
                    Text("Arrived. You should be within one cane's length of your destination.")
                        .foregroundColor(AppColor.white)
                        .bold()
                        .font(.title2)
                        .multilineTextAlignment(.leading)
                }
                
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.black)
    }
    
    enum PopupType: CaseIterable {
        case userNote
        case distanceAway
        case arrived
    }
    
    enum Units: String, CaseIterable {
        case meters = "meters"
        case feet = "feet"
        case none = ""
    }
}

struct NavigatingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigatingView(anchorDetails: LocationDataModel(anchorType: .busStop, coordinates: CLLocationCoordinate2D(latitude: 37, longitude: -71), name: "Bus Stop 1"))
    }
}
