//
//  DDGProfile.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import CloudKit

struct DDGProfile {
    static let kFirstName = "firstName"
    static let kLastName = "lastName"
    static let kCompanyName = "companyName"
    static let kBio = "bio"
    static let kAvatar = "avatar"
    static let kIsCheckedIn = "isCheckedIn"

    let ckRecordID: CKRecord.ID
    let firstName: String
    let lastName: String
    let companyName: String
    let bio: String
    let avatar: CKAsset!
    let isCheckedIn: CKRecord.Reference? = nil

    init(record: CKRecord) {
        self.ckRecordID = record.recordID
        self.firstName = record[DDGProfile.kFirstName] as? String ?? "N/A"
        self.lastName = record[DDGProfile.kLastName] as? String ?? "N/A"
        self.companyName = record[DDGProfile.kCompanyName] as? String ?? "N/A"
        self.bio = record[DDGProfile.kBio] as? String ?? "N/A"
        self.avatar = record[DDGProfile.kAvatar] as? CKAsset
    }
}
