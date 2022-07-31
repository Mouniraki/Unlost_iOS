//
//  SignInRepo.swift
//  Unlost
//
//  Created by Mounir Raki on 20.07.22.
//

import Foundation

protocol SignInRepository: ObservableObject {
    //TODO: ADD ISSIGNEDIN STATE TO PROTOCOL
    func signIn(_ completionHandler: @escaping (Bool) -> Void)
    func signOut(_ completionHandler: @escaping (Bool) -> Void)
}
