//
//  SignInEmailView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 16.05.2023.
//

import SwiftUI

struct SignInEmailView: View {
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .cornerRadius(10)
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .cornerRadius(10)
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign in")
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign in with Email")
    }
}
