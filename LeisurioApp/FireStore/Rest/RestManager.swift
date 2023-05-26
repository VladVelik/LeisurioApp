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
}
