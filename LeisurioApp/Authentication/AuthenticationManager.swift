//
//  AuthenticationManager.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 16.05.2023.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    var userName: String?
    
    init(_ user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.userName = user.displayName
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() {}
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func delete() throws {
        Auth.auth().currentUser?.delete { error in
          if let error = error {
            print(error.localizedDescription)
          } else {
            print("Success deleting")
          }
        }
    }
}

// MARK: Sign in Email
extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        do {
            let deviceLanguage = Locale.current.language.languageCode?.identifier
            Auth.auth().languageCode = deviceLanguage == "ru" ? "ru" : "en"
            
            let authData = try await Auth.auth().createUser(withEmail: email, password: password)
            let user = authData.user
            
            try await user.sendEmailVerification()
            
            try AuthenticationManager.shared.signOut()
            
            return AuthDataResultModel(user)
        } catch {
            let nsError = error as NSError
            switch nsError.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                throw SignUpError.emailAlreadyInUse
            case AuthErrorCode.invalidEmail.rawValue:
                throw SignUpError.invalidEmail
            default:
                throw SignUpError.unknownError
            }
        }
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        do {
            let authData = try await Auth.auth().signIn(withEmail: email, password: password)
            
            if (Auth.auth().currentUser?.isEmailVerified == false) {
                try AuthenticationManager.shared.signOut()
                throw AuthErrorCode(.appNotVerified)
            }
            
            return AuthDataResultModel(authData.user)
        } catch {
            let nsError = error as NSError
            switch nsError.code {
            case AuthErrorCode.userNotFound.rawValue:
                throw SignInError.userNotFound
            case AuthErrorCode.wrongPassword.rawValue:
                throw SignInError.wrongPassword
            case AuthErrorCode.invalidEmail.rawValue:
                throw SignInError.badEmail
            case AuthErrorCode.appNotVerified.rawValue:
                throw SignInError.notVerified
            default:
                throw SignInError.unknownError
            }
        }
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
}

// MARK: SIGN IN SSO
extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInesultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(authDataResult.user)
    }
}
