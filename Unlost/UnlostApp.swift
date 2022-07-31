//
//  UnlostApp.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

// Configuration for Firebase setup
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct UnlostApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject var messagesRepo = LocalMessagesRepository()
    @StateObject var itemsRepo = FIRItemsRepository()
    @StateObject var conversationsRepo = LocalConversationsRepository()
    @StateObject var userRepo = FIRUserRepository()
    @StateObject var signInRepo = GoogleSignInRepo()
    
    
    var body: some Scene {
        WindowGroup {
            MainMenu()
                .environmentObject(messagesRepo)
                .environmentObject(itemsRepo)
                .environmentObject(conversationsRepo)
                .environmentObject(userRepo)
                .environmentObject(signInRepo)
        }
    }
}
