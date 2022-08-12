//
//  RawUserRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation
import UIKit

//TODO: ADD COMPLETIONHANDLER FOR GET
protocol UserRepository: ObservableObject {
    func getCurrentUser()
    
    func getUser(userID: String?) async -> User?
    
    func setNewProfilePicture(imageURL: URL, _ completionHandler: @escaping (Bool) -> Void)
    
    func resetUser()
}
