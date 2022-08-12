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
    
    func getCurrentUser() {
        self.user = User(id: "USER1",
                         firstName: "Mounir",
                         lastName: "Raki",
                         profilePicture: UIImage(systemName: "person.fill") ?? UIImage())
    }
    
    func getUser(userID: String?) async -> User? {
            User(id: "USER1",
                 firstName: "Mounir",
                 lastName: "Raki",
                 profilePicture: UIImage(systemName: "person.fill") ?? UIImage())
    }
    
    func setNewProfilePicture(imageURL: URL, _ completionHandler: @escaping (Bool) -> Void) {
        self.user?.profilePicture = UIImage()
        completionHandler(true)
    }
    
    func resetUser() {
        self.user = nil
    }
    
    
}
