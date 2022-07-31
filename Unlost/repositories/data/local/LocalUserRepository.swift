//
//  LocalUserRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation
import UIKit

final class LocalUserRepository: UserRepository {    
    private(set) var signedInUserID: String? = "MYUSERID"
    
    @Published private(set) var user: User? = nil
    
    init() {
        getUser(userID: signedInUserID) { user in
            self.user = user
        }
    }
    
    func getUser(userID: String?, _ completionHandler: @escaping (User?) -> Void) {
        completionHandler(
            User(id: "USER1",
                 firstName: "Mounir",
                 lastName: "Raki",
                 profilePicture: UIImage(systemName: "person.fill") ?? UIImage())
        )
    }
    
    func setNewProfilePicture(uiImage: UIImage, _ completionHandler: @escaping (Bool) -> Void) {
        self.user?.profilePicture = uiImage
        completionHandler(true)
    }
    
    
}
