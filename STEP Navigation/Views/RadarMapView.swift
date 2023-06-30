//
//  RadarMapView.swift
//  STEP Navigation
//
//  Created by Evelyn on 6/7/23.
//

import SwiftUI
struct RadarMapView: View {
    @State var focusedIndex: Int? = nil
    let circleDiameter: Double = 700
    
    
    static func getQualityColor(quality: MapPointComponent.Quality) -> (dark: Color, light: Color) {
        switch quality {
        case .low:
            return (dark: StaticAppColor.red, light: StaticAppColor.red)
        case .medium:
            return (dark: StaticAppColor.yellow, light: StaticAppColor.yellow)
        case .high:
            return (dark: StaticAppColor.green, light: StaticAppColor.green)
        }
    }
    
    var body: some View {
            let points = [
                MapPointComponent(distance: 0.5, angle: 30, name: "MAC Door (Near Parking Lot)", quality: .low),
                MapPointComponent(distance: 0.89, angle: 70, name: "MAC Door (Near CC)", quality: .medium),
                MapPointComponent(distance: 0.91, angle: 80, name: "CC Door (Near MAC)", quality: .high),
                MapPointComponent(distance: 0.85, angle: 120, name: "CC Door (Near Stairs)", quality: .low),
                MapPointComponent(distance: 0.88, angle: 124, name: "Main Stair", quality: .low),
                MapPointComponent(distance: 0.75, angle: 150, name: "Library", quality: .medium)
            ]
            
        let toolbarColor = focusedIndex != nil && focusedIndex! != 0 ? RadarMapView.getQualityColor(quality: points[focusedIndex!].quality).light : AppColor.foreground

            ZStack {
                //TODO: add a component here that displays "adjusting to landscape mode" or something like that for a few seconds while the phone adjusts, then disappear to display the map
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RadarChartView(points: points, circleDiameter: circleDiameter, focusedIndex: $focusedIndex)
                    }
                }
                .ignoresSafeArea()
                .background(AppColor.background)
                .onAppear {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation") // Forcing the rotation to landscape
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
                                .lineLimit(3)
                                .frame(width: 120)
                                .accessibilityHidden(true)
                            Spacer()
                        }
                    }
                    .frame(maxWidth: 200)
                    .foregroundColor(AppColor.foreground)
                    Spacer()
                }
                .padding()
            }
            .toolbarBackground(toolbarColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

struct RadarChartView: View {
    var points: [MapPointComponent]
    @State var circleDiameter: Double
    
    @Binding var focusedIndex: Int?
    
    var body: some View {
        let centerX = circleDiameter / 2
        let centerY = circleDiameter / 2
        let radius = circleDiameter / 2
        
        ZStack {
            ZStack {
                SemiCircle()
                    .foregroundColor(AppColor.foreground)
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
                        .stroke(AppColor.background, lineWidth: 4)
                    }
                }
                .frame(width: circleDiameter, height: radius)
                .clipped()
                
                let tickSizeAdjuster: Double = 10
                
                SemiCircle()
                    .foregroundColor(AppColor.foreground)
                    .frame(width: circleDiameter - tickSizeAdjuster, height: radius - tickSizeAdjuster)
                    .position(x: tickSizeAdjuster / 2, y: radius / 2)
                
//                Rectangle()
//                    .foregroundColor(AppColor.background)
//                    .frame(width: circleDiameter, height: 20)
//                    .position(x: radius, y: radius)
            }
            
            ZStack {
                ForEach(points.indices) { index in
                    let isFocused = focusedIndex == index // Check if the current point is focused
                    
                    let angle = points[index].adjustedAngle * .pi / 180.0
                    let distance = points[index].adjustedDistance
                    let radius = (distance / 180.0) * radius
                    
//                    let focusColor = isFocused ? RadarMapView.getQualityColor(quality: points[index].quality).dark : AppColor.foreground
                    
                    let lineEndX = centerX + (radius * cos(angle))
                    let lineEndY = centerY + (radius * sin(angle))
                    
                    let dotSize: Double = 15
                    let dotX = lineEndX
                    let dotY = lineEndY
                    
                    Circle()
                        .frame(width: dotSize, height: dotSize)
                        .position(x: dotX, y: dotY)
                        .foregroundColor(AppColor.background)
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
                        .stroke(AppColor.background, lineWidth: 4)
                        
                        Star(corners: 5, smoothness: 0.5)
                            .fill(AppColor.background)
                            .frame(width: dotSize + 20, height: dotSize + 20)
                            .position(x: dotX, y: dotY)
                            .foregroundColor(AppColor.background)
                            .accessibilityHidden(true)
                    }
                }
            }
            
            Circle()
                .frame(width: 50, height: 50)
                .position(x: radius, y: radius)
                .foregroundColor(AppColor.background)
                .accessibilityElement(children: .ignore)
                .accessibility(label: Text("Orientation Anchor: Traffice Circle near Santos Bench"))
        }
        .frame(width: circleDiameter, height: circleDiameter / 2)
    }
}
