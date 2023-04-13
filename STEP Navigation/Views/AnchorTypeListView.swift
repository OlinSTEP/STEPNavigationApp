//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI

struct AnchorTypeListView: View {
//    @StateObject private var anchorData = AnchorData()
    
    // Sets the appearance of the Navigation Bar using UIKit
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor(AppColor.accent)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        // Navigation Stack determines the Navigation Bar
        NavigationStack {
            VStack {
                // Sets the title text
                HStack {
                    Text("Anchor Groups")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.vertical, 20)
            }
            .background(AppColor.accent)
            // Sets the settings button
            .navigationBarItems(
                trailing:
                    Button(action: {
                        print("pressed settings")
                        // replace with a Navigation Link that goes to settings
                    }) {
                        Image(systemName: "gearshape.fill")
                            .scaleEffect(1.5)
                            .foregroundColor(AppColor.black)
                    }
            )
            
            // The scroll view contains the main body of text
            ScrollView {
                VStack {
                    
                    let anchorTypes = DataModelManager.shared.getAnchorTypes()
                    // Creates a navigation button for each anchor type
                    ForEach(Array(anchorTypes).sorted(by: {$0.rawValue < $1.rawValue})) {
                        anchorType in
                        NavigationLink (
//                            destination: LocalizingView(),
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
                        .background(AppColor.grey)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
        .accentColor(AppColor.black)
    }
}

struct AnchorTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorTypeListView()
    }
}
