//
//  SmallPrimaryButton.swift
//  PageTurnerBooks
//
//  Created by Staff on 07/05/2024.
//

import SwiftUI

struct SmallPrimaryButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action){
            Text(title)
        }
        .font(.system(size: 15, weight: .bold, design: .default))
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(LinearGradient(gradient: Gradient(colors: [Color.pTPrimary.opacity(0.8), Color.pTPrimary]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .foregroundColor(Color.white)
        .font(.system(size: 20, weight: .bold, design: .default))
        .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
        .frame(minWidth: 100, idealWidth: .infinity, maxWidth: .infinity, minHeight: 50, idealHeight: 50, maxHeight: 50, alignment: .center)
    }
}

struct SmallPrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        SmallPrimaryButton(title: "Test Button", action: {
            print("preview button tapped")})
        
    }
}
