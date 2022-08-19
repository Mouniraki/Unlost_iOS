//
//  AudioMessage.swift
//  Unlost
//
//  Created by Mounir Raki on 15.07.22.
//

import Foundation

final class AudioMessage: Message {
    let audioUrl: URL
    
    init(id: String, isReceived: Bool, timestamp: DateTime, audioUrl: URL) {
        self.audioUrl = audioUrl
        super.init(id: id, isReceived: isReceived, timestamp: timestamp)
    }
    
    static func fromMessage(message: Message, audioUrl: URL) -> AudioMessage {
        return AudioMessage(id: message.id,
                            isReceived: message.isReceived,
                            timestamp: message.timestamp,
                            audioUrl: audioUrl)
    }
    
    #if DEBUG
    static let example = AudioMessage(id: "ID",
                                     isReceived: false,
                                     timestamp: DateTime.fromAppleDate(from: Date.now),
                                     audioUrl: Bundle.main.url(forResource: "Tada-sound", withExtension: ".mp3")!)
    #endif
}
