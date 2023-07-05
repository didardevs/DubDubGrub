//
//  LocationListView.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI

struct LocationListView: View {
    
    @EnvironmentObject private var locationManager: DDGLocationManager
    @StateObject private var viewModel = LocationListViewModel()
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locationManager.locations) { location in
                    NavigationLink(destination: viewModel.createLocationDetailView(for: location, in: dynamicTypeSize)) {
                        LocationCell(location: location, profiles: viewModel.checkedInProfiles[location.id, default: []])
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text(viewModel.createVoiceOverSummary(for: location)))
                    }
                }
            }
            .navigationTitle("Grub Spots")
            .listStyle(.plain)
            .task { await viewModel.getCheckedInProfileDictionary() }
            .refreshable { await viewModel.getCheckedInProfileDictionary() }
            .alert(item: $viewModel.alertItem, content: { $0.alert })
        }
    }
}

struct LocationListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationListView()
    }
}
