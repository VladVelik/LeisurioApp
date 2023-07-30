//
//  LogInButtonView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 30.07.2023.
//

import SwiftUI

struct ImageButton: View {
    let action: () -> Void
    let imageName: String
    let text: String
    var isButton: Bool = true
    var systemImage: Bool = true
    
    var body: some View {
        if isButton {
            Button(action: action) {
                buttonContent
            }
        } else {
            buttonContent
        }
    }
    
    private var buttonContent: some View {
        HStack {
            if systemImage {
                Image(systemName: imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .padding(.leading, 20)
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .padding(.leading, 20)
            }
            Spacer()
            Text(text)
                .font(.headline)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.white)
        .foregroundColor(.black)
        .cornerRadius(25)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color.black, lineWidth: 1))
    }
}
