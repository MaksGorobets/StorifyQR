//
//  MapViewModel.swift
//  StorifyQR
//
//  Created by Maks Winters on 03.01.2024.
//

import MapKit
import SwiftUI

enum MapDetails {
    static let defaultRegion = CLLocationCoordinate2D(latitude: 8.7832, longitude: 124.5085)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
}

@Observable
final class MapViewModel: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?

    var rawLocation = MapDetails.defaultRegion
    var mapRegionPosition: MapCameraPosition = .region(MKCoordinateRegion(center: MapDetails.defaultRegion, span: MapDetails.defaultSpan))
    
    var isIncludingLocation = false
    var isLocationAvailable = false
    
    var showAlerts = false
    var isShowingAlert = false
    
    var alertMessage = ""
    
    func checkIfLocationServicesIsEnabled() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                self.alertUser("Location services seem to be turned off.")
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
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            isIncludingLocation = false
            showAlerts ? alertUser("Tour location is restricted likely due to parental controls.") : nil
        case .denied:
            isIncludingLocation = false
            showAlerts ? alertUser("You have denied location permission, you can re-enable it in settings") : nil
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            rawLocation = locationManager.location?.coordinate ?? MapDetails.defaultRegion
            mapRegionPosition = .region(MKCoordinateRegion(center: rawLocation, span: MapDetails.defaultSpan))
            isLocationAvailable = true
        @unknown default:
            isIncludingLocation = false
            showAlerts ? alertUser("Unknown locationManager authrorization status, contact developer.") : nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func alertUser(_ message: String) {
        alertMessage = message
        isShowingAlert = true
    }
    
}

