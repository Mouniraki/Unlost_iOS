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
    
    @State private var showDeleteErrorAlert = false
    
    var body: some View {
        NavigationView{
            ZStack {
                if conversationsRepo.isLoading {
                    ProgressView()
                } else {
                    if conversationsRepo.conversations.isEmpty {
                        Text("No conversations in the list")
                    } else {
                        List{
                            ForEach(conversationsRepo.conversations) { conversation in
                                NavigationLink(destination: ChatView(conversation: conversation)){
                                    ChatEntryLayout(conversation: conversation)
                                }
                            }
                            .onDelete{ offsets in
                                conversationsRepo.removeConversation(at: offsets) { success in
                                    if !success {
                                        showDeleteErrorAlert.toggle()
                                    }
                                }
                            }
                        }
                        .listStyle(.grouped)
                    }
                }
            }
            .navigationTitle("My Chats")
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
            .alert("Unable to remove conversations. Check your internet connectivity and try again.", isPresented: $showDeleteErrorAlert) {
                Button("OK", role: .cancel){}
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
