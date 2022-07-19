//
//  MapAnnotationLayout.swift
//  Unlost
//
//  Created by Mounir Raki on 14.07.22.
//

import SwiftUI
import CoreLocation

struct MapAnnotationLayout: View {
    let coordinates: CLLocation
    let annotationTitle: String
    
    @State private var showOpenMapsAlert = false
    
    var body: some View {
        VStack {
            Button {
                showOpenMapsAlert.toggle()
            } label: {
                HStack {
                    Image(systemName: "car")
                        .padding(10)
                        .background(.blue)
                        .foregroundColor(.white)
                    Text(annotationTitle)
                        .padding(.horizontal)
                }
            }
            .background()
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .alert("Are you sure to ask for directions ? This will open the Maps app.", isPresented: $showOpenMapsAlert) {
                
                Button("Open Maps app") {
                    let url = URL(string: "maps://?saddr=&daddr=\(coordinates.coordinate.latitude),\(coordinates.coordinate.longitude)")
                    if UIApplication.shared.canOpenURL(url!) {
                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                    }
                }
                
                Button("Cancel", role: .cancel){
                    
                }
            }
            
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .background()
                .clipShape(Circle())
                .foregroundColor(.red)
        }
    }
}

struct MapAnnotationLayout_Previews: PreviewProvider {
    static var previews: some View {
        MapAnnotationLayout(coordinates: CLLocation(latitude: 12.3932, longitude: 4.29721), annotationTitle: "TestPin")
    }
}
