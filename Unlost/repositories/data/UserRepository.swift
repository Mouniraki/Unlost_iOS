//
//  RawUserRepository.swift
//  Unlost
//
//  Created by Mounir Raki on 19.07.22.
//

import Foundation
import UIKit

protocol UserRepository: ObservableObject {
    func getUser(userID: String?, _ completionHandler: @escaping (User?) -> Void)
    
    func setNewProfilePicture(uiImage: UIImage, _ completionHandler: @escaping (Bool) -> Void)
}
