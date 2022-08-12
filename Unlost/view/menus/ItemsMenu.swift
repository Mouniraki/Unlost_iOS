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
    
    /**
     Removes items at given offsets.
     */
    func deleteItems(at offsets: IndexSet){ // TODO: MOVE THIS TO VIEWMODEL CLASS
        itemsRepo.removeItem(at: offsets) { success in
            //TODO: INSERT CODE HERE
        }
    }
    
    var body: some View {
        NavigationView {
            List{
                ForEach(itemsRepo.items) { item in
                    NavigationLink(destination: ItemView(item: item)){
                        ItemLayout(item: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(.grouped)
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
        }
    }
}

struct ItemsMenu_Previews: PreviewProvider {
    static var previews: some View {
        ItemsMenu()
            .environmentObject(FIRItemsRepository())
    }
}
