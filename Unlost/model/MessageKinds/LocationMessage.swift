//
//  LocationMessage.swift
//  Unlost
//
//  Created by Mounir Raki on 12.07.22.
//

import Foundation
import CoreLocation
import MapKit

final class LocationMessage: Message {
    var coordinates: Location
    
    init(id: String, isReceived: Bool, timestamp: Date, coordinates: Location){
        self.coordinates = coordinates
        super.init(id: id, isReceived: isReceived, timestamp: timestamp)
    }
    
    //TODO: FIND A WAY TO PUT AN ANNOTATION IN THE SNAPSHOT
    func getLocationSnapshot(completion: @escaping (_ image: UIImage?) -> Void) {
        let options: MKMapSnapshotter.Options = .init()
        options.region = MKCoordinateRegion(
            center: coordinates.toCLLocation().coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        options.size = CGSize(width: 200, height: 200)
        options.mapType = .standard
        options.showsBuildings = true
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start{ snapshot, error in
            if let snapshot = snapshot {
                completion(snapshot.image)
            } else if let error = error {
                print("Something went wrong \(error.localizedDescription)")
                completion(nil)
            }
        }
        
    }
    
    
    #if DEBUG
    static let example = LocationMessage(id: "ID",
                                         isReceived: false,
                                         timestamp: Date.now,
                                         coordinates: Location(latitude: 12.39819, longitude: 4.29281))
    #endif
}
