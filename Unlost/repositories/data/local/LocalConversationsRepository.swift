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
    @Published private(set) var isLoading: Bool = false
    
    @Published private(set) var conversations: [Conversation] = []
    
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
    
    func addConversation(qrID: String, location: Location, _ completionHandler: @escaping (Bool) -> Void) {
        if let id = signedInUserID {
            let (ownerID, itemID) = extractTuple(array: qrID.split(separator: ":").map{substr in String(substr)})
            
            
            let conversation = Conversation(id: id + ownerID,
                                            user: User(id: ownerID,
                                                       firstName: "User",
                                                       lastName: "Name",
                                                       profilePicture: UIImage(systemName: "eye")!),
                                            item: Item(id: itemID,
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
    
    func resetConversations() {
        self.conversations = []
    }
    
    
}
