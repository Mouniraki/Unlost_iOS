//
//  FIRConversationsRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 01.08.22.
//

import Foundation
import Firebase

final class FIRConversationsRepository: ConversationsRepository {
    private let db = Firestore.firestore()
    
    @Published private(set) var conversations: [Conversation] = []
    
    func getConversations() {
        self.resetConversations()
        
        if let userID = Auth.auth().currentUser?.uid {
            db.collection("Users")
                .document(userID)
                .collection("Conv_Refs")
                .addSnapshotListener { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("Error while fetching conversation references")
                        return
                    }
                    
                    for convref in snapshot.documents {
                        self.db.collection("Conversations")
                            .document(convref.documentID)
                            .getDocument { conversation, error in
                                guard let conversation = conversation else {
                                    print("Error while fetching conversation")
                                    return
                                }
                                
                                let data = conversation.data()
                                // EACH CONVERSATION ID IS THE CONCATENATION OF BOTH THE CURRENT USERID & THE INTERLOCUTOR ID
                                let convIDPrefix = conversation.documentID.prefix(userID.count)
                                let interlocutorID = String(convIDPrefix == userID ? conversation.documentID.suffix(userID.count) : convIDPrefix)
                                
                                FIRUserRepository().getUser(userID: interlocutorID) { user in
                                    if let convUser = user {
                                        // EACH ITEM ID CONTAINS THE USER ID & ITEM ID SEPARATED BY A ":"
                                        let itemID = (data!["lost_item_id"] as! String).split(separator: ":")
                                        let isMyItem = itemID[0] == userID
                                        
                                        FIRItemsRepository().getItem(userID: String(itemID[0]), itemID: String(itemID[1])){ item in
                                            if let convItem = item {
                                                self.conversations.append(
                                                    Conversation(id: conversation.documentID,
                                                                 user: convUser,
                                                                 item: convItem,
                                                                 isMyItem: isMyItem)
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
        }
    }
    
    //TODO: IMPLEMENT COMPLETION HANDLERS
    //TODO: ENROLL TO APPLE DEVELOPER PROGRAM TO SOLVE ERRORS
    func addConversation(qrID: (String, String), location: Location, _ completionHandler: @escaping (Bool) -> Void) {
        
        let convDict: [String: Any] = [
            "lost_item_id": qrID.0+":"+qrID.1 as String
        ]
        
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { result, error in
                guard result != nil else {
                    print("Error while signing in anonymously")
                    completionHandler(false)
                    return
                }
                
                let userID = result!.user.uid
                let convID = String(userID+qrID.0)
                
                // IF NOT, WE FIRST ADD CONVERSATION TO CONVERSATIONS COLLECTION
                self.db.collection("Conversations")
                    .document(convID)
                    .setData(convDict) { err in
                        if err != nil {
                            completionHandler(false)
                            return
                        }
                        
                        // THEN ADD CONVREFERENCE TO NON-ANONYMOUS USER ONLY
                        self.db.collection("Users")
                            .document(qrID.0)
                            .collection("Conv_Refs")
                            .document(convID)
                            .setData([:]) { err in
                                if err != nil {
                                    completionHandler(false)
                                    return
                                }
                            }
                                        
                        // FINALLY UPDATE THE LAST ITEM LOCATION
                        self.db.collection("Users")
                            .document(qrID.0)
                            .collection("Items")
                            .document(qrID.1)
                            .updateData(["last_location": location.toFIRGeopoint()]) { err in
                                if err != nil {
                                    completionHandler(false)
                                    return
                                }
                            }
                        
                        
                        if (try? Auth.auth().signOut()) == nil {
                            completionHandler(false)
                        } else {
                            completionHandler(true)
                        }
                        return
                    }
            }
        } else {
            let userID = Auth.auth().currentUser!.uid
            
            // FIRST WE CHECK IF A CONVERSATION ALREADY EXISTS
            let convIDs = [userID+qrID.0, qrID.0+userID]
            var exists = false
            for convID in convIDs {
                self.db.collection("Conversations")
                    .document(convID)
                    .getDocument { document, error in
                        if let document = document, document.exists {
                            exists = true
                        }
                    }
            }
            
            if exists {
                completionHandler(false)
                return
            }
            
            // IF NOT, WE FIRST ADD CONVERSATION TO CONVERSATIONS COLLECTION
            self.db.collection("Conversations")
                .document(convIDs[0])
                .setData(convDict)
            
            // THEN ADD CONVREFERENCE TO BOTH USERS
            self.db.collection("Users")
                .document(userID)
                .collection("Conv_Refs")
                .document(convIDs[0])
                .setData([:])
            
            self.db.collection("Users")
                .document(qrID.0)
                .collection("Conv_Refs")
                .document(convIDs[0])
                .setData([:])
            
            // FINALLY UPDATE THE LAST ITEM LOCATION
            self.db.collection("Users")
                .document(qrID.0)
                .collection("Items")
                .document(qrID.1)
                .updateData(["last_location": location.toFIRGeopoint()])
            
            completionHandler(true)
        }
    }
    
    func removeConversation(at offsets: IndexSet, _ completionHandler: @escaping (Bool) -> Void) {
        if let userID = Auth.auth().currentUser?.uid {
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
        }
    }
    
    func resetConversations() {
        self.conversations = []
    }
    
    
}
