//
//  PositionRelativeToOutdoors.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 7/3/23.
//

import SwiftUI
import ARCoreGeospatial
import ARCoreCloudAnchors

struct PositionRelativeToOutdoors: View {
    @ObservedObject var positioningModel = PositioningModel.shared
    @StateObject var recordFeedback = RecordFeedback()
    @State var anchorID: String
    @ObservedObject var firebaseManager = FirebaseManager.shared
    
    @State var currentQuality: GARFeatureMapQuality?
    @State var showInstructions: Bool = true
    @State var savePressed: Bool = false
    
    var body: some View {
        ZStack {
           ARViewContainer()
           VStack {
               Spacer()
               if savePressed {
                   VStack {
                       NavigationLink(destination: HomeView(), label: {
                           Text("Home")
                               .font(.title2)
                               .bold()
                               .frame(maxWidth: .infinity)
                               .foregroundColor(AppColor.background)
                       })
                       .tint(AppColor.foreground)
                       .buttonStyle(.borderedProminent)
                       .buttonBorderShape(.capsule)
                       .controlSize(.large)
                       .overlay(
                           RoundedRectangle(cornerRadius: 30)
                               .stroke(AppColor.background, lineWidth: 2)
                       )
                       .padding(.horizontal)
                   }
                   .onAppear() {
                       if let (cloudAnchorPose, cameraPose, cameraGeospatialTransform) = positioningModel.collectPositionRelativeToOutdoors(of: anchorID) {
                           firebaseManager.addPositionRelativeToOutdoors(of: anchorID, anchorPose: cloudAnchorPose, cameraPose: cameraPose, cameraEarthTransform: cameraGeospatialTransform)
                       } else {
                           AnnouncementManager.shared.announce(announcement: "unexpected error!")
                       }
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(AppColor.foreground)
                   .accessibilityAddTraits(.isModal)
               } else if positioningModel.resolvedCloudAnchors.contains(anchorID) &&
                    positioningModel.geoLocalizationAccuracy.isAtLeastAsGoodAs(other: .high) {
                   VStack {
                       HStack {
                           Text("\(FirebaseManager.shared.getCloudAnchorName(byID: anchorID)!) anchor successfully positioned relative to outdoors.")
                               .foregroundColor(AppColor.text_on_accent)
                               .bold()
                               .font(.title2)
                               .multilineTextAlignment(.center)
                       }
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(AppColor.accent)
                   .onAppear {
                       AnnouncementManager.shared.announce(announcement: "\(FirebaseManager.shared.getCloudAnchorName(byID: anchorID)!) anchor successfully positioned relative to outdoors.")
                       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           savePressed = true
                       }
                   }
               } else if positioningModel.resolvedCloudAnchors.contains(anchorID) {
                   HStack {
                       Text("\(FirebaseManager.shared.getCloudAnchorName(byID: anchorID)!) anchor successfully resolved. You can now walk outside and use your phone to establish your latitude and longitude.")
                           .foregroundColor(AppColor.text_on_accent)
                           .bold()
                           .font(.title2)
                           .multilineTextAlignment(.center)
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(AppColor.accent)
                   .onAppear {
                       AnnouncementManager.shared.announce(announcement: "\(FirebaseManager.shared.getCloudAnchorName(byID: anchorID)!) anchor successfully resolved. You can now walk outside and use your phone to establish your latitude and longitude.")
                   }
               } else if !showInstructions {
                   HStack {
                       Text("Stand at \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID)!) and scan your phone around to resolve the anchor.")
                           .foregroundColor(AppColor.text_on_accent)
                           .bold()
                           .font(.title2)
                           .multilineTextAlignment(.center)
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(AppColor.accent)
                   .onAppear {
                       AnnouncementManager.shared.announce(announcement: "Stand at \(FirebaseManager.shared.getCloudAnchorName(byID: anchorID)!) and scan your phone around to resolve the anchor.")
                   }
               }
               Spacer()
           }
           
           if showInstructions {
               VStack {
                   HStack {
                       //Insert instructions here Lisan
                       Text("Instructions here. Go to your first anchor. Etc etc.")
                           .foregroundColor(AppColor.foreground)
                       Spacer()
                   }
                   Spacer()
                   Button {
                       PositioningModel.shared.resolveCloudAnchor(byID: anchorID)
                       showInstructions = false
                   } label: {
                       Text("Find anchor")
                           .font(.title2)
                           .bold()
                           .frame(maxWidth: .infinity)
                           .foregroundColor(AppColor.text_on_accent)
                   }
                   .tint(AppColor.accent)
                   .buttonStyle(.borderedProminent)
                   .buttonBorderShape(.capsule)
                   .controlSize(.large)
                   .padding(.horizontal)
               }
               .background(AppColor.background)
           }
       }
       .background(AppColor.accent)
       .navigationBarBackButtonHidden()
       .toolbar {
           ToolbarItem(placement: .navigationBarLeading) {
               NavigationLink(destination: RecordMultipleChoice(recordfeedback: self.recordFeedback), label: {
                   Text("Cancel")
                       .bold()
                       .font(.title2)
               })
           }
       }
       .onReceive(PositioningModel.shared.$currentQuality) { newQuality in
           currentQuality = newQuality
       }
       .onAppear() {
           PositioningModel.shared.startPositioning()
       }
       .onDisappear() {
           PositioningModel.shared.stopPositioning()
       }
    }
}
