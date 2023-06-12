//
//  ThumbsDownMultiplechoice.swift
//  STEP Navigation
//
//  Created by Muya Guoji on 6/12/23.
//

import SwiftUI
import CoreLocation

struct MultipleChoice: View {
    @State private var response = ""

    var body: some View {
        VStack {
            Text("What was the problem?")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.top)

            Button(action: {
                print("Navigation Problem")
            }) {
                Text("Navigation")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Route Recording")
            }) {
                Text("Route Recording")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Location Anchor")
            }) {
                Text("Inaccurate Location Anchor")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Others")
            }) {VStack{
                Text("Others")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(10)
                
                TextField("Problem Description", text: $response)
            }}
        }
        ; SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Done")
        }
    }

