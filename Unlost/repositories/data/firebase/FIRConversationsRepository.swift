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
    
    //TODO: REWRITE FUNCTION TO AVOID RELOADING BUGS
    func getConversations() {
        if let userID = Auth.auth().currentUser?.uid {
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
                            //TODO: TRY TO USE MAP INSTEAD OF A FOR-LOOP HERE
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
    
    //TODO: IMPLEMENT COMPLETION HANDLERS
    //TODO: ENROLL TO APPLE DEVELOPER PROGRAM TO IMPLEMENT NOTIFICATIONS BEHAVIOR
    func addConversation(qrID: (String, String), location: Location, _ completionHandler: @escaping (Bool) -> Void) {
        
        let convDict: [String: Any] = [
            "lost_item_id": qrID.0+":"+qrID.1
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
        } else {
            completionHandler(false)
        }
    }
    
    func resetConversations() {
        self.conversations = []
    }
    
    
}
