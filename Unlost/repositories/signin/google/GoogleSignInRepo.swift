//
//  GoogleSignInRepo.swift
//  Unlost
//
//  Created by Mounir Raki on 31.07.22.
//

import Foundation
import Firebase
import GoogleSignIn

final class GoogleSignInRepo: SignInRepository {
    @Published var isSignedIn = false
    
    func signIn(_ completionHandler: @escaping (Bool) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completionHandler(false)
            return
        }
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            completionHandler(false)
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        
        // GOOGLE SIGN IN PART
        GIDSignIn.sharedInstance.signIn(with: config, presenting: presentingViewController) {[unowned self] user, error in
            if let err = error {
                print(err.localizedDescription)
                completionHandler(false)
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                completionHandler(false)
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            // FIREBASE AUTH PART => TO MOVE OUTSIDE
            Auth.auth().signIn(with: credential) { result, error in
                if let err = error {
                    print(err.localizedDescription)
                    completionHandler(false)
                    return
                }
                
                guard let user = result?.user else {
                    completionHandler(false)
                    return
                }
                
                print(user)
                completionHandler(true)
                self.isSignedIn = true
                
            }
        }
    }
    
    func signOut(_ completionHandler: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.isSignedIn = false
            completionHandler(true)
        } catch {
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
}


