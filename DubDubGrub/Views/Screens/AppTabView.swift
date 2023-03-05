//
//  AppTabView.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            LocationMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .toolbarBackground(.visible, for: .tabBar)
            
            LocationListView()
                .tabItem {
                    Label("Locations", systemImage: "building")
                }
            NavigationView{
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
        }
        .onAppear{ DDGCloudKitManager.shared.getUserRecord() }
        .tint(.brandPrimary)
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
