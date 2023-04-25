//
//  MainView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/24/23.
//

import SwiftUI

import SwiftUI

struct MainView: View {
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
            
            VStack {
                NavigationLink (
                    destination: AnchorTypeListView(),
                    label: {
                        Text("Indoor Anchors")
                            .font(.largeTitle)
                            .bold()
                            .padding(30)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            .foregroundColor(AppColor.black)
                    })
                .background(AppColor.accent)
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                NavigationLink (
                    destination: AnchorTypeListView(),
                    label: {
                        Text("Outdoor Anchors")
                            .font(.largeTitle)
                            .bold()
                            .padding(30)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            .foregroundColor(AppColor.black)
                    })
                .background(AppColor.accent)
                .cornerRadius(20)
                .padding(.horizontal)
            }
            .padding(.vertical, 20)
        }
        .accentColor(AppColor.black)
    }
}
        
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
