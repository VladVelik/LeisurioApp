//
//  RecommendationsViewModel.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 14.07.2023.
//

import SwiftUI

class RecommendationsViewModel: ObservableObject, ListViewModel {
    @Published var items: [NewsModel] = []
    @Published var text = "Рекомендаций нет"
    
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
                    self.text = "  загрузка рекомендаций..."
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
        let restTypes = ["игры", "спорт", "хобби", "общение", "прогулки"]
        
        for type in restTypes {
            let recentRestsOfType = recentRests.filter { $0.restType == type }
            
            if recentRestsOfType.isEmpty {
                self.items.append(NewsModel(title: "Не забудьте про тип отдыха!", text: "Вы уже более 5 дней не выбирали \(type)!"))
            }
        }
    }

    private func checkRestVariety(recentRests: [Rest]) {
        let recentRestTypes = Set(recentRests.map { $0.restType })
        
        if recentRestTypes.count < 2 {
            self.items.append(NewsModel(title: "Нужен разнообразный отдых", text: "В последние пять дней вы отдыхали только одним способом. Попробуйте что-то новое!"))
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
            self.items.append(NewsModel(title: "Ваши отдыхи пересекаются", text: "Некоторые из ваших отдыхов пересекаются по времени. Попробуйте уделить внимание планированию своего времени."))
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
            self.items.append(NewsModel(title: "Длинный отдых", text: "Один из ваших отдыхов длиннее 12 часов. Постарайтесь разбивать длинные активности на более мелкие."))
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
            self.items.append(NewsModel(title: "Отличное равномерное распределение времени отдыха!", text: "Ваше время отдыха равномерно распределено по разным видам активности. Продолжайте в том же духе!"))
        } else {
            self.items.append(NewsModel(title: "Нужно более равномерное распределение времени отдыха", text: "Попробуйте распределить свое время отдыха более равномерно между разными видами активности."))
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
            self.items.append(NewsModel(title: "Ваши оценки в среднем ухудшаются после отдыха", text: "Обратите внимание, что ваши оценки самочувствия ухудшаются после отдыха. Попробуйте изменить вид отдыха или его продолжительность."))
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
