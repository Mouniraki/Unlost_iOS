//
//  PicMessage.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import UIKit
import Foundation

final class PicMessage: Message {
    var imageURL: URL
    
    init(id: String, isReceived: Bool, timestamp: DateTime, imageURL: URL){
        self.imageURL = imageURL
        super.init(id: id, isReceived: isReceived, timestamp: timestamp)
    }
    
    static func fromMessage(message: Message, imageURL: URL) -> PicMessage {
        return PicMessage(id: message.id,
                          isReceived: message.isReceived,
                          timestamp: message.timestamp,
                          imageURL: imageURL)
    }
    
    #if DEBUG
    static let example = PicMessage(id: "ID",
                                    isReceived: false,
                                    timestamp: DateTime.fromAppleDate(from: Date.now),
                                    imageURL: Bundle.main.url(forResource: "picimage", withExtension: ".jpg")!)
    #endif
}
