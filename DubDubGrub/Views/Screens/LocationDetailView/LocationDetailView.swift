//
//  LocationDetailView.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI

struct LocationDetailView: View {
    
    @ObservedObject var viewModel: LocationDetailViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var body: some View {
        ZStack{
            VStack(spacing: 16) {
                BannerImageView(image: viewModel.location.createBannerImage())
                
                HStack {
                    AddressView(address: viewModel.location.address)
                    Spacer()
                }
                .padding(.horizontal)
                
                DescriptionView(text: viewModel.location.description)
                
                ZStack {
                    Capsule()
                        .frame(height: 80)
                        .foregroundColor(Color(.secondarySystemBackground))
                    
                    HStack(spacing: 20) {
                        
                        Button {
                            viewModel.getDirectionsToLocation()
                        } label: {
                            LocationActionButton(color: .brandPrimary, imageName: "location.fill")
                                .accessibilityLabel(Text("Get directions"))
                        }
                        
                        Button {
                            
                        } label: {
                            Link(destination: URL(string: viewModel.location.websiteURL)!) {
                                LocationActionButton(color: .brandPrimary, imageName: "network")
                            }
                            .accessibilityRemoveTraits(.isButton)
                            .accessibilityLabel(Text("Go to website"))
                        }
                        
                        Button {
                            viewModel.callLocation()
                        } label: {
                            LocationActionButton(color: .brandPrimary, imageName: "phone.fill")
                                .accessibilityLabel(Text("call location"))
                        }
                        if let _ = DDGCloudKitManager.shared.profileRecordID {
                            Button {
                                viewModel.updateCheckInStatus(to: viewModel.isCheckedIn ? .checkOut : .checkIn)
                                playHaptic()
                            } label: {
                                LocationActionButton(color: viewModel.isCheckedIn ? .grubRed : .brandPrimary, imageName: viewModel.isCheckedIn ? "person.fill.xmark" : "person.fill.checkmark")
                                    .accessibilityLabel(Text(viewModel.isCheckedIn ? "check out of location" : "check into location"))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Text("Who's Here?")
                    .bold()
                    .font(.title2)
                    .accessibilityAddTraits(AccessibilityTraits.isHeader)
                    .accessibilityLabel(Text("Who's Here? \(viewModel.checkedInProfiles.count) checked in"))
                    .accessibilityHint(Text("Bottom section is scrollable"))
                ZStack {
                    if viewModel.checkedInProfiles.isEmpty {
                        Text("Nobody's here")
                            .bold()
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(.top, 30)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: viewModel.determineColumns(for: sizeCategory), content: {
                                ForEach(viewModel.checkedInProfiles) { profile in
                                    FirstNameAvatarView(profile: profile)
                                        .accessibilityElement(children: .ignore)
                                        .accessibilityAddTraits(.isButton)
                                        .accessibilityHint(Text("Show's \(profile.firstName) profile pop up."))
                                        .accessibilityLabel(Text("\(profile.firstName) \(profile.lastName)"))
                                        .onTapGesture {
                                            viewModel.show(profile: profile, in: sizeCategory)
                                    }
                                }
                            })
                        }
                    }
                    if viewModel.isLoading { LoadingView() }
                }
                
                Spacer()
            }
            if viewModel.isShowingProfileModal {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .opacity(0.9)
                    .transition(AnyTransition.opacity.animation(.easeOut(duration: 0.35)))
                    .animation(.easeOut)
                    .zIndex(1)
                
                ProfileModalView(isShowingProfileModalView: $viewModel.isShowingProfileModal, profile: viewModel.selectedProfile!)
                    .accessibilityAddTraits(.isModal)
                    .transition(.opacity.combined(with: .slide))
                    .animation(.easeOut)
                    .zIndex(2)
            }
        }
        .onAppear {
            viewModel.getCheckInProfiles()
            viewModel.getCheckedInStatus()
        }
        .sheet(isPresented: $viewModel.isShowingProfileSheet, content: {
            NavigationView {
                ProfileSheetView(profile: viewModel.selectedProfile!)
                    .toolbar { Button("Dismiss") { viewModel.isShowingProfileSheet = false } }
            }
            .tint(.brandPrimary)
            
        })
        .alert(item: $viewModel.alertItem, content: { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        })
        .navigationTitle(viewModel.location.name)
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationDetailView(viewModel: LocationDetailViewModel(location:DDGLocation(record: MockData.chipotle)))
        }
        
        NavigationView {
            LocationDetailView(viewModel: LocationDetailViewModel(location:DDGLocation(record: MockData.chipotle))).embedInScrollView()
        }
        .environment(\.dynamicTypeSize, .accessibility5)
    }
}

struct LocationActionButton: View {
    
    var color: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 60, height: 60)
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
        }
    }
}

struct FirstNameAvatarView: View {
    
    @Environment(\.dynamicTypeSize) var sizeCategory
    var profile: DDGProfile
    
    var body: some View {
        VStack {
            AvatarView(image: profile.createAvatarImage(), size: sizeCategory >= .large ? 100 : 64)
            Text(profile.firstName)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

struct BannerImageView: View {
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 120)
            .accessibilityHidden(true)
    }
}

struct AddressView: View {
    
    var address: String
    
    var body: some View {
        Label(address, systemImage: "mappin.and.ellipse")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

struct DescriptionView: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .minimumScaleFactor(0.75)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
    }
}
