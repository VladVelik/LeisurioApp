//
//  UserModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 26.05.2023.
//

import Foundation

struct DBUser: Codable {
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    var rests: [String]
    var userName: String?
    var numOfRests: Int
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
        self.rests = []
        self.userName = "User"
        self.numOfRests = 0
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case rests = "rests"
        case userName = "user_name"
        case numOfRests = "num_of_rests"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.rests = try container.decodeIfPresent([String].self, forKey: .rests) ?? []
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
        self.numOfRests = try container.decodeIfPresent(Int.self, forKey: .numOfRests) ?? 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.rests, forKey: .rests)
        try container.encodeIfPresent(self.userName, forKey: .userName)
        try container.encodeIfPresent(self.numOfRests, forKey: .numOfRests)
    }
}
