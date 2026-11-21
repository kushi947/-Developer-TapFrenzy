//
//  AudioManager.swift
//  TapFrenzy
//
//  Created by COBSCCOMP252P-119-G6 on 2026-11-21.
//


import Foundation
import AVFoundation

class AudioManager {

    static let shared = AudioManager()

    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        print("Audio Manager initialized")
    }

    // Load audio files
    func loadSound(_ name: String) {

        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "wav"
        ) else {

            print("ERROR: Cannot find \(name).wav")
            return
        }

        do {

            let player = try AVAudioPlayer(contentsOf: url)

            player.volume = 1.0
            player.prepareToPlay()

            players[name] = player

            print("SUCCESS: \(name).wav loaded")

        } catch {

            print("Audio loading error: \(error)")
        }
    }

    // Play audio
    func play(_ name: String) {

        guard let player = players[name] else {

            print("ERROR: \(name) is not loaded")
            return
        }

        player.currentTime = 0
        player.play()
    }

    // Stop audio
    func stop(_ name: String) {

        players[name]?.stop()
    }
}
