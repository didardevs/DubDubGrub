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

@MainActor final class LocationDetailViewModel: ObservableObject {
    
    @Published var checkedInProfiles: [DDGProfile] = []
    @Published var isCheckedIn = false
    @Published var isShowingProfileModal = false
    @Published var isShowingProfileSheet = false
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    
    
    var location: DDGLocation
    var selectedProfile: DDGProfile?
    var buttonColor: Color { isCheckedIn ? .grubRed : .brandPrimary }
    var buttonImageTitle: String { isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark" }
    var buttonA11yLabel: String { isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark"}
    
    init(location:DDGLocation) { self.location = location }
    
    func determineColumns(for dynamicTypeSize: DynamicTypeSize) -> [GridItem] {
        let numberOfColumns = dynamicTypeSize >= .accessibility3 ? 1 : 3
        return Array(repeating: GridItem(.flexible()), count: numberOfColumns)
    }
    
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
        
        Task {
            do {
                let record = try await DDGCloudKitManager.shared.fetchRecord(with: profileRecordID)
                if let reference = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                    isCheckedIn = reference.recordID == location.id
                } else {
                    isCheckedIn = false
                }
            } catch {
                alertItem = AlertContex.unableToGetCheckInStatus
            }
        }

    }
    
    func updateCheckInStatus(to checkInStatus: CheckInStatus){
        
        guard let profileRecordID = DDGCloudKitManager.shared.profileRecordID else {
            alertItem = AlertContex.unableToGetProfile
            return
        }
        
        showLoadingView()
        
        Task {
            do {
                let record = try await DDGCloudKitManager.shared.fetchRecord(with: profileRecordID)
                switch checkInStatus {
                case .checkIn:
                    record[DDGProfile.kIsCheckedIn] = CKRecord.Reference(recordID: location.id, action: .none)
                    record[DDGProfile.kIsCheckedInNilCheck] = 1
                case .checkOut:
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                }
                
                let savedRecord = try await DDGCloudKitManager.shared.save(record: record)
                hideLoadingView()
                HapticManager.playSuccess()
                let profile = DDGProfile(record: savedRecord)
                switch checkInStatus {
                case .checkIn:
                    checkedInProfiles.append(profile)
                case .checkOut:
                    checkedInProfiles.removeAll(where:{ $0.id == profile.id })
                }
                
                isCheckedIn.toggle()
            } catch {
                hideLoadingView()
                alertItem = AlertContex.unableToCheckInOrOut
            }
        }
    }
    
    func getCheckInProfiles() {
        showLoadingView()
        Task {
            do {
                checkedInProfiles = try await DDGCloudKitManager.shared.getCheckedInProfiles(for: location.id)
                hideLoadingView()
            } catch {
                hideLoadingView()
                alertItem = AlertContex.unableToGetCheckedInProfiles
            }
        }
    }
    
    func show(_ profile: DDGProfile, in dynamicTypeSize: DynamicTypeSize) {
        selectedProfile = profile
        if dynamicTypeSize >= .accessibility3 {
            isShowingProfileSheet = true
        } else {
            isShowingProfileModal = true
        }
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
