//
//  MapMenu.swift
//  Unlost
//
//  Created by Mounir Raki on 11.07.22.
//

import SwiftUI
import MapKit

struct MapMenu: View {
    @EnvironmentObject var itemsRepo: FIRItemsRepository
    
    @State private var showPinDescription = false
    @State private var showSettingsSheet = false
    @State private var showQrScanSheet = false
    
    @State private var defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    
    // TODO: MOVE THIS TO VIEWMODEL CLASS
    func findMidpointOfItemLocations(items: Array<Item>) -> CLLocation {
        let locations = items.filter { item in
            item.lastLocation != nil
        }.map { goodItem in
            goodItem.lastLocation
        }
        
        let locationsCount = Double(locations.count)
        
        let accLoc = locations.reduce(Location(latitude: 0.0, longitude: 0.0)) { lastRes, newEl in
            Location(
                latitude: newEl!.latitude + lastRes.latitude,
                longitude: newEl!.longitude + lastRes.longitude)
        }
        
        if locationsCount > 0 {
            return Location(
                latitude: accLoc.latitude / locationsCount,
                longitude: accLoc.longitude / locationsCount
            ).toCLLocation()
        } else {
            return Location(latitude: 45.0, longitude: 2.0).toCLLocation()
        }

    }
    
    var body: some View {
        //TODO: FIGURE OUT HOW TO ENABLE/DISABLE INFO-BUBBLES FOR INDIVIDUAL MARKERS
        NavigationView {
            Map(coordinateRegion: $defaultRegion, annotationItems: itemsRepo.items.filter {
                i in i.lastLocation != nil
            }){ item in
                MapAnnotation(coordinate: item.lastLocation!.toCLLocation().coordinate){
                    MapAnnotationLayout(coordinates: item.lastLocation!.toCLLocation(), annotationTitle: "\(item.name)")
                }
            }
            .onAppear {
                defaultRegion.center = findMidpointOfItemLocations(items: itemsRepo.items).coordinate
//                print(defaultRegion.center)
            }
            .navigationTitle("Last location of your items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettingsSheet.toggle()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem {
                    Button {
                        showQrScanSheet.toggle()
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsMenu()
        }
        .sheet(isPresented: $showQrScanSheet) {
            QRScanMenu()
        }
    }
}

struct MapMenu_Previews: PreviewProvider {
    static var previews: some View {
        MapMenu()
            .environmentObject(FIRItemsRepository())
    }
}
