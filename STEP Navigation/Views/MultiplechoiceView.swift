//
//  ThumbsDownMultiplechoice.swift
//  STEP Navigation
//
//  Created by Muya Guoji on 6/12/23.
//


// MultipleChoice after thumbs down
//struct MultipleChoice: View {
//    @EnvironmentObject var feedback: Feedback
//
//    var body: some View {
//        VStack {
//            Text("What was the problem?")
//                .font(.title)
//                .multilineTextAlignment(.center)
//                .padding(.top)
//
//            Button(action: {
//                print("Navigation Problem")
//                feedback.isNavigationSelected.toggle()
//            }) {
//                Text("Navigation")
//                    .font(.body)
//                    .padding(5)
//                    .foregroundColor(.white)
//                    .background(feedback.isNavigationSelected ? Color.yellow : Color.red)
//                    .cornerRadius(10)
//            }
//
//            Button(action: {
//                print("Route Recording")
//                feedback.isRouteRecordingSelected.toggle()
//            }) {
//                Text("Route Recording")
//                    .font(.body)
//                    .padding(5)
//                    .foregroundColor(.white)
//                    .background(feedback.isRouteRecordingSelected ? Color.yellow : Color.red)
//                    .cornerRadius(10)
//            }
//
//            Button(action: {
//                print("Location Anchor Problem")
//                feedback.isLocationAnchorSelected.toggle()
//            }) {
//                Text("Inaccurate Location Anchor")
//                    .font(.body)
//                    .padding(5)
//                    .foregroundColor(.white)
//                    .background(feedback.isLocationAnchorSelected ? Color.yellow : Color.red)
//                    .cornerRadius(10)
//            }
//
//            Button(action: {
//                print("Others")
//                feedback.isOtherSelected.toggle()
//            }) {
//                VStack{
//                    Text("Others")
//                        .font(.body)
//                        .padding(5)
//                        .foregroundColor(.white)
//                    .background(feedback.isOtherSelected ? Color.yellow : Color.red)
//                    .cornerRadius(10)
//
//                    TextField("Problem Description", text: $feedback.response)
//                }
//            }
//        }
//        ; SmallButtonComponent_NavigationLink(destination: { HomeView() }, label: "Done")
//    }
//}
