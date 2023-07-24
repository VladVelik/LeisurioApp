//
//  NotificationsViewModel.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 12.07.2023.
//

import SwiftUI

class NotificationsViewModel: ObservableObject, ListViewModel {
    @Published var items: [NewsModel] = []
    @Published var text = "Уведомлений нет"
    
    private var didLoadNotifications = false

    var userId: String = ""

    init() {
        fetchRests()
    }
    
    func toggleLoadNotifications() {
        didLoadNotifications = false
    }
    
    func refresh() {
        didLoadNotifications = false
        fetchRests()
    }
    
    func fetchRests() {
        guard !didLoadNotifications else { return }
        
        Task {
            do {
                DispatchQueue.main.async {
                    self.text = "  загрузка уведомлений..."
                }
                self.userId = try await fetchUserUid()
                let calendar = Calendar.current
                let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
                            
                let rests = try await UserManager.shared.getRestsForUser(userId: self.userId, startDate: thirtyDaysAgo, endDate: Date())

                await self.updateNotifications(with: rests)
                self.didLoadNotifications = true
                DispatchQueue.main.async {
                    self.text = "Уведомлений нет"
                }
            } catch {
                print("Failed to get rests: \(error)")
            }
        }
    }
    
    func fetchUserUid() async throws -> String {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        return userId
    }

    private func updateNotifications(with rests: [Rest]) async {
        DispatchQueue.main.async {
            let now = Date()
            self.items.removeAll()
            let sortedRests = rests.sorted { $0.startDate > $1.startDate }

            self.checkRestInLastDay(rests: rests, currentDate: now)
            self.checkUnratedRests(rests: rests, currentDate: now)
            self.checkRestInLastThreeDays(rests: rests, currentDate: now)
            self.checkRestStreak(rests: sortedRests)
            self.checkMoodImprovementToday(rests: rests, currentDate: now)
        }
    }

    private func checkRestInLastDay(rests: [Rest], currentDate: Date) {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        let oneDayRests = rests.filter { $0.endDate > oneDayAgo }

        if oneDayRests.isEmpty {
            self.items.append(NewsModel(title: "Нет отдыха", text: "За последний день вы не отдыхали. Добавьте отдых сегодня"))
        } else {
            let times = oneDayRests.count
            let sum = oneDayRests.reduce(0) { $0 + Int($1.endDate.timeIntervalSince($1.startDate) / 60) }
            
            self.items.append(NewsModel(title: "Отдых сегодня", text: "Количество активностей сегодня - \(times), общее время в минутах - \(sum)"))
        }
    }

    private func checkUnratedRests(rests: [Rest], currentDate: Date) {
        let unratedRests = rests.filter { !$0.isRated && $0.endDate < currentDate }.count
        if unratedRests > 0 {
            self.items.append(NewsModel(title: "Оцените отдых", text: "Количество неоцененных активностей - \(unratedRests)"))
        }
    }

    private func checkRestInLastThreeDays(rests: [Rest], currentDate: Date) {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: currentDate)!
        let recentRests = rests.filter { $0.endDate > threeDaysAgo }

        if recentRests.isEmpty {
            self.items.append(NewsModel(title: "Нужен отдых", text: "Вы давно не отдыхали!"))
        }
    }

    private func checkRestStreak(rests: [Rest]) {
        let restDaysStreak = self.computeRestDaysStreak(rests: rests)
        if restDaysStreak >= 3 {
            self.items.append(NewsModel(title: "Продолжайте в том же духе!", text: "Вы отдыхаете уже \(restDaysStreak) дней подряд. Отличная работа!"))
        }
    }

    private func checkMoodImprovementToday(rests: [Rest], currentDate: Date) {
        let today = Calendar.current.startOfDay(for: currentDate)
        if rests.first(where: {
            Calendar.current.isDate($0.startDate, inSameDayAs: today) &&
            $0.postRestMood > $0.preRestMood }) != nil {
            self.items.append(NewsModel(title: "Повышение настроения", text: "Ваше настроение за день улучшилось! Отличная работа!"))
        }
    }
    
    private func computeRestDaysStreak(rests: [Rest], timeZone: TimeZone = TimeZone.current) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        var currentDate = calendar.startOfDay(for: Date())

        var streak = 0
        for _ in 0..<30 {
            if rests.first(where: { calendar.isDate($0.startDate, inSameDayAs: currentDate) }) != nil {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                print("No rest found on date: \(currentDate)")
                break
            }
        }

        return streak
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
