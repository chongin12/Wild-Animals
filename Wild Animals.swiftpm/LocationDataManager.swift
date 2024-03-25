//
//  LocationDataManager.swift
//  Wild Animals
//
//  Created by 정종인 on 3/21/24.
//

import Foundation
import CoreLocation
import MapKit
import _MapKit_SwiftUI

@Observable
class LocationDataManager: NSObject {
    static let shared = LocationDataManager()
    var locationManager = CLLocationManager()
    var authorizationStatus: CLAuthorizationStatus?

    var currentCoordinator: CLLocationCoordinate2D {
        if let coordinate = self.locationManager.location?.coordinate {
            return coordinate
        } else {
            return .init()
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        setup()
    }

    private func setup() {
        switch locationManager.authorizationStatus {
            //If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            //If we don´t, we request authorization
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }

    public func checkIfLocationIsEnabled() -> Bool {
        authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
    }

}

extension LocationDataManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            locationManager.requestLocation()
            break
        case .authorizedWhenInUse:
            locationManager.requestLocation()
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location Update!")
        print("location : \(manager.location?.coordinate)")
        self.locationManager = manager
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("error : \(error.localizedDescription)")
    }
}

extension MKCoordinateRegion {
    static var mockData: Self {
        let center = CLLocationCoordinate2D(latitude: 34.011_284, longitude: -116.166_860)
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: center, span: span)
        return region
    }
}

extension MapCameraPosition {
    static var mockData: Self {
        return .region(.mockData)
    }
}
