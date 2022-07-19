//
//  Conversation.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import Foundation
import CoreLocation
import UIKit

struct Conversation: Identifiable {
    var id: String
    var user: User
    var item: Item
    var isMyItem: Bool
    
    #if DEBUG
    static let example = Conversation(id: "CONVID",
                                      user: User(id: "MOUNIRUSER",
                                                firstName: "Mounir",
                                                lastName: "Raki",
                                                profilePicture: UIImage(named: "all-out-donuts-thumb")!),
                                      item: Item(id: "MOUNIRITEM1",
                                                 name: "AirPods",
                                                 description: "My AirPods Pro 2",
                                                 type: .Headphones,
                                                 lastLocation: Location(
                                                    latitude: 46.53408101245577,
                                                    longitude: 6.585174513492525
                                                 ),
                                                 isLost: true),
                                      isMyItem: true)
    #endif
}
