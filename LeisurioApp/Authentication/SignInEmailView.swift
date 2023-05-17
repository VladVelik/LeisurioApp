//
//  SignInEmailView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 16.05.2023.
//

import SwiftUI

final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("email or password not found")
            return
        }
        
        try await AuthenticationManager.shared.createUser(
            email: email,
            password: password
        )
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("email or password not found")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(
            email: email,
            password: password
        )
    }
}

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

struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInEmailView(showSignInView: .constant(false))
        }
    }
}
