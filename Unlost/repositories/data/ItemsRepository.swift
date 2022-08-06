//
//  RawItemsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation

//TODO: ADD COMPLETIONHANDLER FOR GET
protocol ItemsRepository: ObservableObject {    
    func getItems()
    
    func getItem(userID: String, itemID: String, _ completionHandler: @escaping (Item?) -> Void)
    
    func addItem(item: Item, _ completionHandler: @escaping (Bool) -> Void)
    
    func removeItem(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void)
    
    func resetItems()
}

extension ItemsRepository {
    func findItemInList(items: Array<Item>, item: Item) -> Int {
        for i in 0..<items.count {
            if items[i].id == item.id {
                return i
            }
        }
        return -1
    }
}
