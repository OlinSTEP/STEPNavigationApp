//
//  MapComponents.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/9/23.
//

import SwiftUI

struct calculateScreenSize {
    var CircleDiameter: Double {
        return 700
    }
}

struct MapPointComponent {
    let distance: Double
    let angle: Double
    let name: String
    let quality: Quality
    
    var adjustedAngle: Double {
        return angle + 180
    }
    
    var adjustedDistance: Double {
        return distance * 180
    }
    
    var angleToClock: String {
        switch angle {
        case 0..<15:
            return "9 o'clock"
        case 15..<45:
            return "10 o'clock"
        case 45..<75:
            return "11 o'clock"
        case 75..<105:
            return "12 o'clock"
        case 105..<135:
            return "1 o'clock"
        case 135..<165:
            return "2 o'clock"
        case 165..<180:
            return "3 o'clock"
        default:
            return "Invalid Angle"
        }
    }
    
    enum Quality: String {
        case
            low = "Low",
            medium = "Medium",
            high = "High"
    }
}

struct SemiCircle: Shape {
    func path(in rect: CGRect) -> Path {
        Path {
            $0.move(to: CGPoint(x: 0, y: rect.maxY))
            $0.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            $0.addArc(center: CGPoint(x: rect.maxX, y: rect.maxY), radius: rect.maxY, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            $0.addArc(center: CGPoint(x: rect.maxX, y: rect.maxY), radius: rect.maxY, startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 360), clockwise: false)
            $0.move(to: CGPoint(x: 0, y: rect.maxY))
        }
    }
}

struct Star: Shape {
    // store how many corners the star has, and how smooth/pointed it is
    let corners: Int
    let smoothness: Double

    func path(in rect: CGRect) -> Path {
        // ensure we have at least two corners, otherwise send back an empty path
        guard corners >= 2 else { return Path() }

        // draw from the center of our rectangle
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)

        // start from directly upwards (as opposed to down or to the right)
        var currentAngle = -CGFloat.pi / 2

        // calculate how much we need to move with each star corner
        let angleAdjustment = .pi * 2 / Double(corners * 2)

        // figure out how much we need to move X/Y for the inner points of the star
        let innerX = center.x * smoothness
        let innerY = center.y * smoothness

        // we're ready to start with our path now
        var path = Path()

        // move to our initial position
        path.move(to: CGPoint(x: center.x * cos(currentAngle), y: center.y * sin(currentAngle)))

        // track the lowest point we draw to, so we can center later
        var bottomEdge: Double = 0

        // loop over all our points/inner points
        for corner in 0..<corners * 2  {
            // figure out the location of this point
            let sinAngle = sin(currentAngle)
            let cosAngle = cos(currentAngle)
            let bottom: Double

            // if we're a multiple of 2 we are drawing the outer edge of the star
            if corner.isMultiple(of: 2) {
                // store this Y position
                bottom = center.y * sinAngle

                // …and add a line to there
                path.addLine(to: CGPoint(x: center.x * cosAngle, y: bottom))
            } else {
                // we're not a multiple of 2, which means we're drawing an inner point

                // store this Y position
                bottom = innerY * sinAngle

                // …and add a line to there
                path.addLine(to: CGPoint(x: innerX * cosAngle, y: bottom))
            }

            // if this new bottom point is our lowest, stash it away for later
            if bottom > bottomEdge {
                bottomEdge = bottom
            }

            // move on to the next corner
            currentAngle += angleAdjustment
        }

        // figure out how much unused space we have at the bottom of our drawing rectangle
        let unusedSpace = (rect.height / 2 - bottomEdge) / 2

        // create and apply a transform that moves our path down by that amount, centering the shape vertically
        let transform = CGAffineTransform(translationX: center.x, y: center.y + unusedSpace)
        return path.applying(transform)
    }
}
