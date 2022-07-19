//
//  UserRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 18.07.22.
//

import Foundation
import UIKit

class UserRepository: ObservableObject {
    @Published private(set) var user: User? = nil
    
    init() {
        getUser()
    }
    
    func getUser() {
        self.user = User(id: "USER1",
                         firstName: "Mounir",
                         lastName: "Raki",
                         profilePicture: UIImage(systemName: "person.fill") ?? UIImage())
    }
    
    func setNewProfilePicture(uiImage: UIImage) {
        self.user?.profilePicture = uiImage
    }
}
