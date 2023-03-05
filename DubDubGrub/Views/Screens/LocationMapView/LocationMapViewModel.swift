//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import MapKit

final class LocationMapViewModel: NSObject, ObservableObject {
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    var deviceLocationManager: CLLocationManager?
    
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            deviceLocationManager = CLLocationManager()
            deviceLocationManager!.delegate = self
        } else {
            alertItem = AlertContex.locationDisabled
        }
    }
    
    private func checkLocationAuthorization() {
        guard let deviceLocationManager else { return }
        switch deviceLocationManager.authorizationStatus {
            
        case .notDetermined:
            deviceLocationManager.requestWhenInUseAuthorization()
        case .denied:
            alertItem = AlertContex.locationDenied
        case .restricted:
            alertItem = AlertContex.locationRestricted
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }
    }
    
    func getLocations(for locationManager: DDGLocationManager) {
        DDGCloudKitManager.getLocations { [self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let locations):
                    locationManager.locations = locations
                    case .failure(_):
                    self.alertItem = AlertContex.unableToGetLocations
                }
            }
        }
    }
}

extension LocationMapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
