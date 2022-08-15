//
//  ContentView.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation

struct ItemsMenu: View {
    @EnvironmentObject var itemsRepo: FIRItemsRepository
    
    @State private var showAddItemSheet = false
    @State private var showQrScanSheet = false
    @State private var showSettingsMenu = false
    
    @State private var showDeleteErrorAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if itemsRepo.isLoading {
                    ProgressView()
                } else {
                    if itemsRepo.items.isEmpty {
                        Text("No items in the list")
                    } else {
                        List{
                            ForEach(itemsRepo.items) { item in
                                NavigationLink(destination: ItemView(item: item)){
                                    ItemLayout(item: item)
                                }
                            }
                            .onDelete { offsets in
                                itemsRepo.removeItem(at: offsets) { success in
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
            .navigationTitle("My Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    Button {
                        showQrScanSheet.toggle()
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                    
                    Button {
                        showSettingsMenu.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    
                    Button{
                        showAddItemSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddItemView()
            }
            .sheet(isPresented: $showSettingsMenu) {
                SettingsMenu()
            }
            .sheet(isPresented: $showQrScanSheet) {
                QRScanMenu()
            }
            .alert("Unable to delete item. Check your internet connectivity and try again.", isPresented: $showDeleteErrorAlert) {
                Button("OK", role: .cancel){}
            }
        }
    }
}

struct ItemsMenu_Previews: PreviewProvider {
    static var previews: some View {
        ItemsMenu()
            .environmentObject(FIRItemsRepository())
    }
}
