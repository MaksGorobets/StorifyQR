//
//  MapViewModel.swift
//  StorifyQR
//
//  Created by Maks Winters on 03.01.2024.
//

import MapKit
import SwiftUI

// TODO: Error handling

@Observable
final class MapViewModel: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    var rawLocation = CLLocationCoordinate2D(latitude: 8.7832, longitude: 124.5085)
    var mapRegionPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 8.7832, longitude: 124.5085), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
    
    func checkIfLocationServicesIsEnabled() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                // error handling
                return
            }
        }
            self.locationManager = CLLocationManager()
            self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager!.delegate = self
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("requesting auth")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("your location is restricted likely due to parental controls")
        case .denied:
            print("you have denied location permission, you can re-enable it in settings")
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            print("authorized")
            rawLocation = locationManager.location!.coordinate
            mapRegionPosition = .region(MKCoordinateRegion(center: rawLocation, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
        @unknown default:
            fatalError("Unknown locationManager authrorization status")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

