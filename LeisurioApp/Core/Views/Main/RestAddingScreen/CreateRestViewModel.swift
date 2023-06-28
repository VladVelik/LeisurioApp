//
//  CreateRestViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 28.06.2023.
//

import SwiftUI

final class CreateRestViewModel: ObservableObject {
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var restNote: String = ""
    @Published var selectedCategory: String = ""
    
    func clearData() {
        startTime = Date()
        endTime = Date()
        restNote = ""
        selectedCategory = ""
    }
    
    var isIncorrect: Bool {
        endTime < startTime || restNote.isEmpty || restNote.count > 15 || selectedCategory == ""
    }
    
    func mergeDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(byAdding: timeComponents, to: calendar.date(from: dateComponents)!)!
    }
    
    func addNewRest(
        restId: String,
        startDate: Date,
        endDate: Date,
        keyword: String,
        restType: String,
        preRestMood: Int = 3,
        postRestMood: Int = 3,
        finalRestMood: Int = 3
    ) async throws {
        let newRest = Rest(
            restId: restId,
            startDate: startDate,
            endDate: endDate,
            keyword: keyword,
            restType: restType,
            preRestMood: preRestMood,
            postRestMood: postRestMood,
            finalRestMood: finalRestMood
        )
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.addRestToUser(userId: authDataResult.uid, rest: newRest)
            print("Rest added successfully")
            
            NotificationManager.shared.saveNotification(restId: restId, startDate: startDate, endDate: endDate, note: keyword)
            NotificationManager.shared.scheduleNotification(restId: restId, startDate: startDate, endDate: endDate, note: keyword)
        } catch {
            print("Failed to add rest: \(error)")
        }
    }
}
