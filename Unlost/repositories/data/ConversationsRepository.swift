//
//  RawConversationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation

//TODO: ADD COMPLETIONHANDLER FOR GET
protocol ConversationsRepository: ObservableObject {    
    func getConversations()
    
    func addConversation(qrID: (String, String), location: Location, _ completionHandler: @escaping (Bool) -> Void)
    
    func removeConversation(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void)
    
    func resetConversations()

}
