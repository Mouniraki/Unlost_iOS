//
//  ItemMapView.swift
//  Unlost
//
//  Created by Mounir Raki on 13.07.22.
//

import SwiftUI
import MapKit
import CoreLocation

struct ItemMapView: View {
    let item: Item
    
    @State private var defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    
    var body: some View {
        Map(coordinateRegion: $defaultRegion, annotationItems: [Item]([item]).filter{ i in i.lastLocation != nil
        }){ item in
            MapAnnotation(coordinate: item.lastLocation!.toCLLocation().coordinate) {
                MapAnnotationLayout(coordinates: item.lastLocation!.toCLLocation(), annotationTitle: "Go to \(item.name)")
            }
        }
        .onAppear {
            defaultRegion.center = item.lastLocation!.toCLLocation().coordinate
        }
        .navigationTitle("Last location of \(item.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ItemMapView_Previews: PreviewProvider {
    static var previews: some View {
        ItemMapView(item: Item.example)
    }
}
