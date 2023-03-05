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
    
    private var existingProfileRecord: CKRecord? {
        didSet { profileContext = .update }
    }
    var profileContext: ProfileContext = .create
    
    func isValidProfile() -> Bool {
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
