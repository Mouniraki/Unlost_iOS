//
//  ItemView.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation
import CoreImage
import CoreImage.CIFilterBuiltins

struct ItemView: View {
    @EnvironmentObject var itemsRepo: FIRItemsRepository
    
    let item: Item
    
    let locationService = LocationService.shared
    
    @State private var isLost = false
    @State private var geocoderText = ""
    
    @State private var showDeletePrompt = false
    
    var body: some View {
        VStack{
            VStack{
                Image(systemName: item.getRelatedIconType(itemType: item.type))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .padding()
                    .background(.green)
                    .clipShape(Circle())
                    
                HStack{
                    Spacer()
                }
                
                Text("\(item.name)")
                    .font(.largeTitle)
                    .bold()
                
                Text("\(item.description)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            
            Form {
                Section(header: Text("QR Code")) {
                    NavigationLink(destination: QRCodeView(item: item)) {
                        Text("See the associated QR Code")
                    }
                }
                
                Section(header: Text("Last location")){
                    NavigationLink(destination: ItemMapView(item: item)) {
                        Text(geocoderText)
                            .onAppear {
                                locationService.getLocationName(coordinates: item.lastLocation){ locationName in
                                    self.geocoderText = locationName
                                }
                            }
                    }.disabled(item.lastLocation == nil)
                    
                    //TODO: FIND A WAY TO PROPERLY SET ISLOST STATE TO AN ITEM
                    Toggle("Is lost", isOn: $isLost)
                        .onAppear{
                            isLost = item.isLost
                        }
                }
                
                Button {
                    showDeletePrompt.toggle()
                } label: {
                    Label("Delete item", systemImage: "trash")
                }
                .foregroundColor(.red)
                .alert("Are you sure to delete this item ?", isPresented: $showDeletePrompt) {
                    Button("Delete", role: .destructive) {
                        itemsRepo.removeItem(
                            at: IndexSet(
                                integer: itemsRepo.findItemInList(
                                    items: itemsRepo.items,
                                    item: item)
                            )){ success in
                                //TODO: INSERT CODE HERE
                            }
                    }
                    Button("Cancel", role: .cancel){}
                }
            }
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(item: Item.example)
            .environmentObject(FIRItemsRepository())
    }
}
