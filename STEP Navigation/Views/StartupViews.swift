//
//  StartupViews.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/23/23.
//

import SwiftUI

struct StartupPage0: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Clew Maps 2")
                Text("Designed by a research group at Olin College of Engineering")
                Spacer()
                SmallButtonComponent_NavigationLink(destination: {
                    StartupPage1()
                }, label: "Get Started")
                .padding(.bottom, 40)
            }
        }
    }
}

struct StartupPage1:  View {
    @State var showFullTerms: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ScreenTitleComponent(titleText: "Welcome to Clew Maps 2", subtitleText: "Precise short distance navigation for the blind and visually impaired")
                    .padding(.top, 60)
                    .background(AppColor.accent)

                ZStack {
                    VStack {
                        Text("Please accept the Terms and Conditions before you get going")
                            .font(.title)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Before getting started please note the following:")
                                .padding(.horizontal)
                            Spacer()
                        }
                        Text("This is not a cane replacement. Please use your own judgment while traveling. Please be aware of your surroundings while using the app. It is your responsibility to maintain your personal safety at all times while using Clew.")
                            .padding(.horizontal)
                        
                        
                        
                        Button {
                            showFullTerms = true
                        } label: {
                            Text("View Full Terms and Conditions")
                        }
                        
                        Spacer()
                        SmallButtonComponent_NavigationLink(destination: {
                            StartupPage2()
                        }, label: "Accept")

                    }
                    if showFullTerms == true {
                        VStack {
                            Text("Privacy")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            Text("Clew will log the 3D path that your phone traveled when using the app. We use this 3D path information to understand the app's shortcomings and to improve its accuracy. We do not tie this 3D path information to the location where the path was traveled (e.g., it is not linked to GPS position). We will not share these data logs with any third party; however, we may make aggregate analysis of this data public (e.g., in an academic paper). Any changes to this privacy policy will be detailed in the app store release notes of future versions of Clew.")
                                .padding(.horizontal)
                            
                            
                            Text("Contact")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            Text("Want to get involved with Clew? Tell us about your experience by sending the Clew Maps 2 team an email at example@example.com.")
                                .padding(.horizontal)
                            
                            Spacer()
                            SmallButtonComponent_NavigationLink(destination: {
                                StartupPage2()
                            }, label: "Accept")
                        }
                        .accessibilityAddTraits(.isModal)
                        .background(AppColor.background)
                    }
                }
                }
            }
        }
    }




struct StartupPage2:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Get to your destination by creating routes nonvisually")
            Text("Clew Maps 2 is designed to help blind and visually impaired users navigate short indoor distances. Pinpoint your exact location using visual anchors and follow the precise guidance to within a cane's length of your destination.")
            Spacer()
            
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage3()
            }, label: "Launch Tutorial")
            SmallButtonComponent_NavigationLink(destination: {
                HomeView()
            }, label: "Skip Tutorial")
            }
        .navigationBarBackButtonHidden()
        }
    }

struct StartupPage3:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Using Clew")
            Text("Clew helps  you find your way indoors by recording your route when you go from point A to point B. By recording your route Clew helps you get back to where you started.")
                .padding()
            Text("Clew is best used indoors. The app does not rely on GPS this means  that Clew is limited outdoors and over long distances!")
                .padding()
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage4()
            }, label: "Next")
            .padding()
            }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit")
                        .foregroundColor(AppColor.background)
                        .bold()
                }
            }
        }
        }
    }

struct StartupPage4:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Holding Your Phone")
            Text("Clew uses your phone's camera and inertial sensors to track your position as you move around while navigating a route.")
                .padding()
            Text(" For the app to function properly. Make sure to hold your phone vertically, with the back camera facing forward at chest level.")
                .padding()
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage5()
            }, label: "Next")
            .padding()
            }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit")
                        .foregroundColor(AppColor.background)
                        .bold()
                }
            }
        }
        }
    }

struct StartupPage5:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Following a Route")
            Text("Clew will make sounds, vibrate, and give you audio cues to help you follow a route.")
                .padding()
            Text("These sounds and cues will tell you if you're going the right way, if you've slightly gone off track, or if you're completely off the route. They are there to guide you and make sure you stay on the right path.")
                .padding()
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage6()
            }, label: "Next")
            .padding()
            }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit")
                        .foregroundColor(AppColor.background)
                        .bold()
                }
            }
        }
        }
    }

struct StartupPage6:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Getting Back on Track")
            Text("You will hear a different sound when you're not following the right path. This can also happen if your phone is not pointed in the direction of the path. If you realize you're off track, you should stop and turn around until you hear ticking sounds, which means you're facing the right direction.")
                .padding()
            Text("Press the 'Get Directions' button to receive audio directions on how to get back on the route.")
                .padding()
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage7()
            }, label: "Next")
            .padding()
            }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit")
                        .foregroundColor(AppColor.background)
                        .bold()
                }
            }
        }
        }
    }

struct StartupPage7:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Let's Practice!")
            Text("In this first exercise, you'll practice a simple route to get used to Clew's sounds and feedback. The route will guide you to take a few steps forward and then let you know when it ends. Pay attention to the sounds and directions from Clew.")
                .padding()
            Button("PRACTICE NOW") {
                print("Button tapped!")
            }
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage8()
            }, label: "Next")
            .padding()
            }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit")
                        .foregroundColor(AppColor.background)
                        .bold()
                }
            }
        }
        }
    }

struct StartupPage8:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Anchors")
            Text("Setting anchor points is a crucial skill for saving routes or pausing navigation. It helps Clew remember where you are and which way you're facing in the route's surroundings. Anchor points are like markers that make sure you stay on the right path when you want to follow a saved route later on. They play a vital role in making Clew navigate accurately.")
                .padding()
             
            Text("Anchor points are created at the beginning and at the end of a route. We recommend setting the anchor point at a location that is easy to remember and find at a later time. A good anchor point could be set at a wall, a doorframe, or a piece of furniture like a table.")
                .padding()
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                HomeView()
            }, label: "Finish Tutorial")
            .padding()
            }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit")
                        .foregroundColor(AppColor.background)
                        .bold()
                }
            }
        }
        }
    }

struct StartupPage_Preferences: View {
    var body: some View {
        VStack {
//            ScreenTitleComponent(titleText: "Your Preference Options")
            
            Text("Clew Maps 2 provides a variety of customizable settings. Learn about some of your options below. You can adjust these options after you complete the tutorial by navigating to the settings page, which is accessible using the settings button located on the home page.")
            
            Text("Color Scheme")
                .font(.title)
            Text("Choose from a variety of high-contrast color schemes including black and white, black and yellow, and blue and yellow. You can also create your own custom two-toned color schemes.")
            
            Text("Crumb Color")
                .font(.title)
            Text("This sets the color of the box-shaped crumb that visually denotes the anchor while navigating. Choose from a list of provided options or create your own custom colors.")
            
            Text("Units")
                .font(.title)
            Text("Select either imperial or metric to adjust the units used throughout the app.")

            Text("Feedback Options")
                .font(.title)
            Text("Clew Maps 2 can provide navigation feedback in a variety of ways including haptics, beeps, voice instructions, and visual indicators on the screen. You can customize your feedback combination by toggling each option on or off.")
            
            
            Spacer()
            
//            SmallButtonComponent_NavigationLink(destination: {
//                HomeView()
//            }, label: "Next")

        }
        .navigationBarBackButtonHidden()
    }
}
