//
//  AudioManager.swift
//  Unlost
//
//  Created by Mounir Raki on 17.07.22.
//

import Foundation
import AVKit

final class AudioPlayer: ObservableObject {
    @Published var player: AVAudioPlayer?
    
    func setUpAudioPlayer(url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func playPauseAudio(url: URL, isPlaying: Bool){
        if player?.url != url {
            setUpAudioPlayer(url: url)
        }
        
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
    }
}
