//
//  LocationMapViewModel.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI
import MapKit
import CloudKit

final class LocationMapViewModel: ObservableObject {

    @Published var checkedInProfiles : [CKRecord.ID : Int] = [:]
    @Published var isShowingDetailView = false
    @Published var alertItem: AlertItem?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331516, longitude: -121.891054), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

    
    func getLocations(for locationManager: DDGLocationManager) {
        DDGCloudKitManager.shared.getLocations { [self] result in
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
    
    func getCheckedInCount(){
        DDGCloudKitManager.shared.getCheckedInProfileCount { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let checkedInProfiles):
                    self.checkedInProfiles = checkedInProfiles
                case .failure(_):
                        break
                }
            }
        }
    }
    
    func createVoiceOverSummary(for location: DDGLocation) -> String {
        let count = checkedInProfiles[location.id, default: 0]
        let personPlurality = count == 1 ? "person" : "people"
        
        return "Map Pin \(location.name) \(count) \(personPlurality) checked in"
    }
    
    @ViewBuilder func createLocationDetailView(for location: DDGLocation, in sizeCategory: DynamicTypeSize) -> some View {
        if sizeCategory >= .large {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location)).embedInScrollView()
        } else {
            LocationDetailView(viewModel: LocationDetailViewModel(location: location))
        }
    }
}


