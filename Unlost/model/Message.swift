//
//  Message.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import Foundation

class Message: Identifiable {
    var id: String
    var isReceived: Bool
    var timestamp: Date
    
    init(id: String, isReceived: Bool, timestamp: Date){
        self.id = id
        self.isReceived = isReceived
        self.timestamp = timestamp
    }
}
