//
//  TextMessage.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import Foundation

final class TextMessage: Message {
    var body: String
    
    init(id: String, isReceived: Bool, timestamp: Date, body: String){
        self.body = body
        super.init(id: id, isReceived: isReceived, timestamp: timestamp)
    }
    
    #if DEBUG
    static let example = TextMessage(id: "ID",
                                     isReceived: false,
                                     timestamp: Date.now,
                                     body: "My Text Message !")
    #endif
}
