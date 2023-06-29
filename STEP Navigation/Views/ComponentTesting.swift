//
//  ComponentTesting.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/28/23.
//

import SwiftUI

struct ComponentTesting: View {
    @State var testingToggle: Bool = true
    @State var testingTextEntry: String = ""
    @State var editing: Bool = false
    @State var pickerSelected: String = "Apple"
    @State var showPicker: Bool = false
    @State var showConfirmationPopup: Bool = false
    @State var firstCheck: Bool = false
    @State var secondCheck: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScreenHeader(title: "Testing", backButtonHidden: true)
                    ScrollView {
                        VStack(spacing: 20) {
//                            LargeNavigationLink(destination: HomeView(), label: "Large Navigation Link", alignment: .center)
                            
                            //                        LargeButton(action: {
                            //                            print("pressed large button")
                            //                        }, label: "Large Button", invert: true)
                            //
                            //                        SmallNavigationLink(destination: HomeView(), label: "Small Navigation Link", secondaryAction: {print("secondary action small nav")})
                            //
                            //                        SmallButton(action: {
                            //                            print("small button")
                            //                        }, label: "Small Button", invert: true)
                            //
                            //                        SegmentedToggle(toggle: $testingToggle, trueLabel: "True", falseLabel: "False", foregroundColor: .red, backgroundColor: .green)
                            //
                            //                        CustomTextField(entry: $testingTextEntry, textBoxSize: .large)
                            //
                            //                        ComboBox(allOptions: ["Apple", "Pear", "Pineapple", "Lemon"], editing: $editing, inputText: $testingTextEntry)
                            
//                            PickerButton(allOptions: ["Apple", "Pear", "Pineapple"], selection: $pickerSelected, showPage: $showPicker)
//
//                            ARViewTextOverlay(text: "Testing text here. adskfjsa asdlkfj sdf asdlkgja hfaj sadflakjsd fslkj.", buttonLabel: "next", buttonDestination: HomeView(), announce: "Testing text here. This is an announcement")
                            
                            AnchorDetailsText(title: "Bathroom Testing", distanceAway: 32, locationNotes: "These are location notes. Yay! There are notes here. Notes notes notes notes.")
                            
                            SmallButton(action: {
                                showConfirmationPopup = true
                            }, label: "Confirmation Popup")
                            
                            ChecklistItem(toggle: $firstCheck, label: "First Check")
                            ChecklistItem(toggle: $secondCheck, label: "Second Check")

                        }
                    }
                }
                .background(AppColor.background)
                .edgesIgnoringSafeArea([.bottom])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if showPicker {
                    PickerPage(allOptions: ["Apple", "Pear", "Pineapple"], selection: $pickerSelected, showPage: $showPicker)
                }
                
                if showConfirmationPopup {
                    ConfirmationPopup2(showingConfirmation: $showConfirmationPopup, titleText: "Confirm the thing here. This is a title.", confirmButtonLabel: "Yes", confirmButtonDestination: HomeView())
                }
            }
        }
        .accentColor(AppColor.background)

    }
}

