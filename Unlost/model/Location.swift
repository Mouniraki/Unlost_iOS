//
//  Location.swift
//  Unlost
//
//  Created by Mounir Raki on 18.07.22.
//

import Foundation
import CoreLocation

class Location: Equatable {
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    let latitude: Double
    let longitude: Double
    
    init(latitude: Double, longitude: Double){
        self.latitude = latitude
        self.longitude = longitude
    }
    
    static func fromCLLocation(from: CLLocation) -> Location {
        let coordinate = from.coordinate
        return Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    func toCLLocation() -> CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}
