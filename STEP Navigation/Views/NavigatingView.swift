//
//  NavigatingView.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/5/23.
//

import SwiftUI

struct NavigatingView: View {
    let popupEntry: String = "Testing Text"
        
    var body: some View {
        Spacer()
        VStack {
            InformationPopup(popupEntry: popupEntry)
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
}

struct InformationPopup: View {
    let popupEntry: String
    
    var body: some View {
        VStack {
            HStack {
                Text(popupEntry)
                    .foregroundColor(AppColor.white)
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.black)
    }
}

struct NavigatingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigatingView()
    }
}
