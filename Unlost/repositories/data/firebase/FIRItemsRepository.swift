//
//  FIRItemsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 31.07.22.
//

import Foundation
import Firebase

final class FIRItemsRepository: ItemsRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    @Published private(set) var items: [Item] = []
    
    func getItems() {
        if let userID = auth.currentUser?.uid {
            db.collection("Users")
                .document(userID)
                .collection("Items")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("Error fetching item snapshots: \(error!)")
                        return
                    }
                    
                    self.items = snapshot.documents.map { document in
                        let data = document.data()
                        
                        return Item(id: document.documentID,
                                    name: data["item_name"] as! String,
                                    description: data["item_description"] as! String,
                                    type: ItemType.allCases[data["item_type"] as! Int],
                                    lastLocation: Location.fromFIRGeopoint(from: data["last_location"] as? GeoPoint ?? nil),
                                    isLost: data["is_lost"] as! Bool)
                    }
                }
        }
    }
    
    @MainActor
    func getItem(userID: String, itemID: String) async -> Item? {
        do {
            let snapshot = try await db.collection("Users")
                .document(userID)
                .collection("Items")
                .document(itemID)
                .getDocument()
            
            let data = snapshot.data()
            if let data = data {
                return Item(id: snapshot.documentID,
                            name: data["item_name"] as! String,
                            description: data["item_description"] as! String,
                            type: ItemType.allCases[(data["item_type"] as! Int) % 4],
                            lastLocation: Location.fromFIRGeopoint(from: data["last_location"] as? GeoPoint ?? nil),
                            isLost: data["is_lost"] as! Bool)
            } else {
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func addItem(item: Item, _ completionHandler: @escaping (Bool) -> Void) {
        if let userID = auth.currentUser?.uid {
            
            let itemDict: [String: Any] = [
                "item_name": item.name as String,
                "item_type": item.type.rawValue as Int,
                "item_description": item.description as String,
                "is_lost": item.isLost as Bool
            ]
            
            //TODO: FIND HOW TO GET THE COMPLETION STATE OF THE ADD OPERATION
            db.collection("Users")
                .document(userID)
                .collection("Items")
                .addDocument(data: itemDict)
            
            completionHandler(true)
        }
    }
    
    func removeItem(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void) {
        
        if let userID = auth.currentUser?.uid {
            for i in offsets {
                db.collection("Users")
                    .document(userID)
                    .collection("Items")
                    .document(items[i].id)
                    .delete() { error in
                        if let err = error {
                            print(err.localizedDescription)
                            completionHandler(false)
                        } else {
                            completionHandler(true)
                        }
                    }
            }
        }
    }
    
    func resetItems() {
        self.items = []
    }
    
}
