//
//  MainView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/24/23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var database = FirebaseManager.shared
    @ObservedObject var positionModel = PositioningModel.shared
    let minimumGeoLocationAccuracy: GeoLocationAccuracy = .coarse
    
    @State private var isAnimating = false
    
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
            ZStack {
                ARViewContainer()
                Rectangle()
                    .fill(AppColor.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if positionModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: minimumGeoLocationAccuracy) {
                if let currentLatLon = positionModel.currentLatLon {
                    VStack {
                        VStack {
                            HStack {
                                Text("Multiple Destinations Found")
                                    .bold()
                                    .foregroundColor(AppColor.black)
                                    .font(.title)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .padding(.horizontal)
                            
                            VStack {
                                NavigationLink(destination: AnchorTypeListView(), label: {
                                    Text("Next")
                                        .font(.title2)
                                        .bold()
                                        .frame(maxWidth: 300)
                                        .foregroundColor(AppColor.black)
                                })
                                //                            .padding(.bottom, 50)
                                .tint(AppColor.accent)
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                                .controlSize(.large)
                            }
                            .frame(height: 100)
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                        Spacer()
                    }
                    
                } else {
                    Text("Inconsistent State.  Contact your developer")
                }
            } else  {
                VStack {
                    VStack {
                        HStack {
                            Text("Finding Destinations Near You")
                                .foregroundColor(AppColor.black)
                                .bold()
                                .font(.title)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .padding(.horizontal)
                                                
                        ZStack {
                            Circle()
                                .stroke(AppColor.black, lineWidth: 5)
                                .frame(width: 100, height: 100)
                                .opacity(0.25)
                            Circle()
                                .trim(from: 0.25, to: 1)
                                .stroke(AppColor.black, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .frame(width: 100, height: 100)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .onAppear {
                                    withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                                        self.isAnimating = true
                                    }
                                }

                        }
                        .frame(height: 100)
                        .padding()
                        .drawingGroup()
                        
                        Spacer()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .background(AppColor.accent)
        .onAppear() {
            positionModel.startCoarsePositioning()
        }
    }
    .accentColor(AppColor.black)
    }
}
        
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
