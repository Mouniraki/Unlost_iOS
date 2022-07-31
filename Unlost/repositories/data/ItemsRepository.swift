//
//  RawItemsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation

protocol ItemsRepository: ObservableObject {    
    func getItems()
    
    func addItem(item: Item, _ completionHandler: @escaping (Bool) -> Void)
    
    func removeItem(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void)
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
