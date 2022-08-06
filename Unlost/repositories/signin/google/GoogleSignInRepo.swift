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
    @Published private(set) var signedInUserID: String? = nil
    
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
                
                // IF USER ISNT PRESENT IN FIRESTORE => ADD A NEW ENTRY
                let db = Firestore.firestore().collection("Users").document(user.uid)
                
                db.getDocument { snapshot, error in
                    guard snapshot != nil else {
                        let userDict: [String: Any] = [
                            "first_name": user.displayName!, //TODO: FIND HOW TO SPLIT FIRSTNAME & LASTNAME
                            "last_name": user.displayName!
                        ]
                            
                        db.setData(userDict)
                        return
                    }
                }
                
                self.isSignedIn = Auth.auth().currentUser?.uid != nil
                self.signedInUserID = Auth.auth().currentUser?.uid
                completionHandler(true)
            }
        }
    }
    
    func signOut(_ completionHandler: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.isSignedIn = Auth.auth().currentUser?.uid != nil // MUST BE FALSE, SINCE WE SIGNED OUT
            self.signedInUserID = Auth.auth().currentUser?.uid
            completionHandler(true)
        } catch {
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
}


