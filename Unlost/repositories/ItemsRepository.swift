//
//  ItemsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 15.07.22.
//

import Foundation
import CoreLocation

class ItemsRepository: ObservableObject {
    @Published private(set) var items: [Item] = []
    
    init() {
        getItems()
    }
    
    func findItemInList(item: Item) -> Int{
        for i in 0..<items.count {
            if items[i].id == item.id {
                return i
            }
        }
        return -1
    }
    
    func getItems() {
        self.items = [
            Item(id: "MOUNIRITEM1",
                 name: "AirPods",
                 description: "AirPods Pro 2",
                 type: .Headphones,
                 lastLocation: Location(
                    latitude: 46.53408101245577,
                    longitude: 6.585174513492525
                 ),
                 isLost: false),
            
            Item(id: "MOUNIRITEM2",
                 name: "Phone",
                 description: "iPhone 12 White",
                 type: .Phone,
                 lastLocation: Location(
                    latitude: 46.17910312375929,
                    longitude: 6.079325756211649
                 ),
                 isLost: true),
            
            Item(id: "MOUNIRITEM3",
                 name: "Car Keys",
                 description: "Ferrari F8 Tributo",
                 type: .Keys,
                 lastLocation: Location(
                    latitude: 47.4071290165756,
                    longitude: 8.505438908933309
                 ),
                 isLost: true),
            
            Item(id: "MOUNIRITEM4",
                 name: "Wallet",
                 description: "With all my belongings",
                 type: .Wallet,
                 lastLocation: Location(
                    latitude: 51.507222,
                    longitude: -0.1275
                 ),
                 isLost: false)
        ]
    }
    
    func addItem(item: Item) {
        self.items.append(item)
    }
    
    func removeItem(at offsets: IndexSet) {
        self.items.remove(atOffsets: offsets)
    }
    
}
