//
//  AnchorTypeListView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/7/23.
//

import SwiftUI

struct AnchorTypeListView: View {
    @StateObject private var anchorData = AnchorData()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AnchorDetails.AnchorType.allCases, id: \.self) {
                    anchorType in
                    NavigationLink (
                        destination: LocalAnchorListView(anchorType: anchorType)
                            .environmentObject(anchorData),
                        label: {
                            Text(anchorType.rawValue)
                                .font(.title)
                        })
                }
            }
            .navigationTitle("Anchor Groups")
            .toolbar (content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        print("Pressed home")
                    }, label: {
                        Image(systemName: "house")
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Pressed settings")
                    }, label: {
                        Image(systemName: "gear")
                    })
                }
            })
        }
    }
}

struct AnchorTypeListView_Previews: PreviewProvider {
    static var previews: some View {
        AnchorTypeListView()
    }
}
