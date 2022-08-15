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
    private let auth = Auth.auth()
    
    @Published var isSignedIn = Auth.auth().currentUser != nil
    @Published private(set) var signedInUserID: String? = Auth.auth().currentUser?.uid
    
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
            auth.signIn(with: credential) { result, error in
                if let err = error {
                    print(err.localizedDescription)
                    completionHandler(false)
                    return
                }
                
                guard let authUser = result?.user else {
                    completionHandler(false)
                    return
                }
                
                // IF USER ISNT PRESENT IN FIRESTORE => ADD A NEW ENTRY
                let db = Firestore.firestore().collection("Users").document(authUser.uid)
                
                db.getDocument { snapshot, error in
                    guard snapshot != nil, snapshot!.exists else {
                        let userDict: [String: Any] = [
                            "first_name": user!.profile!.givenName!, //TODO: FIND HOW TO SPLIT FIRSTNAME & LASTNAME
                            "last_name": user!.profile!.familyName!
                        ]
                            
                        db.setData(userDict)
                        return
                    }
                    
                    self.isSignedIn = self.auth.currentUser?.uid != nil
                    self.signedInUserID = self.auth.currentUser?.uid
                    completionHandler(true)
                }
            }
        }
    }
    
    func signOut(_ completionHandler: @escaping (Bool) -> Void) {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
            self.isSignedIn = auth.currentUser?.uid != nil // MUST BE FALSE, SINCE WE SIGNED OUT
            self.signedInUserID = auth.currentUser?.uid
            completionHandler(true)
        } catch {
            print(error.localizedDescription)
            completionHandler(false)
        }
    }
}


