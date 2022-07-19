//
//  ChatMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation

struct ChatMenu: View {
    @EnvironmentObject var conversationsRepo: ConversationsRepository
    
    @State private var showSettingsSheet = false
    @State private var showQrScanSheet = false
    
    func deleteItems(at offsets: IndexSet){
        conversationsRepo.removeConversation(at: offsets)
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
            .environmentObject(ConversationsRepository())
    }
}
