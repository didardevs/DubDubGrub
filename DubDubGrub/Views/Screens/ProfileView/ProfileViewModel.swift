//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/5/23.
//

import CloudKit

enum ProfileContext { case create, update }

final class ProfileViewModel: ObservableObject {
    
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var companyName = ""
    @Published var bio = ""
    @Published var avatar = PlaceholderImage.avatar
    @Published var isShowingPhotoPicker = false
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    @Published var isCheckedIn = false
    
    private var existingProfileRecord: CKRecord? {
        didSet { profileContext = .update }
    }
    
    var profileContext: ProfileContext = .create
    
    
    private func isValidProfile() -> Bool {
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !companyName.isEmpty,
              !bio.isEmpty,
              avatar != PlaceholderImage.avatar,
              bio.count <= 100 else { return false }
        return true
    }
    
    func createProfile() {
        guard isValidProfile() else {
            alertItem = AlertContex.invalidProfile
            return
        }
        
        let profileRecord = createProfileRecord()
        
        guard let userRecord = DDGCloudKitManager.shared.userRecord else {
            alertItem = AlertContex.noUserRecord
            return
        }
        
        userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .none)
        showLoadingView()
        DDGCloudKitManager.shared.batchSave(records: [userRecord, profileRecord]) { result in
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                
                switch result {
                case .success(let records):
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        DDGCloudKitManager.shared.profileRecordID = record.recordID
                    }
                    alertItem = AlertContex.createProfileSuccess
                case .failure(_):
                    alertItem = AlertContex.createProfileFailure
                    break
                }
            }
        }
    }
    
    
    func getProfile() {
        
        guard let userRecord = DDGCloudKitManager.shared.userRecord else {
            alertItem = AlertContex.noUserRecord
            return
        }
        
        guard let profileReference = userRecord["userProfile"] as? CKRecord.Reference else { return }
        let profileRecordId = profileReference.recordID
        
        showLoadingView()
        DDGCloudKitManager.shared.fetchRecord(with: profileRecordId) { result in
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                
                switch result {
                case .success(let record):
                    existingProfileRecord = record
                    
                    let profile = DDGProfile(record: record)
                    firstName = profile.firstName
                    lastName = profile.lastName
                    companyName = profile.companyName
                    bio = profile.bio
                    avatar = profile.createAvatarImage()
                    
                case .failure(_):
                    alertItem = AlertContex.unableToGetProfile
                    break
                }
            }
        }
    }
    
    func updateProfile() {
        
        guard isValidProfile() else {
            alertItem = AlertContex.invalidProfile
            return
        }
        
        guard let existingProfileRecord else {
            alertItem = AlertContex.unableToGetProfile
            return
        }
        
        existingProfileRecord[DDGProfile.kFirstName] = firstName
        existingProfileRecord[DDGProfile.kLastName] = lastName
        existingProfileRecord[DDGProfile.kCompanyName] = companyName
        existingProfileRecord[DDGProfile.kBio] = bio
        existingProfileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()
        
        showLoadingView()
        
        DDGCloudKitManager.shared.save(record: existingProfileRecord) { result in
            DispatchQueue.main.async { [self] in
                hideLoadingView()
                switch result {
                case .success(_):
                    alertItem = AlertContex.updateProfileSuccess
                case .failure(_):
                    alertItem = AlertContex.updateProfileFailure
                }
            }
        }
    }
    
    func getCheckedInStatus() {
        
        guard let profileRecordID = DDGCloudKitManager.shared.profileRecordID else { return }
        
        DDGCloudKitManager.shared.fetchRecord(with: profileRecordID) { result in
            DispatchQueue.main.async {
                switch result {
                    case .success(let record):
                        if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                            self.isCheckedIn = true
                        } else {
                            self.isCheckedIn = false
                        }
                    case .failure(_):
                    break
                }
            }
        }
    }
    
    func checkOut() {
        
        guard let profileID = DDGCloudKitManager.shared.profileRecordID else {
            alertItem = AlertContex.unableToGetProfile
            return
        }
        
        DDGCloudKitManager.shared.fetchRecord(with: profileID) { result in
            switch result {
            case .success(let record):
                record[DDGProfile.kIsCheckedIn] = nil
                record[DDGProfile.kIsCheckedInNilCheck] = nil
                
                DDGCloudKitManager.shared.save(record: record) {  result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(_):
                            self.isCheckedIn = false
                        case .failure(_):
                            self.alertItem = AlertContex.unableToCheckInOrOut
                        }
                    }
                }
            case .failure(_):
                DispatchQueue.main.async { self.alertItem = AlertContex.unableToCheckInOrOut }
            }
        }
    }
  
    private func createProfileRecord() -> CKRecord {
        let profileRecord = CKRecord(recordType: RecordType.profile)
        profileRecord[DDGProfile.kFirstName] = firstName
        profileRecord[DDGProfile.kLastName] = lastName
        profileRecord[DDGProfile.kCompanyName] = companyName
        profileRecord[DDGProfile.kBio] = bio
        profileRecord[DDGProfile.kAvatar] = avatar.convertToCKAsset()
        
        return profileRecord
    }
    
    private func showLoadingView() { isLoading = true }
    private func hideLoadingView() { isLoading = false }
}
