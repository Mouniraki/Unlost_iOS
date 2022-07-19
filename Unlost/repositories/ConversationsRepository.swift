//
//  ConversationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 15.07.22.
//

import Foundation
import UIKit
import CoreLocation

class ConversationsRepository: ObservableObject {
    @Published private(set) var conversations: [Conversation] = []
    
    init() {
        getConversations()
    }
    
    
    func getConversations() {
        self.conversations = [
            Conversation(
                id: "USER:MOUNIR",
                user: User(id: "MOUNIRUSER",
                          firstName: "Mounir",
                          lastName: "Raki",
                          profilePicture: UIImage(named: "all-out-donuts-thumb")!),
                item: Item(id: "MOUNIRITEM1",
                           name: "AirPods",
                           description: "My AirPods Pro 2",
                           type: .Headphones,
                           lastLocation: Location(latitude: 46.53408101245577,
                                                    longitude: 6.585174513492525),
                           isLost: true),
                isMyItem: true
            ),
            
            Conversation(
                id: "USER:OMAR",
                user: User(id: "OMARUSER",
                          firstName: "Omar",
                          lastName: "El Malki",
                           profilePicture: UIImage(named: "all-out-donuts-thumb")!),
                item: Item(id: "OMARITEM1",
                           name: "Wallet",
                           description: "With all my belongings",
                           type: .Wallet,
                           lastLocation: Location(latitude: 46.53408101245577,
                                                    longitude: 6.585174513492525),
                           isLost: true),
                isMyItem: false
            )
        ]
    }
    
    func addConversation(conversation: Conversation, _ completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.conversations.append(conversation)
            completionHandler(true)
        }
    }
    
    func removeConversation(at offsets: IndexSet) {
        self.conversations.remove(atOffsets: offsets)
    }
    
}
