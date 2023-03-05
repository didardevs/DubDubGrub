//
//  AlertItem.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContex {
    //MARK: - MapView Errors
    
    static let unableToGetLocations = AlertItem(title: Text("Location Error"), message: Text("Unable to retrieve locations at this time. \nPlease try again."), dismissButton: .default(Text("Ok")))
    //MARK: - Location Authorization Errors
    static let locationRestricted = AlertItem(title: Text("Location Restricted"), message: Text("Your location is restricted. This may be due to parental controls."), dismissButton: .default(Text("Ok")))
    static let locationDenied = AlertItem(title: Text("Location Denied"), message: Text("The application does not have permission to acces your location. To change that go to your phone's settings"), dismissButton: .default(Text("Ok")))
    static let locationDisabled = AlertItem(title: Text("Location Disabled"), message: Text("Yout phone's location services are disabled. To change that go to your phone's settings"), dismissButton: .default(Text("Ok")))
}
