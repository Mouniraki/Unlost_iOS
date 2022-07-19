//
//  PicMessage.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import UIKit
import Foundation

final class PicMessage: Message {
    var image: UIImage
    
    init(id: String, isReceived: Bool, timestamp: Date, image: UIImage){
        self.image = image
        super.init(id: id, isReceived: isReceived, timestamp: timestamp)
    }
    
    #if DEBUG
    static let example = PicMessage(id: "ID",
                                    isReceived: false,
                                    timestamp: Date.now,
                                    image: UIImage(named: "all-out-donuts-thumb")!)
    #endif
}
