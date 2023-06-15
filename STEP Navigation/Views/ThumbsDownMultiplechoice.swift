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
    @State private var navigationButtonColor: Color = Color.red
    @State private var routeRecordingButtonColor: Color = Color.red
    @State private var locationAnchorButtonColor: Color = Color.red
    @State private var otherButtonColor: Color = Color.red

    var body: some View {
        VStack {
            Text("What was the problem?")
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.top)

            Button(action: {
                print("Navigation Problem")
                self.navigationButtonColor = Color.yellow
            }) {
                Text("Navigation")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(navigationButtonColor)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Route Recording")
                self.routeRecordingButtonColor = Color.yellow
            }) {
                Text("Route Recording")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(routeRecordingButtonColor)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Location Anchor Problem")
                self.locationAnchorButtonColor = Color.yellow
            }) {
                Text("Inaccurate Location Anchor")
                    .font(.body)
                    .padding(5)
                    .foregroundColor(.white)
                    .background(locationAnchorButtonColor)
                    .cornerRadius(10)
            }

            Button(action: {
                print("Others")
                self.otherButtonColor = Color.yellow
            }) {
                VStack{
                    Text("Others")
                        .font(.body)
                        .padding(5)
                        .foregroundColor(.white)
                        .background(otherButtonColor)
                        .cornerRadius(10)

                    TextField("Problem Description", text: $response)
                }
            }
        }
        ; SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Done")
    }
}


