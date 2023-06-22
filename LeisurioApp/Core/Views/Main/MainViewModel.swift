//
//  MainViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 26.05.2023.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    @Published var selectedDate: Date = Date() {
        didSet {
            Task {
                try await getRestsForSelectedDate(userId: userId)
            }
        }
    }
    @Published var selectedCategory: String = ""
    @Published var isDatePickerShown: Bool = false
    @Published var isRestViewShown: Bool = false
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var restNote: String = ""
    @Published var restsForSelectedDate = [Rest]()
    
    var userId: String = ""
    
    func clearData() {
        startTime = Date() // или какое-то другое начальное значение
        endTime = Date() // или какое-то другое начальное значение
        restNote = ""
        selectedCategory = "" // или какое-то другое начальное значение
    }
    
    var isIncorrect: Bool {
        endTime < startTime || restNote.isEmpty || restNote.count > 10
    }
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func fetchUserUid() async throws -> String {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        return userId
    }
    
    func addNewRest(restId: String, startDate: Date, endDate: Date, keyword: String, restType: String) async throws {
        let newRest = Rest(
            restId: restId,
            startDate: startDate,
            endDate: endDate,
            keyword: keyword,
            restType: restType
        )
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.addRestToUser(userId: authDataResult.uid, rest: newRest)
            print("Rest added successfully")
            
            NotificationManager.shared.saveNotification(restId: restId, startDate: startDate, endDate: endDate, note: keyword)
            NotificationManager.shared.scheduleNotification(restId: restId, startDate: startDate, endDate: endDate, note: keyword)

            try await getRestsForSelectedDate(userId: authDataResult.uid)
        } catch {
            print("Failed to add rest: \(error)")
        }
    }
    
    func changeDate(by value: Int) {
        selectedDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
    }
    
    func toggleDatePicker() {
        withAnimation {
            isDatePickerShown.toggle()
        }
    }
    
    func closeDatePicker() {
        withAnimation {
            isDatePickerShown = false
        }
    }
    
    func toggleRestView() {
        withAnimation {
            isRestViewShown.toggle()
        }
    }
    
    func mergeDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(byAdding: timeComponents, to: calendar.date(from: dateComponents)!)!
    }
    
    func getRestsForSelectedDate(userId: String) async throws {
        do {
            let rests = try await UserManager.shared.getRestsForUserOnDate(userId: userId, date: selectedDate)
            DispatchQueue.main.async {
                self.restsForSelectedDate = rests
            }
            
        } catch {
            print("Failed to get rests for selected date: \(error)")
        }
    }
    
    func deleteRest(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let restToDelete = restsForSelectedDate[index]

        Task {
            do {
                try await RestManager.shared.deleteRest(restId: restToDelete.restId)
                DispatchQueue.main.async {
                    self.restsForSelectedDate.remove(at: index)
                }
            } catch {
                print("Failed to delete rest: \(error)")
            }
        }
    }

}
