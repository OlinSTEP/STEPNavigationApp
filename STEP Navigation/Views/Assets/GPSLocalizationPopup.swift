//
//  GPSLocalizationView.swift
//  STEP Navigation
//
//  Created by Evelyn on 4/24/23.
//

import SwiftUI
import AuthenticationServices

struct GPSLocalizationPopup: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(AppColor.light)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
        VStack {
            HStack {
                Text("Finding Destinations Near You")
                    .foregroundColor(AppColor.dark)
                    .bold()
                    .font(.title)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .padding(.horizontal)
            
            ZStack {
                Circle()
                    .stroke(AppColor.dark, lineWidth: 5)
                    .frame(width: 100, height: 100)
                    .opacity(0.25)
                Circle()
                    .trim(from: 0.25, to: 1)
                    .stroke(AppColor.dark, style: StrokeStyle(lineWidth: 5, lineCap: .round))
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
        }
    }
