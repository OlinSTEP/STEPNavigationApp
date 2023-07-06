//
//  SoundEffectManager.swift
//  Clew
//
//  Created by Paul Ruvolo on 8/18/21.
//  Copyright © 2021 OccamLab. All rights reserved.
//

import Foundation
import AVFoundation

/// A class that manages playing system sounds as well as custom audio files
class SoundEffectManager {
    /// a handle to the shared singleton instance of SoundEffectManager
    public static var shared = SoundEffectManager()
    /// a player for the success sound
    private var successSound: AVAudioPlayer?
    /// a player for the meh sound
    private var mehSound: AVAudioPlayer?
    /// a player for the on track sound
    private var onTrackSound: AVAudioPlayer?
    /// a player for the error sound
    private var errorSound: AVAudioPlayer?

    /// audio players for playing system sounds through an `AVAudioSession` (this allows them to be audible even when the rocker switch is muted.
    var audioPlayers: [Int: AVAudioPlayer] = [:]
    
    /// the private initializer (don't call this directly)
    private init() {
        loadSoundEffects()
    }
    
    /// Load the sound effects and prepare the audio players
    private func loadSoundEffects() {
        if let successPath = Bundle.main.path(forResource: "ClewSuccessSound", ofType:"wav") {
            do {
                let url = URL(fileURLWithPath: successPath)
                successSound = try AVAudioPlayer(contentsOf: url)
                successSound?.prepareToPlay()
            } catch {
                print("error \(error)")
            }
        }
        if let errorPath = Bundle.main.path(forResource: "ClewErrorSound", ofType:"wav") {
            do {
                let url = URL(fileURLWithPath: errorPath)
                errorSound = try AVAudioPlayer(contentsOf: url)
                errorSound?.prepareToPlay()
            } catch {
                print("error \(error)")
            }
        }
        if let mehPath = Bundle.main.path(forResource: "ClewTutorialFeedback", ofType:"wav") {
            do {
                let url = URL(fileURLWithPath: mehPath)
                mehSound = try AVAudioPlayer(contentsOf: url)
                mehSound?.prepareToPlay()
            } catch {
                print("error \(error)")
            }
        }
        if let onTrackPath = Bundle.main.path(forResource: "caf_MultiwayJoin", ofType:"wav") {
            do {
                let url = URL(fileURLWithPath: onTrackPath)
                onTrackSound = try AVAudioPlayer(contentsOf: url)
                onTrackSound?.prepareToPlay()
            } catch {
                print("error \(error)")
            }
        }
        /// Create the audio player objdcts for the various app sounds.  Creating them ahead of time helps reduce latency when playing them later.
        do {
            audioPlayers[1103] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: "/System/Library/Audio/UISounds/Tink.caf"))
            audioPlayers[1016] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: "/System/Library/Audio/UISounds/tweet_sent.caf"))
            audioPlayers[1050] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: "/System/Library/Audio/UISounds/ussd.caf"))
            audioPlayers[1025] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: "/System/Library/Audio/UISounds/New/Fanfare.caf"))
            audioPlayers[1108] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: "/System/Library/Audio/UISounds/photoShutter.caf"))


            for p in audioPlayers.values {
                p.prepareToPlay()
            }
        } catch let error {
            print("count not setup audio players", error)
        }
    }
    
    ///  Set the audio session to a mode where the sound will play even if the silent switch is on
    private func overrideSilentMode() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    /// Plays a chime sound indicating that a stask has completed successfully
    func success() {
        overrideSilentMode()
        successSound?.play()
    }
    
    /// Plays a thunking sound that conveys that something has gone wrong
    func error() {
        overrideSilentMode()
        errorSound?.play()
    }
    
    /// Plays a chime that indicates incremental progress
    func meh() {
        overrideSilentMode()
        mehSound?.play()
    }
    
    /// Plays a chime that indicates incremental progress
    func onTrack() {
        overrideSilentMode()
        onTrackSound?.play()
    }
    
    /// Play the specified system sound.  If the system sound has been preloaded as an audio player, then play using the AVAudioSession.  If there is no corresponding player, use the `AudioServicesPlaySystemSound` function.
    ///
    /// - Parameter id: the id of the system sound to play
    func playSystemSound(id: Int) {
        overrideSilentMode()
        guard let player = audioPlayers[id] else {
            // fallback on system sounds
            AudioServicesPlaySystemSound(SystemSoundID(id))
            return
        }
        player.play()
    }
}
