//
//  AppTabView.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI

struct AppTabView: View {
    
    @StateObject private var viewModel = AppTabViewModel()
    
    var body: some View {
        TabView {
            LocationMapView()
                .tabItem { Label("Map", systemImage: "map") }
                .toolbarBackground(.visible, for: .tabBar)
            
            LocationListView()
                .tabItem { Label("Locations", systemImage: "building") }
            
            NavigationStack {  ProfileView() }
            .tabItem { Label("Profile", systemImage: "person") }
        }
        .task {
            try? await DDGCloudKitManager.shared.getUserRecord()
            viewModel.checkIfHasSeenOnboard()
        }
        .sheet(isPresented: $viewModel.isShowingOnboardView) {
            OnBoardingView()
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
