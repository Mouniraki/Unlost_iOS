//
//  ChatMapView.swift
//  Unlost
//
//  Created by Mounir Raki on 14.07.22.
//

import SwiftUI
import CoreLocation
import MapKit

struct ChatMapView: View {
    let message: LocationMessage
    
    @State private var defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        Map(coordinateRegion: $defaultRegion, annotationItems: [LocationMessage]([message])){ loc in
            MapAnnotation(coordinate: message.coordinates.toCLLocation().coordinate){
                MapAnnotationLayout(coordinates: message.coordinates.toCLLocation(), annotationTitle: "Go to this location")
            }
        }
        .onAppear {
            defaultRegion.center = message.coordinates.toCLLocation().coordinate
        }
        .navigationTitle("Location of \(message.coordinates.toCLLocation().coordinate.latitude), \(message.coordinates.toCLLocation().coordinate.longitude)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatMapView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMapView(message: LocationMessage.example)
    }
}
