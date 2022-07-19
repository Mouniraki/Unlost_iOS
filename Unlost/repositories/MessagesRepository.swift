//
//  MessageRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 14.07.22.
//

import Foundation
import UIKit
import CoreLocation

class MessagesRepository: ObservableObject {
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId = ""
    
    init(){
        getMessages()
    }
    
    func getMessages() {
        self.messages = [
            LocationMessage(id: "MESSAGE4",
                      isReceived: true,
                      timestamp: Date(timeIntervalSince1970: TimeInterval(1657629594)),
                      coordinates: Location(
                        latitude: 46.53408101245577,
                        longitude: 6.585174513492525)),
            
            PicMessage(id: "MESSAGE3",
                      isReceived: true,
                      timestamp: Date(timeIntervalSince1970: TimeInterval(1657629534)),
                       image: UIImage(named: "all-out-donuts-thumb")!),
            
            TextMessage(id: "MESSAGE1",
                    isReceived: false,
                    timestamp: Date(timeIntervalSince1970: TimeInterval(1657629414)),
                    body: "Hello my people !"),
            
            PicMessage(id: "MESSAGE5",
                      isReceived: false,
                      timestamp: Date(timeIntervalSince1970: TimeInterval(1657629700)),
                       image: UIImage(named: "all-out-donuts-thumb")!),
            
            
            TextMessage(id: "MESSAGE2",
                    isReceived: true,
                    timestamp: Date(timeIntervalSince1970: TimeInterval(1657629474)),
                    body: "Hi dude what are you doing ?")
            
//            AudioMessage(id: "MESSAGE6",
//                        isReceived: true,
//                        timestamp: Date(timeIntervalSince1970: TimeInterval(1657629800)),
//                         audioUrl: AudioMessage.example.audioUrl)
        ]
        
        self.messages.sort{ $0.timestamp < $1.timestamp }
        
        if let id = self.messages.last?.id {
            self.lastMessageId = id
        }
    }
    
    func sendMessage(message: Message) {
        self.messages.append(message)
        self.lastMessageId = message.id
    }
}
