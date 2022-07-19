//
//  PicMessageLayout.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import SwiftUI

struct PicMessageLayout: View {
    let message: PicMessage
    
    var body: some View {
        VStack(alignment: message.isReceived ? .leading : .trailing){
            HStack{
                NavigationLink(
                    destination: Image(uiImage: message.image)
                        .resizable()
                        .scaledToFit()
                ){
                    Image(uiImage: message.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(3)
                        .background(message.isReceived ? .gray : .blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

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

struct PicMessageLayout_Previews: PreviewProvider {
    static var previews: some View {
        PicMessageLayout(
            message: PicMessage.example)
    }
}
