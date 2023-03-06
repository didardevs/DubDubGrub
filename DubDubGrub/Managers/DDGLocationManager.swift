//
//  DDGLocationManager.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import Foundation

final class DDGLocationManager: ObservableObject {
    
    @Published var locations: [DDGLocation] = []
    var selectedLocation: DDGLocation?
}
