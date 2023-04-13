//
//  CapsuleButton.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/8/23.
//

import SwiftUI

struct CapsuleButton: View {
    
    @State var showPopup = false
    
    @State var randomNumber = 1
    
    var body: some View {
        Button(action: {
            randomNumber = Int.random(in: 1...11)
            showPopup = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showPopup = false
            }
        }, label: {
            Text("Secret Tunnel. Secret Tunnel. Through the mountains. Secret, secret, secret, secret, tunnel!")
                .foregroundColor(AppColor.white)
                .frame(maxWidth: .infinity)
                .padding()
        })

        if showPopup {
            Image("Subject\(randomNumber)")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
        }

    }
}
