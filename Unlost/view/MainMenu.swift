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
    
    var body: some View {        
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
            .environmentObject(FIRItemsRepository())
            .environmentObject(LocalConversationsRepository())
            .environmentObject(GoogleSignInRepo())
    }
}
