//
//  CreateRestModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 28.06.2023.
//

import Foundation

struct CreateRestModel {
    var startTime: Date = Date()
    var endTime: Date = Date()
    var restNote: String = ""
    var selectedCategory: String = ""
    
    var isIncorrect: Bool {
        endTime < startTime || restNote.isEmpty || restNote.count > 15 || selectedCategory == ""
    }
}
