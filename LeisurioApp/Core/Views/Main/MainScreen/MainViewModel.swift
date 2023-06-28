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
    
    @Published var isDatePickerShown: Bool = false
    @Published var isRestViewShown: Bool = false
    @Published var restsForSelectedDate = [Rest]()
    @Published var isLoading = false
   
    let categories: [(name: String, imageName: String)] = [
        ("Игры", "gamecontroller.fill"),
        ("Спорт", "sportscourt.fill"),
        ("Хобби", "paintpalette.fill"),
        ("Общение", "message.fill"),
        ("Прогулки", "figure.walk"),
        ("Другое", "ellipsis.circle.fill")
    ]
    
    var userId: String = ""
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func fetchUserUid() async throws -> String {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        return userId
    }
    
    func changeDate(by value: Int) {
        selectedDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
    }
    
    func toggleDatePicker() {
        withAnimation {
            isDatePickerShown.toggle()
        }
    }
    
    func toggleRestView() {
        withAnimation {
            isRestViewShown.toggle()
        }
    }
    
    func closeDatePicker() {
        withAnimation {
            isDatePickerShown = false
        }
    }
    
    func mergeDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(byAdding: timeComponents, to: calendar.date(from: dateComponents)!)!
    }
    
    func getSymbolName(from category: String?) -> String? {
        categories.first(where: { $0.name == category })?.imageName
    }
    
    func updateData() async throws {
        let id = try await fetchUserUid()
        try await getRestsForSelectedDate(userId: id)
    }
    
    func getRestsForSelectedDate(userId: String) async throws {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        do {
            let rests = try await UserManager.shared.getRestsForUserOnDate(userId: userId, date: selectedDate)
            DispatchQueue.main.async {
                self.restsForSelectedDate = rests
                self.isLoading = false
            }
        } catch {
            print("Failed to get rests for selected date: \(error)")
            self.isLoading = false
        }
    }
    
    var sortedRestsForSelectedDate: [(index: Int, rest: Rest)] {
        let calendar = Calendar.current
        return restsForSelectedDate.enumerated().sorted { item1, item2 in
            let (_, rest1) = item1
            let (_, rest2) = item2
            let start1 = rest1.startDate
            let start2 = rest2.startDate
            let time1 = calendar.dateComponents([.hour, .minute], from: start1)
            let time2 = calendar.dateComponents([.hour, .minute], from: start2)
            return time1.hour! < time2.hour! || (time1.hour! == time2.hour! && time1.minute! < time2.minute!)
        }
        .map { (index: $0.offset, rest: $0.element) }
    }

    func deleteRest(at offsets: IndexSet) {
        guard let sortedIndex = offsets.first else { return }
        let (originalIndex, _) = sortedRestsForSelectedDate[sortedIndex]
        let restToDelete = restsForSelectedDate[originalIndex]
        
        Task {
            do {
                try await RestManager.shared.deleteRest(restId: restToDelete.restId)
                NotificationManager.shared.deleteNotification(with: restToDelete.restId)
                DispatchQueue.main.async {
                    self.restsForSelectedDate.remove(at: originalIndex)
                }
            } catch {
                print("Failed to delete rest: \(error)")
            }
        }
    }
    
    func getHourglassSymbol(for rest: Rest) -> String {
        let now = Date()
        let start = rest.startDate
        let end = rest.endDate
        if start <= now && now <= end {
            return "hourglass"
        } else if now < start {
            return "hourglass.bottomhalf.filled"
        } else {
            return "hourglass.tophalf.filled"
        }
    }
}
