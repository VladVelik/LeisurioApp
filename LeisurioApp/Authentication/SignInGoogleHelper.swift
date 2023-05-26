//
//  SignInGoogleHelper.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 17.05.2023.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInesultModel {
    let idToken: String
    let accessToken: String
    
}

final class SignInGoogleHelper {
    @MainActor
    func signIn() async throws -> GoogleSignInesultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let didSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
                
        guard let idToken = didSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = didSignInResult.user.accessToken.tokenString
        let tokens = GoogleSignInesultModel(idToken: idToken, accessToken: accessToken)
        
        return tokens
    }
}
