//
//  RadarMapView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/7/23.
//

import SwiftUI
struct RadarMapView_Dev: View {
    @State var focusedIndex: Int? = nil
    let circleDiameter: Double = 700
    
    static func getQualityColor(quality: Point.Quality) -> (dark: Color, light: Color) {
        switch quality {
        case .low:
            return (dark: AppColor.darkred, light: AppColor.lightred)
        case .medium:
            return (dark: AppColor.darkyellow, light: AppColor.lightyellow)
        case .high:
            return (dark: AppColor.darkgreen, light: AppColor.lightgreen)
        }
    }
    
    var body: some View {
            let points = [
                Point(distance: 0.5, angle: 30, name: "MAC Door (Near Parking Lot)", quality: .low),
                Point(distance: 0.89, angle: 70, name: "MAC Door (Near CC)", quality: .medium),
                Point(distance: 0.91, angle: 80, name: "CC Door (Near MAC)", quality: .high),
                Point(distance: 0.85, angle: 120, name: "CC Door (Near Stairs)", quality: .low),
                Point(distance: 0.88, angle: 124, name: "Main Stair", quality: .low),
                Point(distance: 0.75, angle: 150, name: "Library", quality: .medium)
            ]
            
        let toolbarColor = focusedIndex != nil && focusedIndex! != 0 ? RadarMapView_Dev.getQualityColor(quality: points[focusedIndex!].quality).light : AppColor.accent

            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RadarChartView(points: points, circleDiameter: circleDiameter, focusedIndex: $focusedIndex)
                    }
                }
                .ignoresSafeArea()
                .background(AppColor.dark)
                .onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation") // Forcing the rotation to portrait
                    AppDelegate.orientationLock = .landscapeRight // And making sure it stays that way
                }
                .onDisappear {
                    AppDelegate.orientationLock = .portrait // Unlocking the rotation when leaving the view
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        if let focusedIndex = focusedIndex {
                            HStack {
                                Text(points[focusedIndex].name)
                                    .font(.largeTitle)
                                    .multilineTextAlignment(.leading)
                                    .bold()
                                    .accessibilityHidden(true)
                                    .lineLimit(3)
                                Spacer()
                            }
                            .frame(width: 236)

                            HStack {
                                Text("\(String(format: "%.0f", points[focusedIndex].adjustedDistance)) units away")
                                    .font(.title)
                                    .accessibilityHidden(true)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .frame(width: 200)

                            HStack {
                                Text(points[focusedIndex].angleToClock)
                                    .font(.title)
                                    .accessibilityHidden(true)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .frame(width: 180)

                        }
                        Spacer()
                        
                        HStack {
                            Text("Traffic Circle Near Santos Bench")
                                .font(.title3)
                                .bold()
                                .multilineTextAlignment(.leading)
                                .foregroundColor(AppColor.accent)
                                .lineLimit(3)
                                .frame(width: 120)
                                .accessibilityHidden(true)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: 200)
                    .foregroundColor(AppColor.light)
                    Spacer()
                }
                .padding()
            }
            .toolbarBackground(toolbarColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct Point {
    var distance: Double
    var angle: Double
    var name: String
    var quality: Quality
    
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

struct RadarChartView: View {
    var points: [Point]
    @State var circleDiameter: Double
    
    @Binding var focusedIndex: Int?
    
    var body: some View {
        let centerX = circleDiameter / 2
        let centerY = circleDiameter / 2
        let radius = circleDiameter / 2
        
        ZStack {
            ZStack {
                SemiCircle()
                    .foregroundColor(AppColor.light)
                    .frame(width: circleDiameter, height: radius)
                    .position(x: 0, y: radius / 2)
                
                ZStack {
                    ForEach(0..<12) { index in
                        let angle = Double(index) * (Double.pi / 6)
                        
                        let startX = centerX
                        let startY = centerY
                        
                        let endX = startX + (radius * cos(angle))
                        let endY = startY + (radius * sin(angle))
                        
                        Path { path in
                            path.move(to: CGPoint(x: startX, y: startY))
                            path.addLine(to: CGPoint(x: endX, y: endY))
                        }
                        .stroke(.black, lineWidth: 4)
                    }
                }
                .frame(width: circleDiameter, height: radius)
                .clipped()
                
                let tickSizeAdjuster: Double = 10
                
                SemiCircle()
                    .foregroundColor(AppColor.light)
                    .frame(width: circleDiameter - tickSizeAdjuster, height: radius - tickSizeAdjuster)
                    .position(x: tickSizeAdjuster / 2, y: radius / 2)
                
                Rectangle()
                    .foregroundColor(AppColor.light)
                    .frame(width: circleDiameter, height: 20)
                    .position(x: radius, y: radius)
            }
            
            ZStack {
                ForEach(points.indices) { index in
                    let isFocused = focusedIndex == index // Check if the current point is focused
                    
                    let angle = points[index].adjustedAngle * .pi / 180.0
                    let distance = points[index].adjustedDistance
                    let radius = (distance / 180.0) * radius
                    
                    let focusColor = isFocused ? RadarMapView_Dev.getQualityColor(quality: points[index].quality).dark : AppColor.dark
                    
                    let lineEndX = centerX + (radius * cos(angle))
                    let lineEndY = centerY + (radius * sin(angle))
                    
                    let dotSize: Double = 15
                    let dotX = lineEndX
                    let dotY = lineEndY
                    
                    Circle()
                        .frame(width: dotSize, height: dotSize)
                        .position(x: dotX, y: dotY)
                        .foregroundColor(focusColor)
                        .accessibilityElement(children: .ignore)
                        .accessibility(label: Text(points[index].name))
                        .accessibility(value: Text("\(String(format: "%.0f", points[index].adjustedDistance)) units away at \(points[index].angleToClock)"))
                        .onTapGesture {
                            focusedIndex = index
                        }
                    if isFocused {
                        Path { path in
                            path.move(to: CGPoint(x: centerX, y: centerY))
                            path.addLine(to: CGPoint(x: lineEndX, y: lineEndY))
                        }
                        .stroke(focusColor, lineWidth: 4)
                    }
                }
            }
            
            Circle()
                .frame(width: 50, height: 50)
                .position(x: radius, y: radius)
                .foregroundColor(AppColor.accent)
                .accessibilityElement(children: .ignore)
                .accessibility(label: Text("Orientation Anchor: Traffice Circle near Santos Bench"))
        }
        .frame(width: circleDiameter, height: circleDiameter / 2)
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
