//
//  AnchorDetailViewDouble.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/1/23.
//

import SwiftUI
import CoreLocation

struct AnchorDetailView2PopUp: View {
    let anchorDetailsStart: LocationDataModel
    let anchorDetailsEnd: LocationDataModel
    
    @Binding var showHelp: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Text("FROM")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.top)
                    Spacer()
                }
                HStack {
                    Text(anchorDetailsStart.getName())
                        .font(.title)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                
                HStack {
                    if let currentLocation = PositioningModel.shared.currentLatLon {
                        let distance = currentLocation.distance(from: anchorDetailsStart.getLocationCoordinate())
                        let formattedDistance = String(format: "%.0f", distance)
                        Text("\(formattedDistance) meters away")
                            .font(.title2)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Location Notes")
                            .font(.title3)
                            .bold()
                            .padding(.bottom, 2)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    HStack {
                        if let notes = anchorDetailsStart.getNotes(), notes != "" {
                            Text("\(notes)")
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        else {
                            Text("No notes available for this location. This is super long text because I am trying to test something. alksjd fsaldkfj asd. sadfkldj sfa sadfl,jasd .dfgajoir t adcglkj reoigahfdkgj sdafgjer e hu9adsgfskj fakgaf it9gtdggf dfgklhaj sdfho agdagkljreag reoiadfjgdgskl lkrdffdas geri jg[dif jgsadkjfsdafjuwer owiadgjs gl.")
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                
                HStack {
                    Text("TO")
                        .font(.title2)
                        .padding(.horizontal)
                        .padding(.top)
                    Spacer()
                }

                HStack {
                    Text(anchorDetailsEnd.getName())
                        .font(.title)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                    
                HStack {
                    if let currentLocation = PositioningModel.shared.currentLatLon {
                        let distance = currentLocation.distance(from: anchorDetailsEnd.getLocationCoordinate())
                        let formattedDistance = String(format: "%.0f", distance)
                        Text("\(formattedDistance) meters away")
                            .font(.title2)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Location Notes")
                            .font(.title3)
                            .bold()
                            .padding(.bottom, 2)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    HStack {
                        if let notes = anchorDetailsEnd.getNotes(), notes != "" {
                            Text("\(notes)")
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        else {
                            Text("No notes available for this location.")
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
            }
            Spacer()
            SmallButtonComponent_Button(label: "Dismiss", popupTrigger: $showHelp)
        }
        .background(AppColor.light)
    }
}

