//
//  TextFieldStyleView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 21.07.2023.
//

import SwiftUI

struct TextFieldStyleView: View {
    var title: String
    @Binding var text: String
    var isSecure: Bool
    var color = Color(.systemGray6)
    
    var body: some View {
        VStack {
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
            }
        }
        .padding()
        .background(color)
        .cornerRadius(8)
        .padding(.bottom, 10)
    }
}
