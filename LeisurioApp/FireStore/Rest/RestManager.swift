//
//  RestManager.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class RestManager {
    static let shared = RestManager()
    private init() {}
    
    private let restCollection: CollectionReference = Firestore.firestore().collection("rests")
    
    private func userDocument(rest: String) -> DocumentReference {
        restCollection.document(rest)
    }
    
    func createNewRest(rest: Rest) async throws {
        try userDocument(rest: rest.restId).setData(from: rest, merge: false)
    }
    
    func getRest(restId: String) async throws -> Rest {
        try await userDocument(rest: restId).getDocument(as: Rest.self)
    }
    
    func updateRest(rest: Rest) async throws {
        try userDocument(rest: rest.restId).setData(from: rest, merge: true)
    }
    
    func deleteRest(restId: String) async throws {
        try await restCollection.document(restId).delete()

        let usersSnapshot = try await Firestore.firestore().collection("users")
            .whereField("rests", arrayContains: restId).getDocuments()

        for document in usersSnapshot.documents {
            guard let user = try? document.data(as: DBUser.self) else { continue }
            var updatedUser = user
            updatedUser.rests.removeAll { $0 == restId }
            try Firestore.firestore().collection("users").document(user.userId).setData(from: updatedUser)
        }
    }

}
