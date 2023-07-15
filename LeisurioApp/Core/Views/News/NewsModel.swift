//
//  NotificationsModel.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 12.07.2023.
//

import Foundation

struct NewsModel: Identifiable {
    var id = UUID()
    var title: String
    var text: String
}
