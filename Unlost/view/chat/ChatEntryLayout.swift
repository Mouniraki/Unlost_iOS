//
//  ChatEntryLayout.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import CoreLocation

struct ChatEntryLayout: View {
    let conversation: Conversation
    
    
    var body: some View {
        HStack{
            Image(uiImage: conversation.user.profilePicture)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .background(.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(.black, lineWidth: 1))
                .padding(EdgeInsets(top: 5, leading: 10,  bottom: 5, trailing: 10))
            
            VStack(alignment: .leading){
                Text(conversation.user.getFullUserName())
                    .font(.headline)
                Text(conversation.isMyItem
                     ? "Has found your item \"\(conversation.item.name)\""
                     : "You found the item \"\(conversation.item.name)\"")
                    .lineLimit(1)
                    .font(.callout)
                    .foregroundColor(.gray)
                    
            }
            
        }
    }
}

struct ChatEntryLayout_Previews: PreviewProvider {
    static var previews: some View {
        ChatEntryLayout(conversation: Conversation.example)
    }
}
