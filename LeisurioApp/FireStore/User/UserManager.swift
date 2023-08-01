//
//  UserManager.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class UserManager {
    static let shared = UserManager()
    private init() {}
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: DBUser) async throws {
        do {
            try userDocument(userId: user.userId).setData(from: user, merge: false)
        } catch {
            throw error
        }
    }
    
    func getUser(userId: String) async throws -> DBUser {
        do {
            return try await userDocument(userId: userId).getDocument(as: DBUser.self)
        } catch {
            throw error
        }
    }
    
    func updateRestForUser(userId: String, rest: Rest) async throws {
        do {
            try await RestManager.shared.updateRest(rest: rest)
        } catch {
            throw error
        }
    }
    
    func addRestToUser(userId: String, rest: Rest) async throws {
        do {
            var user = try await getUser(userId: userId)
            user.rests.append(rest.restId)
            try await RestManager.shared.createNewRest(rest: rest)
            try userDocument(userId: user.userId).setData(from: user, merge: false)
        } catch {
            throw error
        }
    }
    
    func getRestsForUserOnDate(userId: String, date: Date) async throws -> [Rest] {
        do {
            let user = try await getUser(userId: userId)
            let restIds = user.rests
            var rests = [Rest]()
            for restId in restIds {
                let rest = try await RestManager.shared.getRest(restId: restId)
                rests.append(rest)
            }
            
            let calendar = Calendar.current
            let targetDateStart = calendar.startOfDay(for: date)
            guard let targetDateEnd = calendar.date(byAdding: .day, value: 1, to: targetDateStart) else {
                return []
            }
            
            let restsOnDate = rests.filter {
                let start = $0.startDate
                let end = $0.endDate
                
                let startDay = calendar.startOfDay(for: start)
                let endDay = calendar.startOfDay(for: end)
                
                return startDay >= targetDateStart && endDay < targetDateEnd
            }
            
            return restsOnDate
        } catch {
            throw error
        }
    }
    
    func getAllRestsForUser(userId: String) async throws -> [Rest] {
        do {
            let user = try await getUser(userId: userId)
            let restIds = user.rests
            
            var rests = [Rest]()
            for restId in restIds {
                let rest = try await RestManager.shared.getRest(restId: restId)
                rests.append(rest)
            }
            
            return rests
        } catch {
            throw error
        }
    }
    
    func getRestsForUser(userId: String, startDate: Date, endDate: Date) async throws -> [Rest] {
        do {
            let user = try await getUser(userId: userId)
            let restIds = user.rests
            
            var rests = [Rest]()
            for restId in restIds {
                let rest = try await RestManager.shared.getRest(restId: restId)
                rests.append(rest)
            }
            
            let calendar = Calendar.current
            let targetStartDate = calendar.startOfDay(for: startDate)
            guard let targetEndDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) else {
                return []
            }
            
            let restsInRange = rests.filter {
                let start = $0.startDate
                let end = $0.endDate
                
                let startDay = calendar.startOfDay(for: start)
                let endDay = calendar.startOfDay(for: end)
                
                return (startDay >= targetStartDate && startDay < targetEndDate) || (endDay >= targetStartDate && endDay < targetEndDate)
            }
            
            return restsInRange
        } catch {
            throw error
        }
    }
    
    func updateEmail(userId: String, newEmail: String) async throws {
        do {
            let userDocument = self.userDocument(userId: userId)
            try await userDocument.updateData(["email" : newEmail])
        } catch {
            throw error
        }
    }
    
    func updateUserName(userId: String, newUserName: String) async throws {
        do {
            let userDocument = self.userDocument(userId: userId)
            try await userDocument.updateData(["user_name" : newUserName])
        } catch {
            throw error
        }
    }
    
    func updateUserProfileImagePath(userId: String, path: String, url: String) async throws {
        do {
            let data: [String:Any] = [
                DBUser.CodingKeys.photoPath.rawValue : path,
                DBUser.CodingKeys.photoUrl.rawValue : url,
            ]
            
            try await userDocument(userId: userId).updateData(data)
        } catch {
            throw error
        }
    }
    
    func deleteUser(userId: String) async throws {
        do {
            let allRestsForUser = try await self.getAllRestsForUser(userId: userId)
            
            for rest in allRestsForUser {
                try await RestManager.shared.deleteRest(restId: rest.restId)
            }
            
            let user = try await self.getUser(userId: userId)
            
            if let photoPath = user.photoPath {
                try await StorageManager.shared.deleteImage(path: photoPath)
            }
            
            try await userDocument(userId: userId).delete()
        } catch {
            throw error
        }
    }
    
    func userExists(user: DBUser) async throws -> Bool {
        do {
            let documentSnapshot = try await userDocument(userId: user.userId).getDocument()
            return documentSnapshot.exists
        } catch {
            throw error
        }
    }
}
