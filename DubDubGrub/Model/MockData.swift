//
//  MockData.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import CloudKit

struct MockData {
    
    static var location: CKRecord {
        let record = CKRecord(recordType: RecordType.location)
        record[DDGLocation.kName] = "Didar's Bar and Grill"
        record[DDGLocation.kAddress] = "123 Main Street"
        record[DDGLocation.kDescription] = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
        record[DDGLocation.kWebsiteURL] = "https://www.apple.com"
        record[DDGLocation.kLocation] = CLLocation(latitude: 37.331516, longitude: -121.891054)
        record[DDGLocation.kPhoneNumber] = "111-111-1111"
        
        return record
    }
    
    static var profile: CKRecord {
        let record = CKRecord(recordType: RecordType.profile)
        record[DDGProfile.kFirstName] = "Aleksandra Jòrd"
        record[DDGProfile.kLastName] = "Kristjánsdóttir"
        record[DDGProfile.kCompanyName] = "Icelandic Air Development LLC"
        record[DDGProfile.kBio] = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam."
        
        return record
    }
    
    static var chipotle: CKRecord {
        let record = CKRecord(recordType: RecordType.location,
                                                       recordID: CKRecord.ID(recordName: "9227C987-F1E1-F3AE-FCC6-F6FE71A43EE7"))
        record[DDGLocation.kName] = "Chipotle"
        record[DDGLocation.kAddress] = "1 S Market St Ste 40"
        record[DDGLocation.kDescription] = "Our local San Jose One South Market Chipotle Mexican Grill is cultivating a better world by serving responsibly sourced, classically-cooked, real food."
        record[DDGLocation.kWebsiteURL] = "https://locations.chipotle.com/ca/san-jose/1-s-market-st"
        record[DDGLocation.kLocation] = CLLocation(latitude: 37.334967, longitude: -121.892566)
        record[DDGLocation.kPhoneNumber] = "408-938-0919"
        
        return record
    }
    
}
