//
//  RawConversationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation

protocol ConversationsRepository: ObservableObject {    
    func getConversations()
    
    func addConversation(qrID: (String, String), _ completionHandler: @escaping (Bool) -> Void)
    
    func removeConversation(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void)
}
