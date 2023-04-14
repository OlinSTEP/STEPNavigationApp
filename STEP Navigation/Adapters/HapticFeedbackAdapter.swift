//
//  HapticFeedbackAdapter.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/6/23.
//

import Foundation
import ARKit
import CoreHaptics

class HapticFeedbackAdapter {
    public static var shared = HapticFeedbackAdapter()
    
    /// record whether we've started the end of route haptics
    var startedEndOfRouteHaptics: Bool?
    /// Allows us to use the core haptics API
    var hapticEngine: CHHapticEngine?
    /// Controls the dynamic haptic pattern at the end of the route
    var hapticPlayer: CHHapticAdvancedPatternPlayer?
    
    private init() {
        
    }
    
    func adjustHaptics(intensity: Float) {
        do {
            try hapticPlayer?.sendParameters([CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0.0)], atTime: 0.0)
        } catch {
            print("couldn't adjust")
        }
    }
    
    func adjustHaptics(pos: simd_float2, goal: simd_float2) {
        adjustHaptics(intensity: max(0.0, 1.0 - simd_distance(pos, goal)))
    }
    
    func startEndOfRouteHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.start() { error in
                if error != nil {
                    print("error \(error?.localizedDescription)")
                    return
                }
                let events = [CHHapticEvent(eventType: .hapticContinuous, parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.1),
                    CHHapticEventParameter(parameterID: .attackTime, value: 0.1),
                    CHHapticEventParameter(parameterID: .releaseTime, value: 0.2),
                    CHHapticEventParameter(parameterID: .decayTime, value: 0.3) ], relativeTime: 0.1, duration: 0.6)]
                
                do {
                    self.hapticPlayer = try self.hapticEngine?.makeAdvancedPlayer(with: CHHapticPattern(events: events, parameters: []))
                    self.hapticPlayer?.loopEnabled = true
                    try self.hapticPlayer?.start(atTime: 0)
                    self.startedEndOfRouteHaptics = true
                    print("Started Haptics!!")
                } catch {
                    print("HAPTICS ERROR!!!")
                    
                }
            }
        } catch {
            print("Unable to start haptic engine")
        }
    }
}
