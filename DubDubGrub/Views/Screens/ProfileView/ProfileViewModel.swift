//
//  ProfileViewModel.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/5/23.
//

import CloudKit

enum ProfileContext { case create, update }

extension ProfileView {
    
    @MainActor final class ProfileViewModel: ObservableObject {
        
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
        var buttonTitle: String { profileContext == .create ? "Create Profile" : "Update Profile" }
        
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
        
        func determineButtonAction() {
            profileContext == .create ? createProfile() : updateProfile()
        }
        
        private func createProfile() {
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
            
            Task {
                do {
                    let records = try await DDGCloudKitManager.shared.batchSave(records: [userRecord, profileRecord])
                    for record in records where record.recordType == RecordType.profile {
                        existingProfileRecord = record
                        DDGCloudKitManager.shared.profileRecordID = record.recordID
                    }
                    hideLoadingView()
                    alertItem = AlertContex.createProfileSuccess
                } catch {
                    hideLoadingView()
                    alertItem = AlertContex.createProfileFailure
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
            
            Task {
                do {
                    let record = try await DDGCloudKitManager.shared.fetchRecord(with: profileRecordId)
                    existingProfileRecord = record
                    
                    let profile = DDGProfile(record: record)
                    firstName = profile.firstName
                    lastName = profile.lastName
                    companyName = profile.companyName
                    bio = profile.bio
                    avatar = profile.avatarImage
                    hideLoadingView()
                } catch {
                    hideLoadingView()
                    alertItem = AlertContex.unableToGetProfile
                }
            }
        }
        
        private func updateProfile() {
            
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
            
            Task {
                do {
                    let _ = try await DDGCloudKitManager.shared.save(record: existingProfileRecord)
                    hideLoadingView()
                    alertItem = AlertContex.updateProfileSuccess
                } catch {
                    hideLoadingView()
                    alertItem = AlertContex.updateProfileFailure
                }
            }
        }
        
        func getCheckedInStatus() {
            
            guard let profileRecordID = DDGCloudKitManager.shared.profileRecordID else { return }
            
            Task {
                do {
                    let record = try await DDGCloudKitManager.shared.fetchRecord(with: profileRecordID)
                    if let _ = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference {
                        isCheckedIn = true
                    } else {
                        isCheckedIn = false
                    }
                } catch {
                    print("unable to get checked in status")
                }
            }
        }
        
        func checkOut() {
            
            guard let profileID = DDGCloudKitManager.shared.profileRecordID else {
                alertItem = AlertContex.unableToGetProfile
                return
            }
            
            showLoadingView()
            
            Task {
                do {
                    let record = try await DDGCloudKitManager.shared.fetchRecord(with: profileID)
                    record[DDGProfile.kIsCheckedIn] = nil
                    record[DDGProfile.kIsCheckedInNilCheck] = nil
                    
                    let _ = try await DDGCloudKitManager.shared.save(record: record)
                    HapticManager.playSuccess()
                    isCheckedIn = false
                    hideLoadingView()
                } catch {
                    self.hideLoadingView()
                    self.alertItem = AlertContex.unableToCheckInOrOut
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
}

