//
//  DDGProfile.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import CloudKit
import UIKit

struct DDGProfile : Identifiable {
    static let kFirstName = "firstName"
    static let kLastName = "lastName"
    static let kCompanyName = "companyName"
    static let kBio = "bio"
    static let kAvatar = "avatar"
    static let kIsCheckedIn = "isCheckedIn"
    static let kIsCheckedInNilCheck = "isCheckedInNilCheck"

    let id: CKRecord.ID
    let firstName: String
    let lastName: String
    let companyName: String
    let bio: String
    let avatar: CKAsset!
    let isCheckedIn: CKRecord.Reference?

    init(record: CKRecord) {
        self.id = record.recordID
        self.firstName = record[DDGProfile.kFirstName] as? String ?? "N/A"
        self.lastName = record[DDGProfile.kLastName] as? String ?? "N/A"
        self.companyName = record[DDGProfile.kCompanyName] as? String ?? "N/A"
        self.bio = record[DDGProfile.kBio] as? String ?? "N/A"
        self.avatar = record[DDGProfile.kAvatar] as? CKAsset
        self.isCheckedIn = record[DDGProfile.kIsCheckedIn] as? CKRecord.Reference
    }
    
    func createAvatarImage() -> UIImage {
        guard let asset = avatar else { return PlaceholderImage.avatar }
        return asset.convertToUIImage(in: .square)
    }
}
