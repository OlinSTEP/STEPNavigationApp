//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI

struct AnchorTypeListView: View {
    @StateObject private var anchorData = AnchorData()
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = UIColor(AppColor.accent)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Anchor Groups")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 20)
//                HStack {
//                    Text("Subtitle")
//                        .font(.title)
//                        .padding(.horizontal)
//                    Spacer()
//                }
                .padding(.bottom, 20)
            }
            .background(AppColor.accent)
            
            ScrollView {
                VStack {
                    ForEach(AnchorDetails.AnchorType.allCases, id: \.self) {
                        anchorType in
                        NavigationLink (
                            destination: LocalAnchorListView(anchorType: anchorType)
                                .environmentObject(anchorData),
                            label: {
                                Text(anchorType.rawValue)
                                    .font(.largeTitle)
                                    .bold()
                                    .padding(30)
//                                    .multilineTextAlignment(.leading)
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
            .navigationBarItems(
                trailing:
                    Button(action: {
                        print("pressed settings")
                    }) {
                        Image(systemName: "gearshape.fill")
                            .scaleEffect(1.5)
                            .foregroundColor(AppColor.black)
                    }
            )
        }
        .accentColor(AppColor.black)
    }
}

struct AnchorTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorTypeListView()
    }
}
