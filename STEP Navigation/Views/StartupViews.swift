//
//  StartupViews.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/23/23.
//

import SwiftUI

struct StartupPage0: View {
    var body: some View {
        Text("Clew Maps 2")
        Text("Designed by a research group at Olin College of Engineering")
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
            }
        .navigationBarBackButtonHidden()
        }
    }

struct StartupPage3:  View {
    var body: some View {
        VStack {
            ScreenTitleComponent(titleText: "Step 1: Create A Cloud Anchor")
            Text(" add first one here  ")
            Text("make your second anchor here:")
            Text("connect your anchors here!")
            Spacer()
            SmallButtonComponent_NavigationLink(destination: {
                StartupPage_Preferences()
            }, label: "Next")
            }
        .navigationBarBackButtonHidden()
        }
    }

struct StartupPage_Preferences: View {
    var body: some View {
        VStack {
//            ScreenTitleComponent(titleText: "Your Preferences")
            
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
