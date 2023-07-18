//
//  ProfileViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    @Published var imageUrl: String? = nil

    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let userInfo = try await UserManager.shared.getUser(userId: authDataResult.uid)
        DispatchQueue.main.async {
            self.user = userInfo
            self.imageUrl = userInfo.photoUrl
        }
    }
    
    func updateUserName(newUserName: String) async throws {
        guard let userId = user?.userId else { return }
        try await UserManager.shared.updateUserName(userId: userId, newUserName: newUserName)
        try await loadCurrentUser()
    }
    
    func updateUserPhotoUrl(newPhoto: UIImage?) async throws {
        guard let userId = user?.userId else { return }
        try await UserManager.shared.updateUserPhotoUrl(userId: userId, newPhoto: newPhoto)
        try await loadCurrentUser()
    }

}
