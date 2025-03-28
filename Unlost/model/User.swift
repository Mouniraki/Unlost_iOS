//
//  User.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import Foundation
import UIKit

struct User: Identifiable {
    var id: String
    var firstName: String
    var lastName: String
    var profilePicture: UIImage
    
    func getFullUserName() -> String {
        return firstName + " " + lastName
    }
    
    #if DEBUG
    static let example = User(id: "EXAMPLEUSERID",
                              firstName: "Example",
                              lastName: "User",
                              profilePicture: UIImage(systemName: "person.fill") ?? UIImage())
    #endif
}
