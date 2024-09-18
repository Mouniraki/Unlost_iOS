//
//  AddItemView.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var itemsRepo: FIRItemsRepository
    
    @State private var itemName = ""
    @State private var itemDesc = ""
    
    let itemTypes = ItemType.allCases
    @State private var itemType = ItemType.Keys
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item name")) {
                    TextField("Enter the item name…", text: $itemName)
                }
                
                Section(header: Text("Item description")) {
                    TextField("Enter a short description…", text: $itemDesc)
                }
                
                Section(header: Text("Item Type")) {
                    Picker("Choose an item type", selection: $itemType){
                        ForEach(itemTypes, id: \.self){
                            Text($0.description)
                        }
                    }
                }
            }
            .navigationTitle("Add New Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        //TODO: REPLACE USER ID BY ACTUAL USER ID
                        itemsRepo.addItem(
                            item: Item(id: "MOUNIRITEM\(itemsRepo.items.count + 1)",
                                       name: itemName,
                                       description: itemDesc,
                                       type: itemType,
                                       lastLocation: nil,
                                       isLost: false)
                        ) { success in
                            // TODO: INSERT CODE HERE
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                    }.disabled(itemName.isEmpty || itemDesc.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        AddItemView()
            .environmentObject(FIRItemsRepository())
    }
}
