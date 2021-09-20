//
//  MusicBox.swift
//  DogWalk
//
//  Created by Christian Selig on 2021-08-24.
//

import AVFoundation

/// 🪗
class MusicBox: NSObject, AVAudioPlayerDelegate {
    enum MusicBoxMusic {
        case bork, pant, unlocked, unlockedAll
        
        var fileName: String {
            switch self {
            case .bork:
                return "bork"
            case .pant:
                return "pant"
            case .unlocked:
                return "unlocked"
            case .unlockedAll:
                return "all-unlocked"
            }
        }
        
        var isLoud: Bool {
            switch self {
            case .bork:
                /// Replicate the experience of your own dog barking at a potentially surprising time
                return true
            case .pant, .unlocked, .unlockedAll:
                return false
            }
        }

    }
    
    static let shared = MusicBox()
    
    /// Need to keep strong reference in order for audio to play
    private var player: AVAudioPlayer?
    
    func play(music: MusicBoxMusic) {
        guard let soundURL = Bundle.main.url(forResource: music.fileName, withExtension: "mp3") else { fatalError("Passed bad music") }
        guard let player = try? AVAudioPlayer(contentsOf: soundURL, fileTypeHint: AVFileType.mp3.rawValue) else { fatalError("Could not create audio player") }
        
        if music.isLoud {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            } catch {
                print(error)
            }
        }
        
        player.delegate = self
        player.play()
        
        self.player = player
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Restore prior audio session category (iOS default is .soloAmbient)
        try? AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options: [])
    }
}
