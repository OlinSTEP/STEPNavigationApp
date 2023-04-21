//
//  AnchorListView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI
import CoreLocation

struct LocalAnchorListView: View {
    let anchorType: AnchorType
    let location: CLLocationCoordinate2D
    
    private let listBackgroundColor = AppColor.grey
    private let listTextColor = AppColor.black
    
    @State private var nearbyDistance: Double = 50
    @State var showPopup = false
    
    var body: some View {
        let anchors = DataModelManager.shared.getNearbyLocations(for: anchorType, location: location, maxDistance: CLLocationDistance(nearbyDistance))

        VStack {
            HStack {
                Text("\(anchorType.rawValue) Anchors")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 20)
            
            HStack {
                Text("Within \(nearbyDistance, specifier: "%.0f") meters")
                    .font(.title)
                    .padding(.leading)
                if showPopup == false {
                    Image(systemName: "chevron.down")
                } else {
                    Image(systemName: "chevron.up")
                }
                // want to make the chevron bigger/easier to see/etc - not sure how thought??
                Spacer()
            }
            .padding(.bottom, 20)
            .onTapGesture {
                showPopup.toggle()
            }
            
            if showPopup == true {
                HStack {
                    Text("0")
                    Slider(value: $nearbyDistance, in: 0...200, step: 10)
                    Text("200")
                }
                .frame(width: 300)
                .padding(.bottom, 20)
            }
        }
        .background(AppColor.accent)
//        .navigationBarItems(
//            trailing:
//                Button(action: {
//                    print("pressed settings")
//                }) {
//                    Image(systemName: "gearshape.fill")
//                        .scaleEffect(1.5)
//                        .foregroundColor(AppColor.black)
//                }
//        )
        
        if anchors.isEmpty {
            VStack {
                Spacer()
                Text("Nothing nearby. Try widening your search radius.")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
        } else {

            ScrollView {
                VStack {
                    ForEach(anchors, id: \.self) {
                        anchor in
                        NavigationLink (
                            destination: AnchorDetailView(anchorDetails: anchor),
                            label: {
                                HStack {
                                    Text(anchor.getName())
                                        .font(.title)
                                        .bold()
                                        .padding(30)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 140)
                                .foregroundColor(AppColor.black)
                            })
                        .background(AppColor.accent)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
    }
    
    
    
}

struct AnchorListView_Previews: PreviewProvider {
    static var previews: some View {
        LocalAnchorListView(anchorType: .busStop, location: CLLocationCoordinate2D(latitude: 42, longitude: -71))
    }
}
