//
//  HapticFeedbackAdapter.swift
//  STEP Navigation
//
//  Created by Paul Ruvolo on 4/6/23.
//

import Foundation
import ARKit
import CoreHaptics

/// Provides an interface that allows navigation instructions to be provided to the
/// user in the form of haptic feedback.
class HapticFeedbackAdapter {
    /// The handle to the singleton instance of this class
    public static var shared = HapticFeedbackAdapter()
    
    /// record whether we've started the end of route haptics
    var startedEndOfRouteHaptics: Bool?
    /// Allows us to use the core haptics API
    var hapticEngine: CHHapticEngine?
    /// Controls the dynamic haptic pattern at the end of the route
    var hapticPlayer: CHHapticAdvancedPatternPlayer?
    
    /// this shouldn't be called directly (instead use the singleton instance)
    private init() {
        
    }
    
    /// Adjust the haptics based on the provided intensity
    /// - Parameter intensity: an intensity value in the range of 0.0 to 1.0
    func adjustHaptics(intensity: Float) {
        do {
            try hapticPlayer?.sendParameters([CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0.0)], atTime: 0.0)
        } catch {
            print("couldn't adjust")
        }
    }
    
    /// Adjust the intensity of the haptics based on the relative position of the user and the goal.
    /// The intensity will be greater when the user is closer to the goal.
    /// - Parameters:
    ///   - pos: The user's position projected onto the X-Z plane of the ARSession
    ///   - goal: The goal position projected onto the X-Z plane of the ARSession
    func adjustHaptics(pos: simd_float2, goal: simd_float2) {
        adjustHaptics(intensity: max(0.0, 1.0 - simd_distance(pos, goal)))
    }
    
    /// Stop the haptics immediately
    func stopHaptics() {
        do {
            try hapticPlayer?.stop(atTime: 0.0)
        } catch {
            
        }
    }
    
    /// Start the haptic engine and allow for subsequent calls to adjustHaptics to be effective.
    func startHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            hapticEngine?.start() { error in
                if error != nil {
                    print("error \(error?.localizedDescription ?? "none")")
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
