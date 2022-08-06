//
//  FIRUserRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 01.08.22.
//

import Foundation
import Firebase
import FirebaseStorage

final class FIRUserRepository: UserRepository {
    private let db = Firestore.firestore()
    private let st = Storage.storage()

    @Published private(set) var user: User? = nil
    
    func getCurrentUser() {
        if let userID = Auth.auth().currentUser?.uid {
            self.getUser(userID: userID) { user in
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
                    
                    if snapshot.exists {
                        if data!["user_icon"] != nil {
                            let gsReference = self.st.reference().child(data!["user_icon"] as! String)
                            
                            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                            let localFileURL = url.appendingPathComponent("\(user).jpg")
                            
                            gsReference.write(toFile: localFileURL) { url, error in
                                if error != nil {
                                    // PERFORM ACTIONS
                                    print("Error while fetching user profile picture")
                                } else {
                                    completionHandler(
                                        User(id: snapshot.documentID,
                                            firstName: data!["first_name"] as! String,
                                            lastName: data!["last_name"] as! String,
                                            profilePicture: self.loadProfilePicture(imgUrl: url!))
                                    )
                                }
                            }
                        } else {
                            completionHandler(
                                User(id: snapshot.documentID,
                                    firstName: data!["first_name"] as! String,
                                    lastName: data!["last_name"] as! String,
                                    profilePicture: UIImage(systemName: "person.fill") ?? UIImage())
                            )
                        }
                    } else {
                        // IF THE USER DOESN'T EXIST => MOST CERTAINLY AN ANONYMOUS USER
                        completionHandler(
                            User(id: UUID().uuidString,
                                 firstName: "Anonymous",
                                 lastName: "User",
                                 profilePicture: UIImage(systemName: "person.fill") ?? UIImage())
                        )
                    }
                }
        }
    }
    
    func setNewProfilePicture(imageURL: URL, _ completionHandler: @escaping (Bool) -> Void) {
        if let user = user, let data = loadProfilePicture(imgUrl: imageURL).jpegData(compressionQuality: 0.3) {
            let FIRstoragePath = "users_assets/\(user.id)/\(user.id).jpg"
            let picReference = self.st.reference().child(FIRstoragePath)
            
            picReference.putData(data, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    completionHandler(false)
                    return
                }
                
                //TODO: FIND A WAY TO CHECK SUCCESS OF OPERATION
                self.db.collection("Users")
                    .document(user.id)
                    .updateData([
                        "user_icon": FIRstoragePath
                    ])
                
                completionHandler(true)
            }
        }
    }
    
    func resetUser() {
        self.user = nil
    }
    
    private func loadProfilePicture(imgUrl: URL) -> UIImage {
        if let imgData = try? Data(contentsOf: imgUrl), let loaded = UIImage(data: imgData) {
            return loaded
        } else {
            return UIImage(systemName: "person.fill") ?? UIImage()
        }
    }
    
}
