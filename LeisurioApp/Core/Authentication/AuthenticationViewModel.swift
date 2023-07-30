//
//  AuthenticationViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

@MainActor
final class AuthenticationViewModel: ObservableObject {
    func signWithGoogle(isSignIn: Bool) async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        
        let userExists = try await UserManager.shared.userExists(user: user)
        
        if userExists && !isSignIn {
            print("Account already exists.")
            try AuthenticationManager.shared.signOut()
            
            throw GoogleError.accountAlreadyExists
        } else if !userExists && isSignIn {
            print("No account exists.")
            try AuthenticationManager.shared.delete()
            try AuthenticationManager.shared.signOut()
            
            throw GoogleError.noAccountExists
        } else if !userExists {
            try await UserManager.shared.createNewUser(user: user)
            print("Registration successful.")
        } else {
            print("Authorization successful.")
        }
    }
}
