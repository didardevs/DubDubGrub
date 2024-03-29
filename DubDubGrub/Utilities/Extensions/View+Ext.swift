//
//  View+Ext.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI

extension View {
    
    func profileNameTextStyle() -> some View {
        self.modifier(ProfileNameText())
    }
        
    func embedInScrollView() -> some View {
        GeometryReader { geometry in
            ScrollView {
                self.frame(minHeight: geometry.size.height, maxHeight: .infinity)
            }
        }
    }

}
