//
//  StartupViews.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/23/23.
//

import SwiftUI
import AVKit

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
                        .font(.title)
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
                    ScreenHeader(title: "Welcome to Clew Maps 2", subtitle: "Precise Short Distance Navigation for the Blind and Visually Impaired", backButtonHidden: true)
                    ScrollView {
                        StartupText("Before getting started please note the following: This is not a cane replacement. Please use your own judgment while traveling. Please be aware of your surroundings while using the app. It is your responsibility to maintain your personal safety at all times while using Clew Maps 2.")
                    }
                        Spacer()
                        
                    VStack(spacing: 28) {
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
                        StartupText("Clew Maps 2 will log the 3D path that your phone travels when using the app. We use this 3D path information to understand the app's shortcomings and to improve its accuracy. We will not share these data logs with any third party; however, we may make aggregate analysis of this data public (e.g., in an academic paper). Any changes to this privacy policy will be detailed in the app store release notes of future versions of Clew Maps 2.")
                            .padding(.bottom, 4)
                        
                        LeftLabel(text: "Contact")
                        StartupText("Want to get involved with Clew Maps 2? Have some feedback for us about the app? Reach out to the team leader at pruvolo@olin.edu.")
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
                ScrollView {
                    StartupText("Clew Maps 2 is designed to help blind and visually impaired users navigate short indoor distances. Pinpoint your exact location using visual anchors and follow the precise guidance to within a cane's length of your destination.")
                }
                Spacer()
                VStack(spacing: 28) {
                    SmallNavigationLink(destination: StartupPage3(), label: "Launch Tutorial")
                    SmallNavigationLink(destination: HomeView(), label: "Skip Tutorial", invert: true)
                }
            }
        }
    }
}

struct StartupPage3:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Using Clew Maps 2")
                ScrollView {
                    UnorderedList(listItems: ["Clew Maps 2 helps you find your way indoors by recording and connecting anchors.", "The app is best used over short distances."])
                }
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
                ScrollView {
                    UnorderedList(listItems: ["Clew Maps 2 uses your phone’s camera and sensors to track your position as you navigate a route.", "Hold your phone vertically, with the back camera facing forward at chest level."])
                }
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
                ScrollView {
                    UnorderedList(listItems: ["Clew Maps 2 will vibrate and give you audio clues as you follow a route. If you veer off the path the clues will stop.", "If you stop hearing the audio clues, stop and turn the phone from side to side until the sounds resume.", "If needed, press the 'Get Directions' button for audio directions to get back on the route."])
                }
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
                ScreenHeader(title: "Demo Video: How to Follow a Route")
                VideoView(videoID: "aVLYKcKvoC4")
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
                ScreenHeader(title: "Anchors")
                ScrollView {
                    UnorderedList(listItems: ["Anchor points are markers that make sure you stay on the right path as you navigate a route.", "They are crucial for saving routes or pausing navigation because they allow Clew Maps 2 to remember where you are and which way you’re facing.", "You will create anchors at the beginning and end of a route. Clew Maps 2 will automatically add anchors along long routes.", "Try to set the anchor point at an easy-to-remember location (ex. doorframe, furniture)."])
                }
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
                ScreenHeader(title: "Demo Video: How to Create an Anchor")
                VideoView(videoID: "ZYOYGU-PIQw")
                Spacer()
                SmallNavigationLink(destination: StartupPage9(), label: "Next")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
        }
    }
}

struct StartupPage9:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Connecting Anchors")
                ScrollView {
                    UnorderedList(listItems: ["After creating anchors they need to be connected to create a map of the space. There are three types of connections.", "Directly connected anchors are two anchors that have a route recorded directly between them; every time you record a connection you are creating directly connected anchors.", "Indirectly connected anchors are anchors that are connected by a series of multiple routes.", "Connected in Reverse anchors are anchors that were directly connected in only one direction (i.e. from Anchor A to Anchor B) and had the reverse route (i.e. from Anchor B to Anchor A) auto-generated."])
                }
                Spacer()
                SmallNavigationLink(destination: StartupPage10(), label: "Next")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
        }
    }
}

struct StartupPage10:  View {
    var body: some View {
        ScreenBackground {
            VStack {
                ScreenHeader(title: "Demo Video: How to Connect Anchors")
                VideoView(videoID: "vFuFk05MYvA")
                Spacer()
                SmallNavigationLink(destination: HomeView(), label: "Finish Tutorial")
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ExitTutorial()
            }
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
                .font(.title2)
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
        HeaderNavigationLink(label: "Exit Tutorial", placement: .navigationBarTrailing, destination: HomeView())
    }
}

