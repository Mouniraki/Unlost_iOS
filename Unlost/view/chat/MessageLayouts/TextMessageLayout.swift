//
//  MessageLayout.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import SwiftUI

struct TextMessageLayout: View {
    let message: TextMessage
        
    var body: some View {
        VStack(alignment: message.isReceived ? .leading : .trailing){
            HStack{
                Text(message.body)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .background(message.isReceived ? .gray : .blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .frame(maxWidth: 300, alignment: message.isReceived ? .leading : .trailing)
            
            Text(message.timestamp.formatted(.dateTime.day().month().year().hour().minute()))
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: message.isReceived ? .leading : .trailing)
        .padding(message.isReceived ? .leading : .trailing)
        .padding(.horizontal, 10)
        
    }
}

struct MessageLayout_Previews: PreviewProvider {
    static var previews: some View {
        TextMessageLayout(message: TextMessage.example)
    }
}
