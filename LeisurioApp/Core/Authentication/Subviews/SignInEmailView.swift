//
//  SignInEmailView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 16.05.2023.
//

import SwiftUI

struct AlertItem: Identifiable {
    var id = UUID()
    var title: String
    var message: String
}

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    @Binding var isSignIn: Bool
    
    @State var alertItem: AlertItem?
    
    var body: some View {
        VStack {
            Text(isSignIn ? NSLocalizedString("Sign In ", comment: "") : NSLocalizedString("Sign Up ", comment: ""))
                .font(.title)
                .bold()
                .foregroundColor(.black)
                .padding()
            TextFieldStyleView(title: "Email", text: $viewModel.email, isSecure: false, color: .white)
            TextFieldStyleView(title: NSLocalizedString("Password", comment: ""), text: $viewModel.password, isSecure: true, color: .white)
                
            Button {
                Task {
                    do {
                        if isSignIn {
                            try await viewModel.signIn()
                        } else {
                            try await viewModel.signUp()
                        }
                        showSignInView = false
                    } catch let error as LocalizedError {
                        alertItem = AlertItem(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString(error.localizedDescription, comment: ""))
                    }
                }
            } label: {
                Text(isSignIn ? NSLocalizedString("Sign In", comment: "") : NSLocalizedString("Sign Up", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .alert(item: $alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            Spacer()
        }
        .padding()
        .background(
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .offset(x: -UIScreen.main.bounds.width / 6)
                .opacity(0.3)
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
