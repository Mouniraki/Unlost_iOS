//
//  Item.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import Foundation
import CoreLocation

enum ItemType: Int, CaseIterable, CustomStringConvertible {
    case Wallet, Headphones, Keys, Phone
    
    var description: String {
        switch self {
        case .Wallet:
            return "Wallet"
        case .Phone:
            return "Phone"
        case .Keys:
            return "Keys"
        case .Headphones:
            return "Headphones"
        }
    }
    
    static func getItemTypeFromID(id: Int) -> ItemType {
        return ItemType.allCases[id]
    }
}

struct Item: Identifiable, Equatable {
    var id: String
    var name: String
    var description: String
    var type: ItemType
    var lastLocation: Location?
    var isLost: Bool
    
    #if DEBUG
    static let example = Item(id: "ITEMDEMO",
                              name: "AirPods",
                              description: "My AirPods Pro 2",
                              type: ItemType.Headphones,
                              lastLocation: Location(latitude: 51.507222, longitude: -0.1275),
                              isLost: true)
    #endif
    
    /**
     Returns the correct icon given the item type.
     */
    func getRelatedIconType(itemType: ItemType) -> String {
        switch itemType {
            case .Wallet:
                return "wallet.pass"
            case .Phone:
                return "iphone"
            case .Keys:
                return "key"
            case .Headphones:
                return "headphones"
        }
    }
}


