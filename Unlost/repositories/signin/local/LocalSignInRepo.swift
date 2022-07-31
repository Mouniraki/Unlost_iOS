//
//  LocalSignIn.swift
//  Unlost
//
//  Created by Mounir Raki on 18.07.22.
//

import Foundation

final class LocalSignInRepo: SignInRepository {
    @Published var isSignedIn = false
    
    func signIn(_ completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let signInResult = true
            completionHandler(signInResult)
            self.isSignedIn = signInResult
        }
    }
    
    func signOut(_ completionHandler: @escaping (Bool) -> Void) {
        self.isSignedIn = false
        completionHandler(true)
    }
}
