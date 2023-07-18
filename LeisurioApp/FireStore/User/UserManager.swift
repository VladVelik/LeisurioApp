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
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func updateRestForUser(userId: String, rest: Rest) async throws {
        try await RestManager.shared.updateRest(rest: rest)
    }
    
    func addRestToUser(userId: String, rest: Rest) async throws {
        var user = try await getUser(userId: userId)
        user.rests.append(rest.restId)
        try await RestManager.shared.createNewRest(rest: rest)
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
    func getRestsForUserOnDate(userId: String, date: Date) async throws -> [Rest] {
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
    }
    
    func getAllRestsForUser(userId: String) async throws -> [Rest] {
        let user = try await getUser(userId: userId)
        let restIds = user.rests
        
        var rests = [Rest]()
        for restId in restIds {
            let rest = try await RestManager.shared.getRest(restId: restId)
            rests.append(rest)
        }
        
        return rests
    }
    
    func getRestsForUser(userId: String, startDate: Date, endDate: Date) async throws -> [Rest] {
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
    }
    
    func updateUserName(userId: String, newUserName: String) async throws {
        let userDocument = self.userDocument(userId: userId)
        try await userDocument.updateData(["user_name" : newUserName])
    }
    
    func updateUserPhotoUrl(userId: String, newPhoto: UIImage?) async throws {
        guard let base64Image = newPhoto?.toBase64() else { return }
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).updateData(["photoUrl": base64Image])
    }
}

extension UIImage {
    func toBase64() -> String? {
        return self.jpegData(compressionQuality: 1.0)?.base64EncodedString()
    }
    
    static func fromBase64(_ base64: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
}
