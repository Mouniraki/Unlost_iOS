//
//  FIRConversationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 01.08.22.
//

import Foundation
import Firebase

final class FIRConversationsRepository: ConversationsRepository {
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    @Published private(set) var conversations: [Conversation] = []
    
    //TODO: REWRITE FUNCTION TO AVOID RELOADING BUGS
    func getConversations() {
        if let userID = auth.currentUser?.uid {
            self.db.collection("Users")
                .document(userID)
                .collection("Conv_Refs")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("ERROR: unable to retrieve conversation references")
                        return
                    }
                    
                    Task {
                        do {
                            //TODO: TRY TO USE MAP INSTEAD OF A FOR-LOOP HERE (MAP CONFLICTS WITH ASYNC CODE)
                            var list: [Conversation] = []
                            for convref in snapshot.documents {
                                let conversation = try await self.db.collection("Conversations").document(convref.documentID).getDocument()
                                let data = conversation.data()
                                // EACH CONVERSATION ID IS THE CONCATENATION OF BOTH THE CURRENT USERID & THE INTERLOCUTOR ID
                                let convIDPrefix = conversation.documentID.prefix(userID.count)
                                let interlocutorID = String(convIDPrefix == userID ? conversation.documentID.suffix(userID.count) : convIDPrefix)
                                let user = await FIRUserRepository().getUser(userID: interlocutorID)
                                
                                let itemID = (data!["lost_item_id"] as! String).split(separator: ":")
                                let isMyItem = itemID[0] == userID
                                let item = await FIRItemsRepository().getItem(userID: String(itemID[0]), itemID: String(itemID[1]))
                                
                                if user != nil && item != nil {
                                    list.append(
                                        Conversation(id: convref.documentID,
                                                     user: user!,
                                                     item: item!,
                                                     isMyItem: isMyItem)
                                    )
                                }
                            }
                            self.conversations = list
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
        }
    }
    
    //TODO: ENROLL TO APPLE DEVELOPER PROGRAM TO IMPLEMENT NOTIFICATIONS BEHAVIOR
    func addConversation(qrID: String, location: Location, _ completionHandler: @escaping (Bool) -> Void) {
        let (ownerID, itemID): (String, String) = extractTuple(array: qrID.split(separator: ":").map {substr in String(substr)})
        
        let convDict: [String: Any] = [
            "lost_item_id": qrID
        ]
        
        if auth.currentUser == nil {
            auth.signInAnonymously { result, error in
                guard result != nil else {
                    print("Error while signing in anonymously")
                    completionHandler(false)
                    return
                }
                
                let userID = result!.user.uid
                let convID = String(userID+ownerID)
                
                // FIRST WE UPDATE THE LAST ITEM LOCATION
                self.db.collection("Users")
                    .document(ownerID)
                    .collection("Items")
                    .document(itemID)
                    .updateData(["last_location": location.toFIRGeopoint()]) { error in
                        guard error == nil else {
                            completionHandler(false)
                            return
                        }
                        
                        
                        // THEN ADD CONVERSATION TO CONVERSATIONS COLLECTION
                        self.db.collection("Conversations")
                            .document(convID)
                            .setData(convDict){ error in
                                guard error == nil else {
                                    completionHandler(false)
                                    return
                                }
                                
                                // FINALLY ADD CONVREFERENCE TO NON-ANONYMOUS USER ONLY
                                self.db.collection("Users")
                                    .document(ownerID)
                                    .collection("Conv_Refs")
                                    .document(convID)
                                    .setData([:]){ error in
                                        guard error == nil else {
                                            completionHandler(false)
                                            return
                                        }
                                        
//                                        // AND SEND A NOTIFICATION
//                                        //TODO: PROVIDE LIST OF DEVICES TO PING
//                                        FIRNotificationsRepository().sendNotification(title: "A user has found your item!",
//                                                                                      body: "Your item … has been found by an anonymous user !",
//                                                                                      devices: []) { success in
//                                            if !success {
//                                                completionHandler(success)
//                                            }
//                                        }
                                    }
                            }
                        
                        if (try? self.auth.signOut()) == nil {
                            completionHandler(false)
                        } else {
                            completionHandler(true)
                        }
                        return
                    }
            }
        } else {
            let userID = auth.currentUser!.uid
            // CONVERSATION IDS ARE FORMED BY CONCATENATING USER IDS IN ALPHABETICAL ORDER (CASE SENSITIVE!)
            let convID = userID < ownerID ? userID+ownerID : ownerID+userID
            
            // FIRST WE UPDATE THE LAST ITEM LOCATION
            self.db.collection("Users")
                .document(ownerID)
                .collection("Items")
                .document(itemID)
                .updateData(["last_location": location.toFIRGeopoint()]){ error in
                    guard error == nil else {
                        completionHandler(false)
                        return
                    }
                    
                    // THEN ADD CONVERSATION TO CONVERSATIONS COLLECTION
                    self.db.collection("Conversations")
                        .document(convID)
                        .setData(convDict){ error in
                            guard error == nil else {
                                completionHandler(false)
                                return
                            }
                            
                            // FINALLY ADD CONVREFERENCE TO BOTH USERS
                            self.db.collection("Users")
                                .document(ownerID)
                                .collection("Conv_Refs")
                                .document(convID)
                                .setData([:]) { error in
                                    guard error == nil else {
                                        completionHandler(false)
                                        return
                                    }
                                    
                                    
                                    self.db.collection("Users")
                                        .document(userID)
                                        .collection("Conv_Refs")
                                        .document(convID)
                                        .setData([:]) { error in
                                            guard error == nil else {
                                                completionHandler(false)
                                                return
                                            }
                                            
                                            completionHandler(true)
                                            
//                                            // AND SEND A NOTIFICATION (NOT AVAILABLE NOW)
//                                            FIRNotificationsRepository().sendNotification(title: "A user has found your item!",
//                                                                                          body: "Your item … has been found by …!",
//                                                                                          devices: []) { success in
//                                                completionHandler(success)
//                                            }
                                            
                                        }
                                }
                        }
                    
                }
        }
    }
    
    func removeConversation(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void) {
        if let userID = auth.currentUser?.uid {
            for i in offsets {
                db.collection("Users")
                    .document(userID)
                    .collection("Conv_Refs")
                    .document(conversations[i].id)
                    .delete { error in
                        if let err = error {
                            print(err.localizedDescription)
                            completionHandler(false)
                        } else {
                            completionHandler(true)
                        }
                    }
            }
        } else {
            completionHandler(false)
        }
    }
    
    func resetConversations() {
        self.conversations = []
    }
    
    
}
