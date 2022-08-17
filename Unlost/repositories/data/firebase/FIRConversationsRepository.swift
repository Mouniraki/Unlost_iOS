//
//  FIRConversationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 01.08.22.
//

import Foundation
import Firebase
import FirebaseDatabase

final class FIRConversationsRepository: ConversationsRepository {
    private let auth = Auth.auth()
    private let fs = Firestore.firestore()
    
    @Published private(set) var conversations: [Conversation] = []
    @Published private(set) var isLoading: Bool = false
    
    //TODO: REWRITE FUNCTION TO AVOID RELOADING BUGS
    func getConversations() {
        if let userID = auth.currentUser?.uid {
            self.isLoading = true
            self.fs.collection("Users")
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
                                let conversation = try await self.fs.collection("Conversations").document(convref.documentID).getDocument()
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
                            self.isLoading = false
                        } catch {
                            print(error.localizedDescription)
                            self.isLoading = false
                        }
                    }
                }
        }
    }
    
    //TODO: ENROLL TO APPLE DEVELOPER PROGRAM TO IMPLEMENT NOTIFICATIONS BEHAVIOR
    func addConversation(qrID: String, location: Location, _ completionHandler: @escaping (Bool) -> Void) {
        
        let (ownerID, itemID): (String, String) = extractTuple(array: qrID.split(separator: ":").map {substr in String(substr)})
        
        // ANONYMOUSLY CREATE CONVERSATION
        if auth.currentUser == nil {
            auth.signInAnonymously { result, error in
                guard result != nil else {
                    print("Error while signing in anonymously")
                    completionHandler(false)
                    return
                }
                
                let userID = result!.user.uid
                let convID = userID < ownerID ? userID+ownerID : ownerID+userID
                
                self.performActions(ownerID: ownerID, itemID: itemID, convID: convID, location: location) { success in
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
            let convID = userID < ownerID ? userID+ownerID : ownerID+userID
            
            self.performActions(ownerID: ownerID, itemID: itemID, convID: convID, location: location) { success in
                if success {
                    self.fs.collection("Users")
                        .document(userID)
                        .collection("Conv_Refs")
                        .document(convID)
                        .setData([:]) { error in
                            guard error == nil else {
                                completionHandler(false)
                                return
                            }
                            
                            completionHandler(true)
                            
                        }
                } else {
                    completionHandler(false)
                    return
                }
            }
            
        }
    }
    
    
    private func performActions(ownerID: String, itemID: String, convID: String, location: Location, _ completionHandler: @escaping (Bool) -> Void) {
        let convDict: [String: Any] = [
            "lost_item_id": ownerID+":"+itemID
        ]
        
        // FIRST WE CHECK IF THE OWNER & ITS ITEM EXIST
        self.fs.collection("Users")
            .document(ownerID)
            .collection("Items")
            .document(itemID)
            .getDocument { snapshot, error in
                guard let snapshot = snapshot,
                        snapshot.exists == true
                else {
                    completionHandler(false)
                    return
                }
                
                // THEN WE UPDATE THE LAST LOCATION OF THE ITEM
                self.fs.collection("Users")
                    .document(ownerID)
                    .collection("Items")
                    .document(itemID)
                    .updateData(["last_location": location.toFIRGeopoint()]) { error in
                        guard error == nil else {
                            completionHandler(false)
                            return
                        }
                        
                        // THEN ADD CONVERSATION TO CONVERSATIONS COLLECTION
                        self.fs.collection("Conversations")
                            .document(convID)
                            .setData(convDict){ error in
                                guard error == nil else {
                                    completionHandler(false)
                                    return
                                }
                                
                                // FINALLY ADD CONVREFERENCE TO NON-ANONYMOUS USER ONLY
                                self.fs.collection("Users")
                                    .document(ownerID)
                                    .collection("Conv_Refs")
                                    .document(convID)
                                    .setData([:]){ error in
                                        guard error == nil else {
                                            completionHandler(false)
                                            return
                                        }
                                        
        //                                // SEND A NOTIFICATION (NOT AVAILABLE NOW)
        //                                FIRNotificationsRepository().sendNotification(title: "A user has found your item!",
        //                                                                              body: "Your item … has been found by …!",
        //                                                                              devices: []) { success in
        //                                    completionHandler(success)
        //                                }
                                        
                                        completionHandler(true)
                                    }
                            }
                    }
                
            }
        

    }
    
    
    
    func removeConversation(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void) {
        if let userID = auth.currentUser?.uid {
            for i in offsets {
                fs.collection("Users")
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
