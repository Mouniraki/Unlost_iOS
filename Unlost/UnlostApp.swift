//
//  UnlostApp.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI

@main
struct UnlostApp: App {
    @StateObject var itemsRepo = ItemsRepository()
    @StateObject var conversationsRepo = ConversationsRepository()
    @StateObject var userRepo = UserRepository()
    @StateObject var signInRepo = LocalSignInRepo()
    
    var body: some Scene {
        WindowGroup {
            MainMenu()
                .environmentObject(itemsRepo)
                .environmentObject(conversationsRepo)
                .environmentObject(userRepo)
                .environmentObject(signInRepo)
        }
    }
}
