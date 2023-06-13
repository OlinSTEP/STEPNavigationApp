//
//  InstructionsView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/13/23.
//

import SwiftUI

struct RecordAnchorInstructionsView: View {
    var body: some View {
        let instructionListItems = [
            "Hold your phone vertically at chest height, such that the camera is facing straight out in front of you.",
            "Move your phone left to right in a wide arc.",
            "Turn around 180 degrees and move your phone left to right in a wide arc.",
            "Tilt your phone very slightly upwards.",
            "Repeat steps 2 and 3.",
            "Tilt your phone very slightly downwards.",
            "Repeat steps 2 and 3.",
            "Take a few steps back and repeat steps 1 through 7.",
            "If there is still time remaining, continue to move your phone around to capture the anchor from as many angles as possible."
        ]
        
        let tipListItems = [
            "Anchors take 30 seconds to record.",
            "A countdown timer is present on the recording screen and a chime will sound when the anchor has been successfully created.",
            "Try to stand facing a fixed landmark, such as a particular door, sign, table, etc."
        ]
        
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Quick Reminders")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    OrderedList(listItems: tipListItems)
                    
                    HStack {
                        Text("Instructions")
                            .font(.title2)
                            .bold()
                        Spacer()
                    }
                    Text("Stand in the anchor destination with the rear camera pointing away from you. Move your phone slowly and steadily as you complete the following motions.")
                    OrderedList(listItems: instructionListItems)
                }
                .padding()
            }
            Spacer()
        }
        .frame(width: .infinity, height: .infinity)
        .background(AppColor.light)
    }
}

struct OrderedList: View {
    var listItems: [String]
    var listItemSpacing: CGFloat? = nil
    var toNumber: ((Int) -> String) = { "\($0 + 1)." }
    var bulletWidth: CGFloat? = nil
    var bulletAlignment: Alignment = .leading
    
    var body: some View {
        VStack(alignment: .leading,
               spacing: listItemSpacing) {
            ForEach(listItems.indices, id: \.self) { idx in
                HStack(alignment: .top) {
                    Text(toNumber(idx))
                        .frame(width: bulletWidth,
                               alignment: bulletAlignment)
                    Text(listItems[idx])
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }
            }
        }
       .padding(2)
    }
}
