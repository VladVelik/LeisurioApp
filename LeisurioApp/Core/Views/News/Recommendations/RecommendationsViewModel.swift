//
//  RecommendationsViewModel.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 14.07.2023.
//

import SwiftUI

class RecommendationsViewModel: ObservableObject, ListViewModel {
    @Published var items: [NewsModel] = []
    @Published var text = Texts.RecommendationsController.noRecommendations
    
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
                    self.text = Texts.RecommendationsController.loadingRecommendations
                }
                self.userId = try await fetchUserUid()
                let calendar = Calendar.current
                let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date())!
                            
                let rests = try await UserManager.shared.getRestsForUser(userId: self.userId, startDate: thirtyDaysAgo, endDate: Date())

                await self.updateNotifications(with: rests)
                self.didLoadNotifications = true
                DispatchQueue.main.async {
                    self.text = Texts.RecommendationsController.noRecommendations
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
            
            let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: now)!
            let recentRests = rests.filter { $0.endDate > fiveDaysAgo }
            
            self.checkRestTypeNotUsed(recentRests: recentRests, currentDate: now)
            self.checkRestVariety(recentRests: recentRests)
            self.checkRestOverlap(recentRests: recentRests)
            self.checkLongRests(recentRests: recentRests)
            self.checkRestDurationDistribution(recentRests: recentRests)
            self.checkMoodChange(recentRests: recentRests)
        }
    }

    private func checkRestTypeNotUsed(recentRests: [Rest], currentDate: Date) {
        let restTypes = [NSLocalizedString("Игры", comment: ""),
                         NSLocalizedString("Спорт", comment: ""),
                         NSLocalizedString("Хобби", comment: ""),
                         NSLocalizedString("Общение", comment: ""),
                         NSLocalizedString("Прогулки", comment: "")]
        
        for type in restTypes {
            let recentRestsOfType = recentRests.filter { $0.restType == type }
            //var typ = NSLocalizedString(type, comment: "")
            if recentRestsOfType.isEmpty {
                self.items.append(NewsModel(title: Texts.RecommendationsController.dontForgetRestType, text: String(format: Texts.RecommendationsController.restTypeDescription, type)))
            }
        }
    }

    private func checkRestVariety(recentRests: [Rest]) {
        let recentRestTypes = Set(recentRests.map { $0.restType })
        
        if recentRestTypes.count < 2 {
            self.items.append(NewsModel(title: Texts.RecommendationsController.variedRestNeeded, text: Texts.RecommendationsController.oneRestTypeOnly))
        }
    }

    private func checkRestOverlap(recentRests: [Rest]) {
        var overlappingRests = false
        var previousRest: Rest? = nil
        
        for rest in recentRests {
            if let prevRest = previousRest, rest.startDate < prevRest.endDate {
                overlappingRests = true
                break
            }
            previousRest = rest
        }
        
        if overlappingRests {
            self.items.append(NewsModel(title: Texts.RecommendationsController.overlappingRests, text: Texts.RecommendationsController.overlappingRestsDescription))
        }
    }

    private func checkLongRests(recentRests: [Rest]) {
        var longRest = false
        
        for rest in recentRests {
            let time = rest.endDate.timeIntervalSince(rest.startDate)
            
            if time > 12 * 60 * 60 {
                longRest = true
                break
            }
        }
        
        if longRest {
            self.items.append(NewsModel(title: Texts.RecommendationsController.longRest, text: Texts.RecommendationsController.longRestDescription))
        }
    }

    private func checkRestDurationDistribution(recentRests: [Rest]) {
        var restTypeTimes: [String: Double] = [:]
        
        for rest in recentRests {
            let time = rest.endDate.timeIntervalSince(rest.startDate)
            restTypeTimes[rest.restType, default: 0] += time
        }
        
        let meanTime = restTypeTimes.values.reduce(0, +) / Double(restTypeTimes.count)
        let squaredDifferences = restTypeTimes.values.map { pow($0 - meanTime, 2) }
        let variance = squaredDifferences.reduce(0, +) / Double(squaredDifferences.count)
        let standardDeviation = sqrt(variance)
        
        if standardDeviation <= meanTime * 0.2 {
            self.items.append(NewsModel(title: Texts.RecommendationsController.excellentRestDistribution, text: Texts.RecommendationsController.excellentRestDistributionDescription))
        } else {
            self.items.append(NewsModel(title: Texts.RecommendationsController.moreUniformRestDistributionNeeded, text: Texts.RecommendationsController.moreUniformRestDistributionNeededDescription))
        }
    }

    private func checkMoodChange(recentRests: [Rest]) {
        var beforeRestRatings: [Int] = []
        var afterRestRatings: [Int] = []
        
        for rest in recentRests {
            beforeRestRatings.append(rest.preRestMood)
            afterRestRatings.append(rest.postRestMood)
        }
        
        if beforeRestRatings.isEmpty {
            return
        }
        
        let meanBeforeRestRating = beforeRestRatings.reduce(0, +) / beforeRestRatings.count
        let meanAfterRestRating = afterRestRatings.reduce(0, +) / afterRestRatings.count
        
        if meanBeforeRestRating > meanAfterRestRating {
            self.items.append(NewsModel(title: Texts.RecommendationsController.moodWorsensAfterRest, text: Texts.RecommendationsController.moodWorsensAfterRestDescription))
        }
    }
    
    private func computeRestDaysStreak(rests: [Rest], timeZone: TimeZone = TimeZone.current) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        
        var restDays = Set<Date>()
        for rest in rests {
            let startDate = calendar.startOfDay(for: rest.startDate)
            let endDate = calendar.startOfDay(for: rest.endDate)
            var date = startDate
            while date <= endDate {
                restDays.insert(date)
                date = calendar.date(byAdding: .day, value: 1, to: date)!
            }
        }
        
        let sortedRestDays = restDays.sorted(by: <)
        var previousDay: Date? = nil
        var currentStreak = 1
        var maxStreak = 1
        for day in sortedRestDays {
            if let prevDay = previousDay, calendar.isDate(day, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: prevDay)!) {
                currentStreak += 1
                if currentStreak > maxStreak {
                    maxStreak = currentStreak
                }
            } else {
                currentStreak = 1
            }
            previousDay = day
        }
        
        return maxStreak
    }
    
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
