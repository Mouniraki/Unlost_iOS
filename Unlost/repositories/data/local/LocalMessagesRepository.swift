//
//  FBMessagesRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation
import UIKit

final class LocalMessagesRepository: MessagesRepository {    
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""

    
    func getMessages(convID: String) {
        self.messages = [
            LocationMessage(id: "MESSAGE4",
                      isReceived: true,
                      timestamp: DateTime.fromAppleDate(from: Date(timeIntervalSince1970: TimeInterval(1657629594))),
                      coordinates: Location(
                        latitude: 46.53408101245577,
                        longitude: 6.585174513492525)),
            
            PicMessage(id: "MESSAGE3",
                       isReceived: true,
                       timestamp: DateTime.fromAppleDate(from: Date(timeIntervalSince1970: TimeInterval(1657629534))),
                       imageURL: PicMessage.example.imageURL),//UIImage(named: "all-out-donuts-thumb")!),
            
            TextMessage(id: "MESSAGE1",
                        isReceived: false,
                        timestamp: DateTime.fromAppleDate(from: Date(timeIntervalSince1970: TimeInterval(1657629414))),
                        body: "Hello my people !"),
            
            PicMessage(id: "MESSAGE5",
                       isReceived: false,
                       timestamp: DateTime.fromAppleDate(from: Date(timeIntervalSince1970: TimeInterval(1657629700))),
                       imageURL: PicMessage.example.imageURL),//UIImage(named: "all-out-donuts-thumb")!),
            
            TextMessage(id: "MESSAGE2",
                        isReceived: true,
                        timestamp: DateTime.fromAppleDate(from: Date(timeIntervalSince1970: TimeInterval(1657629474))),
                        body: "Hi dude what are you doing ?")
            
//            AudioMessage(id: "MESSAGE6",
//                        isReceived: true,
//                        timestamp: Date(timeIntervalSince1970: TimeInterval(1657629800)),
//                         audioUrl: AudioMessage.example.audioUrl)
        ].sorted { $0.timestamp < $1.timestamp }
        
        if let id = self.messages.last?.id {
            self.lastMessageId = id
        }
        
//        completionHandler(true)
    }
    
    func sendMessage(convID: String, message: Message, _ completionHandler: @escaping (Bool) -> Void) {
        self.messages.append(message)
        self.lastMessageId = message.id
        
        completionHandler(true)
    }
    
    func resetMessages() {
        self.messages = []
    }
}
