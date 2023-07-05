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
    
    var alert: Alert {
        Alert(title: title, message: message, dismissButton: dismissButton)
    }
}

struct AlertContex {
    //MARK: - MapView Errors
    
    static let unableToGetLocations = AlertItem(title: Text("Location Error"), message: Text("Unable to retrieve locations at this time. \nPlease try again."), dismissButton: .default(Text("Ok")))
    static let checkedInCount = AlertItem(title: Text("Server Error"), message: Text("Unable to get the number of people checked into each location. Please check your internet connection and try again."), dismissButton: .default(Text("Ok")))
    
    //MARK: - LocationListView Errors
    static let unableToGetAllCheckedInProfiles = AlertItem(title: Text("Server Error"), message: Text("We are unable to get all users checked in at this time.\nPlease try again."), dismissButton: .default(Text("Ok")))
    
    //MARK: - Location Authorization Errors
    static let locationRestricted = AlertItem(title: Text("Location Restricted"), message: Text("Your location is restricted. This may be due to parental controls."), dismissButton: .default(Text("Ok")))
    static let locationDenied = AlertItem(title: Text("Location Denied"), message: Text("The application does not have permission to acces your location. To change that go to your phone's settings"), dismissButton: .default(Text("Ok")))
    static let locationDisabled = AlertItem(title: Text("Location Disabled"), message: Text("Yout phone's location services are disabled. To change that go to your phone's settings"), dismissButton: .default(Text("Ok")))
    
    //MARK: - ProfileView Errors
    static let invalidProfile = AlertItem(title: Text("Invalid Profile"), message: Text("All fields are required as well as a profile photo. Your bio must be < 100 characters. \nPlease try again."), dismissButton: .default(Text("Ok")))
    static let noUserRecord = AlertItem(title: Text("No User Record"), message: Text("You must log into iCloud on your phone in order to utilize Dub Dub Grub's Profile. Please log in on your phone's settings screen."), dismissButton: .default(Text("Ok")))
    static let createProfileSuccess = AlertItem(title: Text("Profile Created Succsessfully!"), message: Text("Your profile has successfully been created."), dismissButton: .default(Text("Ok")))
    static let createProfileFailure = AlertItem(title: Text("Failed to Create Profile"), message: Text("We were unable to create your profile at this time. \nPlese try again later or contact customer support if this persists."), dismissButton: .default(Text("Ok")))
    static let unableToGetProfile = AlertItem(title: Text("Unable to Retrieve Profile"), message: Text("We were unable to retrieve your profile at this time. \nPlese try again later or contact customer support if this persists."), dismissButton: .default(Text("Ok")))
    static let updateProfileSuccess = AlertItem(title: Text("Profile Updated Successfully!"), message: Text("Your Dub Dub Grub's profile was updated successfully!"), dismissButton: .default(Text("Ok")))
    static let updateProfileFailure = AlertItem(title: Text("Profile Update Failed!"), message: Text("We were unable to update your profile at this time. \nPlese try again later or contact customer support if this persists."), dismissButton: .default(Text("Ok")))
    
    //MARK: - LocationDetailView Errors
    static let invalidPhoneNumber = AlertItem(title: Text("Invalid Phone Number"), message: Text("The phone number for location is invalid."), dismissButton: .default(Text("Ok")))
    static let invalidDevice = AlertItem(title: Text("Invalid Device"), message: Text("You may call only on iPhone device."), dismissButton: .default(Text("Ok")))
    static let unableToGetCheckInStatus = AlertItem(title: Text("Server Error"), message: Text("Unable to retrieve checked in status of the current user.\nPlease try again."), dismissButton: .default(Text("Ok")))
    
    static let unableToCheckInOrOut = AlertItem(title: Text("Server Error"), message: Text("We are unable to check in/out at this time.\nPlease try again."), dismissButton: .default(Text("Ok")))
    
    static let unableToGetCheckedInProfiles = AlertItem(title: Text("Server Error"), message: Text("We are unable to get users checked into this location at this time.\nPlease try again."), dismissButton: .default(Text("Ok")))
}
