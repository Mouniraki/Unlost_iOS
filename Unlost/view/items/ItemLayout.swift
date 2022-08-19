//
//  ItemLayout.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI

struct ItemLayout: View {
    let item: Item
    
    var body: some View {
        HStack{
            Image(systemName: ItemType.getRelatedIconType(itemType: item.type))
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding()
            
            VStack(alignment: .leading){
                Text("\(item.name)")
                    .font(.headline)
                Text("\(item.description)")
            }
        }
    }
}

struct ItemLayout_Previews: PreviewProvider {
    static var previews: some View {
        ItemLayout(item: Item.example)
    }
}
