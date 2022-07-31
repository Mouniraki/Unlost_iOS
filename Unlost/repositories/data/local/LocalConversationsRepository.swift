//
//  LocalConversationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation
import UIKit

final class LocalConversationsRepository: ConversationsRepository {
    private(set) var signedInUserID: String? = "MYUSERID"
    
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
        
//        completionHandler(true)
    }
    
    func addConversation(qrID: (String, String), _ completionHandler: @escaping (Bool) -> Void) {
        if let id = signedInUserID {
            let conversation = Conversation(id: id + qrID.0,
                                            user: User(id: qrID.0,
                                                       firstName: "User",
                                                       lastName: "Name",
                                                       profilePicture: UIImage(systemName: "eye")!),
                                            item: Item(id: qrID.1,
                                                       name: "MyItem",
                                                       description: "MyDesc",
                                                       type: .Keys,
                                                       isLost: true),
                                            isMyItem: false)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.conversations.append(conversation)
                completionHandler(true)
            }
        }
    }
    
    func removeConversation(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void) {
        self.conversations.remove(atOffsets: offsets)
        completionHandler(true)
    }
    
    
}
