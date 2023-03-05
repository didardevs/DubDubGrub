//
//  DDGCloudKitManager.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import CloudKit

struct DDGCloudKitManager{
    
    static func getLocations(completed: @escaping (Result<[DDGLocation], Error>) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: DDGLocation.kName, ascending: true)
        let query = CKQuery(recordType: RecordType.location, predicate: NSPredicate(value: true))
        query.sortDescriptors = [sortDescriptor]
        
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
            guard error == nil else {
                completed(.failure(error!))
                return
            }
            
            guard let records = records else { return }
            let locations = records.map { $0.convertToDDGLocation() }
            completed(.success(locations))
        }
    }
}
