//
//  ProfileViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI
import PhotosUI

final class ProfileViewModel: ObservableObject {
    @Published var user: DBUser? = nil
    @Published var imageUrl: String? = nil
    
    @Published var isImagePickerPresented = false
    @Published var isLoadingImage = false
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastImage: String = ""
    
    @Published var nearestRest: Rest?
    @Published var todayRestDuration: TimeInterval? = 0
    
    func loadCurrentUser() async throws {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            let userInfo = try await UserManager.shared.getUser(userId: authDataResult.uid)
            
            DispatchQueue.main.async {
                self.user = userInfo
                self.imageUrl = userInfo.photoUrl
            }
            
            let nearRest = try? await getNearestRest(userId: userInfo.userId)
            let todayDuration = try? await getTotalRestDuration(userId: userInfo.userId, date: Date())
            
            DispatchQueue.main.async {
                self.nearestRest = nearRest
                self.todayRestDuration = todayDuration
            }
        } catch {
            print("Failed to load current user: \(error)")
        }
    }
    
    func imageChanging(newValue: PhotosPickerItem?) {
        isLoadingImage = true
        if let newValue {
            saveProfileImage(item: newValue) {
                self.isLoadingImage = false
                self.toastMessage = NSLocalizedString("Profile photo updated!", comment: "")
                self.toastImage = "checkmark.square"
                self.showToast = true
            }
        }
    }
    
    func saveProfileImage(item: PhotosPickerItem, completion: @escaping () -> Void) {
        guard let user else { return }
        
        if (user.photoUrl != "") {
            Task {
                try await self.deleteProfileImage()
            }
        }
        
        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            
            print("SUCCESS!")
            print(path)
            print(name)
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
            try await loadCurrentUser()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func deleteProfileImage() async throws {
        guard let user, let path = user.photoPath else { return }
        
        Task {
            do {
                try await StorageManager.shared.deleteImage(path: path)
            } catch {
                print("Deletion error: \(error)")
            }
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: "", url: "")
        }
    }

}

extension ProfileViewModel {
    func getNearestRest(userId: String) async throws -> Rest? {
        do {
            let allRests = try await UserManager.shared.getAllRestsForUser(userId: userId)
            
            let futureRests = allRests.filter { $0.startDate > Date() }
            return futureRests.min(by: { $0.startDate < $1.startDate })
        } catch {
            print("Failed to get nearest rest: \(error)")
            return nil
        }
    }
    
    func getTotalRestDuration(userId: String, date: Date) async throws -> TimeInterval {
        do {
            let restsOnDate = try await UserManager.shared.getRestsForUserOnDate(userId: userId, date: date)
            let totalDuration = restsOnDate.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            return totalDuration
        } catch {
            print("Failed to get nearest rest: \(error)")
            return 0
        }
    }
}
