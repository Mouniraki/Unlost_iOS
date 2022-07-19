//
//  MainMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation

struct MainMenu: View {
    @EnvironmentObject var signInRepo: LocalSignInRepo
//    @State private var performTransition = false
    
    var body: some View {
//        animation(.easeInOut, value: signInRepo.isSignedIn)
        
        if !signInRepo.isSignedIn {
            SignInMenu()
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
            }
        }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
            .environmentObject(ItemsRepository())
            .environmentObject(ConversationsRepository())
            .environmentObject(LocalSignInRepo())
    }
}
