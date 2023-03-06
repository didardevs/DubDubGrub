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
            
            NavigationView{  ProfileView() }
            .tabItem { Label("Profile", systemImage: "person") }
        }
        .onAppear{
            DDGCloudKitManager.shared.getUserRecord()
            viewModel.runStartupChecks()
        }
        .tint(.brandPrimary)
        .sheet(isPresented: $viewModel.isShowingOnboardView, onDismiss: viewModel.checkIfLocationServicesIsEnabled) {
            OnBoardingView(isShowingOnboardView: $viewModel.isShowingOnboardView)
        }
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
