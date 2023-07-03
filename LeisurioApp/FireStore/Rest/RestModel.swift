//
//  RestModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 26.05.2023.
//

import Foundation

struct Rest: Codable, Identifiable {
    let restId: String
    let startDate: Date
    let endDate: Date
    let keyword: String
    let restType: String
    var preRestMood: Int
    var postRestMood: Int
    var finalRestMood: Int
    var isRated: Bool
    
    var id: String {
        restId
    }
    
    init(
        restId: String,
        startDate: Date,
        endDate: Date,
        keyword: String,
        restType: String,
        preRestMood: Int,
        postRestMood: Int,
        finalRestMood: Int,
        isRated: Bool
    ) {
        self.restId = restId
        self.startDate = startDate
        self.endDate = endDate
        self.keyword = keyword
        self.restType = restType
        self.preRestMood = preRestMood
        self.postRestMood = postRestMood
        self.finalRestMood = finalRestMood
        self.isRated = isRated
    }
    
    enum CodingKeys: String, CodingKey {
        case restId = "rest_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case keyword = "keyword"
        case restType = "rest_type"
        case preRestMood = "pre_rest_mood"
        case postRestMood = "post_rest_mood"
        case finalRestMood = "final_rest_mood"
        case isRated = "is_rated"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.restId = try container.decode(String.self, forKey: .restId)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.keyword = try container.decode(String.self, forKey: .keyword)
        self.restType = try container.decode(String.self, forKey: .restType)
        self.preRestMood = try container.decode(Int.self, forKey: .preRestMood)
        self.postRestMood = try container.decode(Int.self, forKey: .postRestMood)
        self.finalRestMood = try container.decode(Int.self, forKey: .finalRestMood)
        self.isRated = try container.decode(Bool.self, forKey: .isRated)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.restId, forKey: .restId)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.endDate, forKey: .endDate)
        try container.encode(self.keyword, forKey: .keyword)
        try container.encode(self.restType, forKey: .restType)
        try container.encode(self.preRestMood, forKey: .preRestMood)
        try container.encode(self.postRestMood, forKey: .postRestMood)
        try container.encode(self.finalRestMood, forKey: .finalRestMood)
        try container.encode(self.isRated, forKey: .isRated)
    }
}
