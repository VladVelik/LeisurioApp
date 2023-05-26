//
//  StatisticsViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

class StatisticsViewModel: ObservableObject {
    @Published var weeklyRestData: [(date: String, restMinutes: Double)] = []
    @Published var isDataLoading: Bool = false
    @Published var selectedStartDate = Date()
    
    var userId: String = ""

    private let calendar = Calendar.current
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }()
    
    func onAppear() {
        fetchWeeklyRestData()
    }
    
    func fetchWeeklyRestData() {
        Task {
            do {
                let id = try await fetchUserUid()
                await loadWeeklyRestData(forUserId: id, startingFrom: selectedStartDate)
            } catch {
                print("Error: \(error)")
            }
        }
    }

    private func loadWeeklyRestData(forUserId userId: String, startingFrom date: Date) async {
        DispatchQueue.main.async {
            self.isDataLoading = true
        }
        var data: [(date: String, restMinutes: Double)] = []
        
        var dateComponents = DateComponents()
        for day in 0..<7 {
            dateComponents.day = day
            guard let currentDate = calendar.date(byAdding: dateComponents, to: date) else { continue }
            do {
                let rests = try await UserManager.shared.getRestsForUserOnDate(userId: userId, date: currentDate)
                let totalRestMinutes = rests.reduce(0) { (result, rest) in
                    let start = rest.startDate ?? Date()
                    let end = rest.endDate ?? Date()
                    let restDuration = end.timeIntervalSince(start) / 60
                    return result + restDuration
                }
                data.append((date: timeFormatter.string(from: currentDate), restMinutes: totalRestMinutes))
            } catch {
                print("Failed to fetch rests for date \(currentDate): \(error)")
            }
        }
        
        await updateData(data: data)
        DispatchQueue.main.async {
            self.isDataLoading = false
        }
    }
    
    @MainActor
    private func updateData(data: [(date: String, restMinutes: Double)]) {
        self.weeklyRestData = data
    }
    
    func fetchUserUid() async throws -> String {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        return userId
    }
}
