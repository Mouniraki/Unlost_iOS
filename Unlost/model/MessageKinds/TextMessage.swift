//
//  TextMessage.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import Foundation

final class TextMessage: Message {
    var body: String
    
    init(id: String, isReceived: Bool, timestamp: DateTime, body: String){
        self.body = body
        super.init(id: id, isReceived: isReceived, timestamp: timestamp)
    }
    
    static func fromMessage(message: Message, body: String) -> TextMessage {
        return TextMessage(id: message.id,
                           isReceived: message.isReceived,
                           timestamp: message.timestamp,
                           body: body)
    }
    
    #if DEBUG
    static let example = TextMessage(id: "ID",
                                     isReceived: false,
                                     timestamp: DateTime.fromAppleDate(from: Date.now),
                                     body: "My Text Message !")
    #endif
}
