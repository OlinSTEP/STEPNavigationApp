//
//  Components.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/2/23.
//

import SwiftUI

/// This struct manages the appearance of the titles for each screen.
struct ScreenTitleComponent: View {
    let titleText: String
    let subtitleText: String?
    
    /// Init Method
    /// - Parameters:
    ///   - titleText: takes a string to create the main header title
    ///   - subtitleText: takes an optional string to create the subheader title
    init(titleText: String, subtitleText: String? = nil) {
        self.titleText = titleText
        self.subtitleText = subtitleText
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(titleText)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.bottom, subtitleText != nil ? 0.5 : 20)
            
            if let subtitleText = subtitleText {
                HStack {
                    Text(subtitleText)
                        .font(.title2)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, 20)
            }
        }
        .background(AppColor.accent)
    }
}

struct CustomHeaderButtonComponent: View {
    var body: some View {
        Text("Blank")
    }
}


/// This struct manages the appearance of small button components that are navigation links. Their visual appearance is identical to the small button components that are buttons.
struct SmallButtonComponent_NavigationLink<Destination: View>: View {
    let destination: () -> Destination
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    
    /// Init Method
    /// - Parameters:
    ///   - destination: the destination screen for the navigation link
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    init(destination: @escaping () -> Destination, label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent) {
        self.destination = destination
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
    }
    
    
    var body: some View {
            NavigationLink(destination: destination, label: {
                Text(label)
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: 300)
                    .foregroundColor(labelColor)
            })
            .tint(backgroundColor)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
    }
}

/// This struct manages the appearance of small button components that are buttons. Their visual appearance is identical to the small button components that are navigation links.
struct SmallButtonComponent_Button: View {
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    @Binding var popupTrigger: Bool
    let role: ButtonRole?
    
    /// Init Method
    /// - Parameters:
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    ///   - popupTrigger: a boolean that is toggled by pressing the button
    ///   - role: an optional specifier for the role of the button, can take values such as .cancel, .destructive, and more
    init(label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent, popupTrigger: Binding<Bool>, role: ButtonRole? = nil){
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
        self._popupTrigger = popupTrigger
        self.role = role
    }
    
    
    var body: some View {
        
        Button(role: role) {
            popupTrigger.toggle()
        } label: {
            Text(label)
                .font(.title2)
                .bold()
                .frame(maxWidth: 300)
                .foregroundColor(labelColor)
        }
        .tint(backgroundColor)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
    }
}

/// This struct manages the appearance of large button components that are navigation links. Their visual appearance is identical to the large button components that are buttons.
struct LargeButtonComponent_NavigationLink<Destination: View>: View {
    let destination: () -> Destination
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    let labelTextSize: Font?
    let labelTextLeading: Bool?
    
    /// Init Method
    /// - Parameters:
    ///   - destination: the destination screen for the navigation link
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    ///   - labelTextSize: an optional specifier to change the text size of the label; if not text size is specified, the default is .largeTitle
    ///   - labelTextLeading: an optional boolean to make the text leading (left-aligned); by default the boolean is set to false and the text is centered
    init(destination: @escaping () -> Destination, label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent, labelTextSize: Font? = .largeTitle, labelTextLeading: Bool? = false) {
        self.destination = destination
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
        self.labelTextSize = labelTextSize
        self.labelTextLeading = labelTextLeading
    }
    
    var body: some View {
        NavigationLink (
            destination: destination,
            label: {
                HStack {
                    Text(label)
                        .font(labelTextSize)
                        .bold()
                        .padding(30)
                        .foregroundColor(labelColor)
                        .multilineTextAlignment(.leading)
                    if labelTextLeading == true {
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 140)
            })
        .background(backgroundColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

/// This struct manages the appearance of large button components that are buttons Their visual appearance is identical to the large button components that are navigation links.
struct LargeButtonComponent_Button: View {
    let label: String
    let labelColor: Color?
    let backgroundColor: Color?
    let action: () -> Void
    
    /// Init Method
    /// - Parameters:
    ///   - label: the string label for the button component
    ///   - labelColor: an optional color for the text label of the button; if no color is specified, the default color is AppColor.dark
    ///   - backgroundColor: an optional color for the background color of the button; if no color is specified, the default color is AppColor.accent
    ///   - action: the action for the button to perform, can take any length of code
    init(label: String, labelColor: Color? = AppColor.dark, backgroundColor: Color? = AppColor.accent, action: @escaping () -> Void ) {
        self.label = label
        self.labelColor = labelColor
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.title)
                    .bold()
                    .padding(30)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(labelColor)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 140)
        }
        .background(backgroundColor)
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

/// This struct is responsible for the presentation of various types of informational popups based on the type of popup.
struct InformationPopupComponent: View {
    let popupType: PopupType
    
    /// Init Method
    /// - Parameter popupType:this is a parameter that shows the type of popup
    init(popupType: PopupType) {
        self.popupType = popupType
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(popupType.messageText)
                    .foregroundColor(AppColor.light)
                    .bold()
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            if case .arrived = popupType {
                SmallButtonComponent_NavigationLink(destination: {
                    MainView()
                }, label: "Home")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColor.dark)
    }
    
    /// This enumeration represents the different types of popups that can be presented.
    ///
    /// - `waitingToLocalize`:The popup type when the app is aligning the route.
    /// - `arrived`: The popup type when the user arrives at the last cloud anchor.
    /// - `direction`: The popup type when the application is providing a direction, which holds a string value                 representing the direction text.
    enum PopupType {
        case waitingToLocalize
        case arrived
        case direction(directionText: String)
        
        var messageText: String {
            switch self {
            case .arrived:
                return "Arrived. You should be within one cane's length of your destination."
            case . waitingToLocalize:
                return "Trying to align to your route. Scan your phone around to recognize your surroundings."
            case .direction(let directionText):
                return directionText
            }
        }
    }
}


/// This struct displays the details of the cloud anchor.
struct AnchorDetailsComponent: View {
    let title: String
    let distanceAway: String
    let locationNotes: String?
    
    /// Init Method
    /// - Parameters:
    ///   - title: Name of the destination.
    ///   - distanceAway: Distance away from the destination.
    ///   - locationNotes: Optional notes for the location.
    init(title: String, distanceAway: String, locationNotes: String? = "No notes available for this location.") {
        self.title = title
        self.distanceAway = distanceAway
        self.locationNotes = locationNotes
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                Spacer()
            }
            
            HStack {
                    Text("\(distanceAway) meters away")
                        .font(.title)
                        .padding(.horizontal)
                Spacer()
            }
            VStack {
                HStack {
                    Text("Location Notes")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 1)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                ScrollView {
                    HStack {
                        if let locationNotes = locationNotes {
                            Text(locationNotes)
                        }
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 2)
        }
        
    }
}

struct ActionBarComponent: View {
    var body: some View {
        Text("Blank")
    }
}
