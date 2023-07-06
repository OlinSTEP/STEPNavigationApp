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
            ScreenBackground {
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
                    SmallNavigationLink(destination: StartupPage1(), label: "Get Started")
                }
                .onAppear() {
                    settingsManager.toggleShowTutorials(show: false)
                }
            }
        }
    }
}

struct StartupPage1:  View {
    @State var showFullTerms: Bool = false
    
    var body: some View {
        ZStack {
            ScreenBackground {
                VStack {
                    ScreenHeader(title: "Welcome to Clew Maps 2", subtitle: "Precise short distance navigation for the blind and visually impaired", backButtonHidden: true)
                        StartupText("Before getting started please note the following: This is not a cane replacement. Please use your own judgment while traveling. Please be aware of your surroundings while using the app. It is your responsibility to maintain your personal safety at all times while using Clew Maps 2.")
                        Spacer()
                        
                        VStack(spacing: 20) {
                            SmallButton(action: {
                                showFullTerms = true
                            }, label: "View Full Terms and Conditions", invert: true)
                            SmallNavigationLink(destination: StartupPage2(), label: "Accept")
                    }
                }
            }
            if showFullTerms == true {
                VStack {
                    ScreenHeader(title: "Terms and Conditions", backButtonHidden: true)
                    ScrollView {
                        LeftLabel(text: "Privacy")
                        Text("Clew Maps 2 will log the 3D path that your phone travels when using the app. We use this 3D path information to understand the app's shortcomings and to improve its accuracy. We do not tie this 3D path information to the location where the path was traveled (e.g., it is not linked to GPS position). We will not share these data logs with any third party; however, we may make aggregate analysis of this data public (e.g., in an academic paper). Any changes to this privacy policy will be detailed in the app store release notes of future versions of Clew Maps 2.")
                            .padding(.bottom, 4)
                        
                        LeftLabel(text: "Contact")
                        Text("Want to get involved with Clew Maps 2? Have some feedback for us about the app? Reach out to the team at example@example.com.")
                    }
                    .padding(.horizontal)
                    Spacer()
                    SmallNavigationLink(destination: StartupPage2(), label: "Accept")
                        .padding(.bottom, 48)
                }
                .foregroundColor(AppColor.foreground)
                .accessibilityAddTraits(.isModal)
                .background(AppColor.background)
                .edgesIgnoringSafeArea([.bottom])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}




struct StartupPage2:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "What is Clew Maps 2?", backButtonHidden: true)
                StartupText("Clew Maps 2 is designed to help blind and visually impaired users navigate short indoor distances. Pinpoint your exact location using visual anchors and follow the precise guidance to within a cane's length of your destination.")
                Spacer()
                SmallNavigationLink(destination: StartupPage3(), label: "Launch Tutorial")
                SmallNavigationLink(destination: HomeView(), label: "Skip Tutorial", invert: true)
            }
        }
    }
}

struct StartupPage3:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Using Clew")
                
                StartupParagraph(["Clew helps you find your way indoors by recording your route when you go from point A to point B. By recording your route Clew helps you get back to where you started.", "Clew is best used indoors over short distances. Because the app does not use GPS for navigation it is limited outdoors and over long distances."])
                Spacer()
                SmallNavigationLink(destination: StartupPage4(), label: "Next")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
        }
    }
}

struct StartupPage4:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Holding Your Phone")
                StartupParagraph(["Clew uses your phone's camera and inertial sensors to track your position as you move around while navigating a route.", "For the app to function properly. Make sure to hold your phone vertically, with the back camera facing forward at chest level."])
                Spacer()
                SmallNavigationLink(destination: StartupPage5(), label: "Next")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
        }
    }
}

struct StartupPage5:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Following a route")
                StartupParagraph(["Clew will make sounds, vibrate, and give you audio cues to help you follow a route.", "These sounds and cues will tell you if you're going the right way, if you've slightly gone off track, or if you're completely off the route. They are there to guide you and make sure you stay on the right path."])
                Spacer()
                SmallNavigationLink(destination: StartupPage6(), label: "Next")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
        }
    }
}

struct StartupPage6:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Getting Back on Track")
                StartupParagraph(["You will hear a different sound when you're not following the right path. This can also happen if your phone is not pointed in the direction of the path. If you realize you're off track, you should stop and turn around until you hear ticking sounds, which means you're facing the right direction.", "Press the 'Get Directions' button to receive audio directions on how to get back on the route."])
                Spacer()
                SmallNavigationLink(destination: StartupPage7(), label: "Next")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
        }
    }
}

struct StartupPage7:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "See it in Action")
                StartupText("In this video we will demonstraate how Clew works.")
                Spacer()
                SmallNavigationLink(destination: StartupPage8(), label: "Next")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
        }
    }
}

struct StartupPage8:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Anchors", backButtonHidden: true)
                StartupParagraph(["Setting anchor points is a crucial skill for saving routes or pausing navigation. It helps Clew remember where you are and which way you're facing in the route's surroundings. Anchor points are like markers that make sure you stay on the right path when you want to follow a saved route later on. They play a vital role in making Clew navigate accurately.", "Anchor points are created at the beginning and at the end of a route. We recommend setting the anchor point at a location that is easy to remember and find at a later time. A good anchor point could be set at a wall, a doorframe, or a piece of furniture like a table."])
                Text("Indoor Vs. Outdoor Navigation")
                Text("As you walk outside,, Clew runs in a straight line regardless of obsticles in your path. It is up to you to navigate around the obsticles. While indoors, itis more connected.")

                Spacer()
                SmallNavigationLink(destination: HomeView(), label: "Finish Tutorial")
            }
            .navigationBarBackButtonHidden()
        }
    }
}

struct StartupText: View {
    let text: String
    
    init(_ text: String) {
            self.text = text
        }
    
    var body: some View {
        HStack {
            Text(text)
                .bold()
                .foregroundColor(AppColor.foreground)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct StartupParagraph: View {
    let texts: [String]
    
    init(_ texts: [String]) {
            self.texts = texts
        }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(texts, id: \.self) { text in
                StartupText(text)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ExitTutorial: ToolbarContent {
    var body: some ToolbarContent {
        HeaderNavigationLink(label: "Exit Tutorial", placement: .navigationBarLeading, destination: HomeView())
    }
}

