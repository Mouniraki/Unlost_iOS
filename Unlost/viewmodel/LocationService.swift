//
//  LocationService.swift
//  Unlost
//
//  Created by Mounir Raki on 18.07.22.
//

import Foundation
import Combine
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
    var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()
    
    @Published var lastLocation: Location?
    @Published var tokens: Set<AnyCancellable> = []
    
    private override init(){
        super.init()
    }
    
    // Singleton
    static let shared = LocationService()
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    func requestLocationUpdates() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        default:
            deniedLocationAccessPublisher.send()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        default:
            manager.stopUpdatingLocation()
            deniedLocationAccessPublisher.send()
        }
    }
    
    // Success delegate => sends the last location through the publisher
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        coordinatesPublisher.send(location.coordinate)
    }
    
    // Error delegate => handles errors when retrieving location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordinatesPublisher.send(completion: .failure(error))
    }
    
    // OBSERVER FUNCTIONS => TO USE IN ORDER TO UPDATE UI COMPONENTS
    func observeLocationUpdates() {
        self.coordinatesPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            } receiveValue: { coordinates in
                self.lastLocation = Location(latitude: coordinates.latitude, longitude: coordinates.longitude)
            }
            .store(in: &tokens)
    }

    func observeLocationAccessDenied() {
        self.deniedLocationAccessPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                print("Show error message")
            }
            .store(in: &tokens)
    }
    
    // GEOCODER FUNCTIONS
    let geocoder = CLGeocoder()

    func getLocationName(coordinates: Location?, completion: @escaping (_ name: String) -> Void){
        if coordinates != nil {
            geocoder.reverseGeocodeLocation(coordinates!.toCLLocation(), completionHandler: {
                (placemarks, error) in
                guard let placemarks = placemarks,
                    let location = placemarks.first else {
                    completion("Name not available")
                    return
                }
                
                completion("\(location.name ?? ""), \(location.locality ?? "")")
            })
        } else {
            completion("No location available")
        }
    }
}
