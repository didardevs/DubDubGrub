//
//  LocationDetailViewModel.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/5/23.
//

import SwiftUI
import MapKit
import CloudKit

enum CheckInStatus { case checkIn, checkOut }

final class LocationDetailViewModel: ObservableObject {
    
    @Published var checkedInProfiles: [DDGProfile] = []
    @Published var isCheckedIn = false
    @Published var isShowingProfileModal = false
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var location: DDGLocation
    
    init(location:DDGLocation) { self.location = location }
    
    
    func getDirectionsToLocation() {
        let placemark = MKPlacemark(coordinate: location.location.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = location.name
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    func callLocation(){
        guard let url = URL(string: "tel://\(location.phoneNumber)") else {
            alertItem = AlertContex.invalidPhoneNumber
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            alertItem = AlertContex.invalidDevice
        }
    }
    
    func getCheckedInStatus() {
        guard let profileRecordID = DDGCloudKitManager.shared.profileRecordID else { return }
        
        DDGCloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let record):
                        if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                            isCheckedIn = reference.recordID == location.id
                        } else {
                            isCheckedIn = false
                        }
                    case .failure(_):
                    alertItem = AlertContex.unableToGetCheckInStatus
                }
            }
        }
    }
    
    func updateCheckInStatus(to checkInStatus: CheckInStatus){
        
        guard let profileRecordID = DDGCloudKitManager.shared.profileRecordID else {
            alertItem = AlertContex.unableToGetProfile
            return
        }
        
        DDGCloudKitManager.shared.fetchRecord(with: profileRecordID) { [self] result in
            switch result {
            case .success(let record):
                switch checkInStatus {
                case .checkIn:
                    record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                    record[DDGProfile.kIsCheckedInNilCheck] = 1
                case .checkOut:
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                }
                
                DDGCloudKitManager.shared.save(record: record) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let record):
                            let profile = DDGProfile(record: record)
                            switch checkInStatus {
                            case .checkIn:
                                checkedInProfiles.append(profile)
                            case .checkOut:
                                checkedInProfiles.removeAll(where:{ $0.id == profile.id })
                            }
                            
                            isCheckedIn = checkInStatus == .checkIn
                            
                        case .failure(_):
                            alertItem = AlertContex.unableToCheckInOrOut
                        }
                    }
                }
            case .failure(_):
                alertItem = AlertContex.unableToCheckInOrOut
            }
        }
    }
    
    func getCheckInProfiles() {
        showLoadingView()
        DDGCloudKitManager.shared.getCheckedInProfiles(for: location.id) { result in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let profiles):
                    checkedInProfiles = profiles
                case .failure(_):
                    alertItem = AlertContex.unableToGetCheckedInProfiles
                }
                
                hideLoadingView()
            }
        }
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
