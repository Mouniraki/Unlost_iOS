//
//  ChatMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation

struct ChatMenu: View {
    @EnvironmentObject var conversationsRepo: FIRConversationsRepository
    @EnvironmentObject var userRepo: FIRUserRepository
    @EnvironmentObject var itemsRepo: FIRItemsRepository
    
    @State private var showSettingsSheet = false
    @State private var showQrScanSheet = false
    
    //TODO: REPLACE USER ID BY ACTUAL UID
    func deleteItems(at offsets: IndexSet){
        conversationsRepo.removeConversation(at: offsets){
            success in
            //TODO: INSERT CODE HERE
        }
    }
    
    var body: some View {
        NavigationView{
            List{
                ForEach(conversationsRepo.conversations) { conversation in
                    NavigationLink(destination: ChatView(conversation: conversation)){
                        ChatEntryLayout(conversation: conversation)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("My Chats")
            .listStyle(.grouped)
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button {
                        showSettingsSheet.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem {
                    Button {
                        showQrScanSheet.toggle()
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }
            
            .sheet(isPresented: $showSettingsSheet) {
                SettingsMenu()
            }
            .sheet(isPresented: $showQrScanSheet) {
                QRScanMenu()
            }
        }
    }
}

struct ChatMenu_Previews: PreviewProvider {
    static var previews: some View {
        ChatMenu()
            .environmentObject(FIRConversationsRepository())
            .environmentObject(FIRUserRepository())
            .environmentObject(FIRItemsRepository())
    }
}
