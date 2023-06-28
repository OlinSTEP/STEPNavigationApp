//
//  StartupViews.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/23/23.
//

import SwiftUI

struct StartupPage0: View {
    var settingsManager = SettingsManager.shared
    @State var showTutorials: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Clew Maps 2")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .foregroundColor(AppColor.foreground)
                Text("Designed by a research group at Olin College of Engineering")
                    .font(.title2)
                    .padding()
                    .foregroundColor(AppColor.foreground)
                    .multilineTextAlignment(.center)
                Spacer()
                SmallButtonComponent_NavigationLink(destination: {
                    StartupPage1()
                }, label: "Get Started")
                .padding(.bottom, 40)
            }
            .background(AppColor.background)
            .edgesIgnoringSafeArea([.bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear() {
                settingsManager.toggleShowTutorials(show: false)
            }
        }
    }
}

struct StartupPage1:  View {
    @State var showFullTerms: Bool = false
    
    var body: some View {
            VStack {
                ScreenTitleComponent(titleText: "Welcome to Clew Maps 2", subtitleText: "Precise short distance navigation for the blind and visually impaired")
                    .padding(.top, 60)
                    .background(AppColor.accent)

                ZStack {
                    VStack {
                        Text("Before getting started please note the following: This is not a cane replacement. Please use your own judgment while traveling. Please be aware of your surroundings while using the app. It is your responsibility to maintain your personal safety at all times while using Clew Maps 2.")
                            .bold()
                            .padding()

                        Spacer()
                        
                        Button(action: {showFullTerms = true}) {
                            Text("View Full Terms and Conditions")
                                .font(.title3)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(AppColor.foreground)
                        }
                        .tint(AppColor.background)
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .controlSize(.large)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(AppColor.foreground, lineWidth: 2)
                        )
                        .padding(.horizontal)
                        
                        SmallButtonComponent_NavigationLink(destination: {
                            StartupPage2()
                        }, label: "Accept")
                        .padding(.bottom, 40)

                    }
                    .foregroundColor(AppColor.foreground)
                    
                    if showFullTerms == true {
                        VStack {
                            ScrollView {
                                VStack {
                                    HStack {
                                        Text("Privacy")
                                            .font(.title)
                                            .bold()
                                            .padding(.vertical, 4)
                                        Spacer()
                                    }
                                    
                                    Text("Clew Maps 2 will log the 3D path that your phone travels when using the app. We use this 3D path information to understand the app's shortcomings and to improve its accuracy. We do not tie this 3D path information to the location where the path was traveled (e.g., it is not linked to GPS position). We will not share these data logs with any third party; however, we may make aggregate analysis of this data public (e.g., in an academic paper). Any changes to this privacy policy will be detailed in the app store release notes of future versions of Clew Maps 2.")
                                    
                                    HStack {
                                        Text("Contact")
                                            .font(.title)
                                            .bold()
                                            .padding(.vertical, 4)
                                        Spacer()
                                    }
                                    
                                    Text("Want to get involved with Clew Maps 2? Have some feedback for us about the app? Reach out to the team at example@example.com.")
                                }
                                .padding(.horizontal)
                            }
                            
                            Spacer()
                            
                            SmallButtonComponent_NavigationLink(destination: {
                                StartupPage2()
                            }, label: "Accept")
                            .padding(.bottom, 40)
                        }
                        .foregroundColor(AppColor.foreground)
                        .accessibilityAddTraits(.isModal)
                        .background(AppColor.background)
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .background(AppColor.background)
            .edgesIgnoringSafeArea([.bottom])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }




struct StartupPage2:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Get to your destination by creating routes nonvisually")
                .padding(.top, 60)
                .background(AppColor.accent)
                
            Text("Clew Maps 2 is designed to help blind and visually impaired users navigate short indoor distances. Pinpoint your exact location using visual anchors and follow the precise guidance to within a cane's length of your destination.")
                .bold()
                .foregroundColor(AppColor.foreground)
                .padding()
            
            Spacer()
            
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage3()
            }, label: "Launch Tutorial")
            
            
            NavigationLink(destination: {HomeView()}, label: {
                Text("Skip Tutorial")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(AppColor.foreground)
            })
            .tint(AppColor.background)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(AppColor.foreground, lineWidth: 2)
            )
            .padding(.horizontal)
            .padding(.bottom, 40)
            
            }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

struct StartupPage3:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Using Clew")
                .padding(.top, 20)
                .background(AppColor.foreground)
            
            VStack {
                Text("Clew helps you find your way indoors by recording your route when you go from point A to point B. By recording your route Clew helps you get back to where you started.")
                    .padding(.vertical, 4)
                Text("Clew is best used indoors. The app does not rely on GPS this means that Clew is limited outdoors and over long distances!")
                    .padding(.vertical, 4)
            }
            .bold()
            .foregroundColor(AppColor.foreground)
            .padding(.horizontal)
            
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage4()
            }, label: "Next")
            .padding(.bottom, 40)
            }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit Tutorial")
                        .foregroundColor(AppColor.background)
                        .bold()
                        .font(.title2)
                }
            }
        }
        }
    }

struct StartupPage4:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Holding Your Phone")
                .padding(.top, 20)
                .background(AppColor.foreground)
            
            VStack {
                Text("Clew uses your phone's camera and inertial sensors to track your position as you move around while navigating a route.")
                    .padding(.vertical, 4)
                Text(" For the app to function properly. Make sure to hold your phone vertically, with the back camera facing forward at chest level.")
                    .padding(.vertical, 4)
            }
            .foregroundColor(AppColor.foreground)
            .bold()
            .padding(.horizontal)
            
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage5()
            }, label: "Next")
            .padding(.bottom, 40)

            }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit Tutorial")
                        .foregroundColor(AppColor.background)
                        .bold()
                        .font(.title2)
                }
            }
        }
        }
    }

struct StartupPage5:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Following a Route")
                .padding(.top, 20)
                .background(AppColor.foreground)
            
            VStack {
                Text("Clew will make sounds, vibrate, and give you audio cues to help you follow a route.")
                    .padding(.vertical, 4)
                Text("These sounds and cues will tell you if you're going the right way, if you've slightly gone off track, or if you're completely off the route. They are there to guide you and make sure you stay on the right path.")
                    .padding(.vertical, 4)
            }
            .foregroundColor(AppColor.foreground)
            .bold()
            .padding(.horizontal)
            
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage6()
            }, label: "Next")
            .padding(.bottom, 40)

            }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit Tutorial")
                        .foregroundColor(AppColor.background)
                        .bold()
                        .font(.title2)
                }
            }
        }
        }
    }

struct StartupPage6:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Getting Back on Track")
                .padding(.top, 20)
                .background(AppColor.foreground)
            
            VStack {
                Text("You will hear a different sound when you're not following the right path. This can also happen if your phone is not pointed in the direction of the path. If you realize you're off track, you should stop and turn around until you hear ticking sounds, which means you're facing the right direction.")
                    .padding(.vertical, 4)
                Text("Press the 'Get Directions' button to receive audio directions on how to get back on the route.")
                    .padding(.vertical, 4)
            }
            .padding(.horizontal)
            .bold()
            .foregroundColor(AppColor.foreground)
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage7()
            }, label: "Next")
            .padding(.bottom, 40)

            }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit Tutorial")
                        .foregroundColor(AppColor.background)
                        .bold()
                        .font(.title2)
                }
            }
        }
        }
    }

struct StartupPage7:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "See It In Action")
                .padding(.top, 20)
                .background(AppColor.foreground)
            
            Text("In this video...")
                .padding()
                .foregroundColor(AppColor.foreground)
                .bold()

            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage8()
            }, label: "Next")
            .padding(.bottom, 40)


        }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit Tutorial")
                        .foregroundColor(AppColor.background)
                        .bold()
                        .font(.title2)
                }
            }
        }
        }
    }

struct StartupPage8:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Anchors")
            VStack {
                Text("Setting anchor points is a crucial skill for saving routes or pausing navigation. It helps Clew remember where you are and which way you're facing in the route's surroundings. Anchor points are like markers that make sure you stay on the right path when you want to follow a saved route later on. They play a vital role in making Clew navigate accurately.")
                    .padding(.vertical, 4)
                    .bold()
                
                Text("Anchor points are created at the beginning and at the end of a route. We recommend setting the anchor point at a location that is easy to remember and find at a later time. A good anchor point could be set at a wall, a doorframe, or a piece of furniture like a table.")
                    .padding(.vertical, 4)
                    .bold()
            }
            .padding(.horizontal)
            .foregroundColor(AppColor.foreground)
            
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                HomeView()
            }, label: "Finish Tutorial")
            .padding(.bottom, 40)
            
            }
        .navigationBarBackButtonHidden()
        .background(AppColor.background)
        .edgesIgnoringSafeArea([.bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    HomeView()
                } label: {
                    Text("Exit Tutorial")
                        .foregroundColor(AppColor.background)
                        .bold()
                        .font(.title2)
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
