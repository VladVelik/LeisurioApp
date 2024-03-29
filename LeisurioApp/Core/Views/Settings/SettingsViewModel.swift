//
//  SettingsViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 24.05.2023.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published private var user: DBUser? = nil
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastImage: String = ""
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    func loadCurrentUser() async throws {
        //self.user = try AuthenticationManager.shared.getAuthenticatedUser()
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let userInfo = try await UserManager.shared.getUser(userId: authDataResult.uid)
        DispatchQueue.main.async {
            self.user = userInfo
        }
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
        changeAccount()
    }
    
    func deleteAccount() async throws {
        try AuthenticationManager.shared.delete()
        try AuthenticationManager.shared.signOut()
        try await UserManager.shared.deleteUser(userId: user?.userId ?? "")
        changeAccount()
    }
    
    func changeAccount() {
        NotificationManager.shared.removeAllNotifications()
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail(newEmail: String) async throws {
        try await AuthenticationManager.shared.updateEmail(email: newEmail)
        guard let userId = user?.userId else { return }
        try await UserManager.shared.updateEmail(userId: userId, newEmail: newEmail)
    }
    
    func updatePassword(newPassword: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: newPassword)
    }
    
    func updateUserName(newUserName: String) async throws {
        guard let userId = user?.userId else { return }
        try await UserManager.shared.updateUserName(userId: userId, newUserName: newUserName)
    }
}
