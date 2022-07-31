//
//  FIRUserRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 01.08.22.
//

import Foundation
import Firebase

final class FIRUserRepository: UserRepository {
    private let db = Firestore.firestore()

    @Published private(set) var signedInUserID: String? = Auth.auth().currentUser?.uid
    @Published private(set) var user: User? = nil
    
    
    init() {
        if let userID = signedInUserID {
            getUser(userID: userID) { user in
                self.user = user
            }
        }
    }
    
    func getUser(userID: String?, _ completionHandler: @escaping (User?) -> Void) {
        if let user = userID {
            
            db.collection("Users")
                .document(user)
                .getDocument { snapshot, error in
                    guard let snapshot = snapshot else {
                        print("Error fetching item snapshots: \(error!)")
                        completionHandler(nil)
                        return
                    }
                    
                    let data = snapshot.data()
                    
                    // TODO: DOWNLOAD CORRECT PROFILE PICTURE AND ASSIGN IT TO USER
                    completionHandler(
                        User(id: snapshot.documentID,
                            firstName: data!["first_name"] as! String,
                            lastName: data!["last_name"] as! String,
                            profilePicture: UIImage())
                    )
                }
        }
    }
    
    func setNewProfilePicture(uiImage: UIImage, _ completionHandler: @escaping (Bool) -> Void) {
        //TODO: UPLOAD PROFILE PICTURE AND SET IT TO USER
    }
    
    
}
