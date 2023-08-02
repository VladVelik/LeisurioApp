//
//  NotificationsViewModel.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 12.07.2023.
//

import SwiftUI

enum Texts {
    
    enum NotificationsController {
        
        static var loadingNotifications: String { NSLocalizedString("  loading notifications...", comment: "") }
        static var noNotificationsYet: String { NSLocalizedString("No notifications yet", comment: "") }
        static var noRestToday: String { NSLocalizedString("No rest", comment: "") }
        static var noRestTodayDesc: String { NSLocalizedString("You didn't rest for the past day. Add some rest today", comment: "") }
        static var restToday: String { NSLocalizedString("Rest today", comment: "") }
        static var restTodayDesc: String { NSLocalizedString("Activities today - %d, total time in minutes - %d", comment: "") }
        static var rateRest: String { NSLocalizedString("Rate your rest", comment: "") }
        static var rateRestDesc: String { NSLocalizedString("Number of unrated activities - %d", comment: "") }
        static var needsRest: String { NSLocalizedString("Needs rest", comment: "") }
        static var needsRestDesc: String { NSLocalizedString("You haven't rested for a long time!", comment: "") }
        static var keepItUp: String { NSLocalizedString("Keep it up", comment: "") }
        static var keepItUpDesc: String { NSLocalizedString("You have been resting for %d days in a row. Good job!", comment: "") }
        static var moodBoost: String { NSLocalizedString("Mood boost", comment: "") }
        static var moodBoostDesc: String { NSLocalizedString("Your mood improved today! Great work!", comment: "") }
    }
    
    enum RecommendationsController {
        static let noRecommendations = NSLocalizedString("No recommendations yet", comment: "")
        static let loadingRecommendations = NSLocalizedString("  loading recommendations...", comment: "")
        static let dontForgetRestType = NSLocalizedString("Не забудьте про тип отдыха!", comment: "")
        static let variedRestNeeded = NSLocalizedString("Нужен разнообразный отдых", comment: "")
        static let overlappingRests = NSLocalizedString("Ваши активности пересекаются", comment: "")
        static let longRest = NSLocalizedString("Длинный отдых", comment: "")
        static let excellentRestDistribution = NSLocalizedString("Отличное равномерное распределение времени отдыха!", comment: "")
        static let moreUniformRestDistributionNeeded = NSLocalizedString("Нужно более равномерное распределение времени отдыха", comment: "")
        static let moodWorsensAfterRest = NSLocalizedString("Ваши оценки в среднем ухудшаются после отдыха", comment: "")
        static let restTypeDescription =
            NSLocalizedString("Вы уже более 5 дней не выбирали %@!", comment: "")
        
        static let oneRestTypeOnly = NSLocalizedString("В последние пять дней вы отдыхали только одним способом. Попробуйте что-то новое!", comment: "")
        static let overlappingRestsDescription = NSLocalizedString("Некоторые из ваших активностей пересекаются по времени. Попробуйте уделить внимание планированию своего времени.", comment: "")
        static let longRestDescription = NSLocalizedString("Один из ваших активностей длиннее 12 часов. Постарайтесь разбивать длинные активности на более мелкие.", comment: "")
        static let excellentRestDistributionDescription = NSLocalizedString("Ваше время отдыха равномерно распределено по разным видам активности. Продолжайте в том же духе!", comment: "")
        static let moreUniformRestDistributionNeededDescription = NSLocalizedString("Попробуйте распределить свое время отдыха более равномерно между разными видами активности.", comment: "")
        static let moodWorsensAfterRestDescription = NSLocalizedString("Обратите внимание, что ваши оценки самочувствия ухудшаются после отдыха. Попробуйте изменить вид отдыха или его продолжительность.", comment: "")
    }
}


class NotificationsViewModel: ObservableObject, ListViewModel {
    @Published var items: [NewsModel] = []
    @Published var text = Texts.NotificationsController.noNotificationsYet
    
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
                    self.text = Texts.NotificationsController.loadingNotifications
                }
                self.userId = try await fetchUserUid()
                let calendar = Calendar.current
                let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
                
                let rests = try await UserManager.shared.getRestsForUser(userId: self.userId, startDate: thirtyDaysAgo, endDate: Date())
                
                await self.updateNotifications(with: rests)
                self.didLoadNotifications = true
                DispatchQueue.main.async {
                    self.text = Texts.NotificationsController.noNotificationsYet
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
            self.items.append(NewsModel(title: Texts.NotificationsController.noRestToday,
                                        text: Texts.NotificationsController.noRestTodayDesc))
        } else {
            let times = oneDayRests.count
            let sum = oneDayRests.reduce(0) { $0 + Int($1.endDate.timeIntervalSince($1.startDate) / 60) }
            
            self.items.append(NewsModel(title: Texts.NotificationsController.restToday,
                                        text: String(format: Texts.NotificationsController.restTodayDesc, times, sum)))
        }
    }
    
    private func checkUnratedRests(rests: [Rest], currentDate: Date) {
        let unratedRests = rests.filter { !$0.isRated && $0.endDate < currentDate }.count
        if unratedRests > 0 {
            self.items.append(NewsModel(title: Texts.NotificationsController.rateRest,
                                        text: String(format: Texts.NotificationsController.rateRestDesc, unratedRests)))
        }
    }
    
    private func checkRestInLastThreeDays(rests: [Rest], currentDate: Date) {
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: currentDate)!
        let recentRests = rests.filter { $0.endDate > threeDaysAgo }
        
        if recentRests.isEmpty {
            self.items.append(NewsModel(title: Texts.NotificationsController.needsRest,
                                        text: Texts.NotificationsController.needsRestDesc))
        }
    }
    
    private func checkRestStreak(rests: [Rest]) {
        let restDaysStreak = self.computeRestDaysStreak(rests: rests)
        if restDaysStreak >= 3 {
            self.items.append(NewsModel(title: Texts.NotificationsController.keepItUp,
                                        text: String(format: Texts.NotificationsController.keepItUpDesc, restDaysStreak)))
        }
    }
    
    private func checkMoodImprovementToday(rests: [Rest], currentDate: Date) {
        let today = Calendar.current.startOfDay(for: currentDate)
        if rests.first(where: {
            Calendar.current.isDate($0.startDate, inSameDayAs: today) &&
            $0.postRestMood > $0.preRestMood }) != nil {
            self.items.append(NewsModel(title: Texts.NotificationsController.moodBoost,
                                        text: Texts.NotificationsController.moodBoostDesc))
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

