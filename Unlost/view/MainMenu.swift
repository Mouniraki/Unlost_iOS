//
//  MainMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation

struct MainMenu: View {
    @EnvironmentObject var signInRepo: GoogleSignInRepo
    @EnvironmentObject var userRepo: FIRUserRepository
    @EnvironmentObject var convRepo: FIRConversationsRepository
    @EnvironmentObject var itemsRepo: FIRItemsRepository
    
    var body: some View {        
        if !signInRepo.isSignedIn {
            SignInMenu()
                .onAppear{
                    userRepo.resetUser()
                    itemsRepo.resetItems()
                    convRepo.resetConversations()
                }
        } else {
            TabView {
                ItemsMenu()
                    .tabItem{
                        Label("My Items", systemImage: "list.dash")
                    }

                MapMenu()
                    .tabItem{
                        Label("Map", systemImage: "map")
                    }
                        
                ChatMenu()
                    .tabItem{
                        Label("My Chats", systemImage: "message")
                    }
                }
                .onAppear{
                    userRepo.getCurrentUser()
                    convRepo.getConversations()
                    itemsRepo.getItems()
                }
            }
        }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
            .environmentObject(FIRItemsRepository())
            .environmentObject(FIRUserRepository())
            .environmentObject(FIRConversationsRepository())
            .environmentObject(GoogleSignInRepo())
    }
}
