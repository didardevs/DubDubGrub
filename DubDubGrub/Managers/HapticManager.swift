//
//  HapticManager.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/16/23.
//

import UIKit

struct HapticManager {
    static func playSuccess(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
