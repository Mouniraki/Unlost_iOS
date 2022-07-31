//
//  FBMessagesRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation
import UIKit

final class LocalMessagesRepository: MessagesRepository {
    private(set) var signedInUserID: String? = "MYUSERID"
    
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    
    init(){
        getMessages(convID: "DUMMYCONVID")
    }
    
    func getMessages(convID: String) {
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
        
//        completionHandler(true)
    }
    
    func sendMessage(convID: String, message: Message, _ completionHandler: @escaping (Bool) -> Void) {
        self.messages.append(message)
        self.lastMessageId = message.id
        
        completionHandler(true)
    }
}
