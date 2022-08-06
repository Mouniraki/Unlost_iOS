//
//  RawMessagesRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation

//TODO: ADD COMPLETIONHANDLER FOR GET
protocol MessagesRepository: ObservableObject {
    func getMessages(convID: String)
    
    func sendMessage(convID: String, message: Message, _ completionHandler: @escaping (Bool) -> Void)
    
    //TODO: FIGURE OUT IF THIS IS NEEDED OR NOT
    func resetMessages()
}
