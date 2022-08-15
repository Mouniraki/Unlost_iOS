//
//  LocationMessageLayout.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import SwiftUI
import CoreLocation

struct LocationMessageLayout: View {
    let message: LocationMessage
    
    //TODO: CHANGE DEFAULT LOCATION IMAGE TO SOMETHING MORE MEANINGFUL
    @State private var defaultLocationSnapshot = UIImage(named: "locationPlaceholder")
    
    var body: some View {
        VStack(alignment: message.isReceived ? .leading : .trailing){
            HStack{
                NavigationLink(destination: ChatMapView(message: message)){
                    Image(uiImage: defaultLocationSnapshot!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(3)
                        .background(message.isReceived ? .gray : .blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onAppear{
                            message.getLocationSnapshot { snapshot in
                                if snapshot != nil{
                                    defaultLocationSnapshot = snapshot
                                }
                            }
                        }
                }
            }
            .frame(maxWidth: 300, alignment: message.isReceived ? .leading : .trailing)
            
            Text(message.timestamp.toAppleDate().formatted(.dateTime.day().month().year().hour().minute()))
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: message.isReceived ? .leading : .trailing)
        .padding(message.isReceived ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}

struct LocationMessageLayout_Previews: PreviewProvider {
    static var previews: some View {
        LocationMessageLayout(message: LocationMessage.example)
    }
}
