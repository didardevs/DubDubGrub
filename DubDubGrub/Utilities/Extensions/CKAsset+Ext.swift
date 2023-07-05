//
//  CKAsset+Ext.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/5/23.
//

import CloudKit
import UIKit

extension CKAsset {
    
    func convertToUIImage(in dimention: ImageDimention) -> UIImage {
        guard let fileUrl = self.fileURL else { return dimention.placeholder}
        do {
            let data = try Data(contentsOf: fileUrl)
            return UIImage(data: data) ?? dimention.placeholder
        } catch {
            return dimention.placeholder
        }
    }
}
