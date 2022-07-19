//
//  AudioMessage.swift
//  Unlost
//
//  Created by Mounir Raki on 15.07.22.
//

import Foundation

final class AudioMessage: Message {
    //TODO: ADD AUDIO ATTRIBUTE
    let audioUrl: URL
    
    init(id: String, isReceived: Bool, timestamp: Date, audioUrl: URL) {
        self.audioUrl = audioUrl
        super.init(id: id, isReceived: isReceived, timestamp: timestamp)
    }
    
    #if DEBUG
    static let example = AudioMessage(id: "ID",
                                     isReceived: false,
                                     timestamp: Date.now,
                                      audioUrl: Bundle.main.url(forResource: "Tada-sound", withExtension: ".mp3")!)
    #endif
}
