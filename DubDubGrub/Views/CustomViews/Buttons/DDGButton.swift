//
//  DDGButton.swift
//  DubDubGrub
//
//  Created by Didar Naurzbayev on 3/4/23.
//

import SwiftUI

struct DDGButton: View {
    
    var buttonTitle: String
    var color: Color = .brandPrimary
    
    var body: some View {
        Text(buttonTitle)
            .bold()
            .frame(width: 280, height: 44)
            .background(color.gradient)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct DDGButton_Previews: PreviewProvider {
    static var previews: some View {
        DDGButton(buttonTitle: "Create profile")
    }
}
