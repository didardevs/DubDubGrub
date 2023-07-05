//
//  DDGLocation.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import CloudKit
import UIKit

struct DDGLocation : Identifiable, Hashable {
    
    static let kName = "name"
    static let kDescription = "description"
    static let kSquareAsset = "squareAsset"
    static let kBannerAsset = "bannerAsset"
    static let kAddress = "address"
    static let kLocation = "location"
    static let kWebsiteURL = "websiteURL"
    static let kPhoneNumber = "phoneNumber"
    
    let id: CKRecord.ID
    let name: String
    let description: String
    let squareAsset: CKAsset!
    let bannerAsset: CKAsset!
    let address: String
    let location: CLLocation
    let websiteURL: String
    let phoneNumber: String
    
    init(record: CKRecord) {
        self.id = record.recordID
        self.name = record[DDGLocation.kName] as? String ?? "N/A"
        self.description = record[DDGLocation.kDescription] as? String ?? "N/A"
        self.squareAsset = record[DDGLocation.kSquareAsset] as? CKAsset
        self.bannerAsset = record[DDGLocation.kBannerAsset] as? CKAsset
        self.address = record[DDGLocation.kAddress] as? String ?? "N/A"
        self.location = record[DDGLocation.kLocation] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        self.websiteURL = record[DDGLocation.kWebsiteURL] as? String ?? "N/A"
        self.phoneNumber = record[DDGLocation.kPhoneNumber] as? String ?? "N/A"
    }
    
    
    var squareImage: UIImage {
        guard let asset = squareAsset else { return PlaceholderImage.square }
        return asset.convertToUIImage(in: .square)
    }
    
    var bannerImage: UIImage {
        guard let asset = squareAsset else { return PlaceholderImage.banner }
        return asset.convertToUIImage(in: .banner)
    }
}

