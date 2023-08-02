//
//  SignInEmailViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

final class SignInEmailViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    func generalCheck() throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("email or password not found")
            throw SignInError.loginDetailsNil
        }
        
        if (password.count < 8) {
            throw SignInError.shortPassword
        }
    }
    
    func signUp() async throws {
        try generalCheck()
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        
        throw SignInError.notVerified
    }
    
    func signIn() async throws {
        try generalCheck()
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
