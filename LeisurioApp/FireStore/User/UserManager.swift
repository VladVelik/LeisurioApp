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
            guard let start = $0.startDate, let end = $0.endDate else {
                return false
            }
            let startDay = calendar.startOfDay(for: start)
            let endDay = calendar.startOfDay(for: end)
            
            return startDay >= targetDateStart && endDay < targetDateEnd
        }

        return restsOnDate
    }
}