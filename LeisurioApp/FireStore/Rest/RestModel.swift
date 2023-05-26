//
//  RestModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 26.05.2023.
//

import Foundation

struct Rest: Codable, Identifiable {
    let restId: String
    let startDate: Date?
    let endDate: Date?
    let keyword: String?
    
    var id: String {
        restId
    }
    
    init(restId: String, startDate: Date, endDate: Date, keyword: String) {
        self.restId = restId
        self.startDate = startDate
        self.endDate = endDate
        self.keyword = keyword
    }
    
    enum CodingKeys: String, CodingKey {
        case restId = "rest_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case keyword = "keyword"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.restId = try container.decode(String.self, forKey: .restId)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.keyword = try container.decode(String.self, forKey: .keyword)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.restId, forKey: .restId)
        try container.encode(self.startDate, forKey: .startDate)
        try container.encode(self.endDate, forKey: .endDate)
        try container.encode(self.keyword, forKey: .keyword)
    }
}
