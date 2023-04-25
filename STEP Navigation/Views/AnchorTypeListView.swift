//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI
import CoreLocation

struct AnchorTypeListView: View {    
    @ObservedObject var database = FirebaseManager.shared
    @ObservedObject var positionModel = PositioningModel.shared
    
    @State private var nearbyDistance: Double = 100
    @State var showPopup = false
    
    var body: some View {
        // Navigation Stack determines the Navigation Bar
        NavigationStack {
            VStack {
                // Sets the title text
                HStack {
                    Text("Destinations")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 0.5)
                
                HStack {
                    Text("Within \(nearbyDistance, specifier: "%.0f") meters")
                        .font(.title)
                        .padding(.leading)
                    if showPopup == false {
                        Image(systemName: "chevron.down")
                    } else {
                        Image(systemName: "chevron.up")
                    }
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
            
            
            // The scroll view contains the main body of text
            ScrollView {
                VStack {
                    
                    let anchorTypes = DataModelManager.shared.getAnchorTypes()
                    // Creates a navigation button for each anchor type
                    ForEach(Array(anchorTypes).sorted(by: {$0.rawValue < $1.rawValue})) {
                        anchorType in
                        NavigationLink (
                            destination: LocalizingView(anchorType: anchorType),
                            label: {
                                Text(anchorType.rawValue)
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(30)
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

//struct AnchorTypeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnchorTypeListView()
//    }
//}
