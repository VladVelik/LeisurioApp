//
//  StatisticsViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

class StatisticsViewModel: ObservableObject {
    @Published var restData: [(date: String, restMinutes: Double)] = []
    @Published var restTypeData: [(type: String, restMinutes: Double)] = []
    
    @Published var isDataLoading: Bool = false
    @Published var selectedStartDate = Date()
    @Published private var isFirstLoad = true
    @Published var selectedTimeframe: Timeframe = .week

    var userId: String = ""
    private var currentTask: Task<Void, Never>?

    var preparedData: [PieChartData] {
        get {
            var preparedData: [PieChartData] = []
            switch selectedTimeframe {
            case .week:
                preparedData = restData.map { PieChartData(id: UUID(), label: $0.date, restMinutes: $0.restMinutes) }
            case .month:
                for i in stride(from: 0, to: restData.count, by: 3) {
                    let slice = restData[i..<min(i+3, restData.count)]
                    let totalMinutes = slice.reduce(0) { $0 + $1.restMinutes }
                    let startDay = slice.first?.date ?? ""
                    let endDay = slice.last?.date ?? ""
                    let dateInterval = "\(startDay)-\(endDay)"
                    preparedData.append(PieChartData(id: UUID(), label: dateInterval, restMinutes: totalMinutes))
                }
            }
            return preparedData
        }
    }
    
    var typesData: [PieChartData] {
        get {
            var typesData: [PieChartData] = []
            
            typesData = restTypeData.map {
                PieChartData(id: UUID(), label: $0.type, restMinutes: $0.restMinutes)
            }
            
            return typesData
        }
    }

    enum Timeframe: String, CaseIterable, Identifiable {
        case week = "week"
        case month = "month"
        
        var id: String {
            self.rawValue
        }
        
        var durationInDays: Int {
            self == .week ? 7 : 30
        }
        
        var displayName: String {
            switch self {
            case .week:
                return NSLocalizedString("week", comment: "")
            case .month:
                return NSLocalizedString("month", comment: "")
            }
        }
    }


    private let calendar = Calendar.current
    
    private let weekTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter
    }()
    
    private let monthTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()

    func onAppear() {
        if isFirstLoad {
            fetchRestData()
            isFirstLoad = false
        }
    }

    func fetchRestData() {
        currentTask?.cancel()
        currentTask = Task {
            do {
                let id = try await fetchUserUid()
                try await loadRestData(forUserId: id, startingFrom: selectedStartDate, forDays: selectedTimeframe.durationInDays)
            } catch {
                if error is CancellationError {
                    print("Data fetching task was cancelled")
                } else {
                    print("Error: \(error)")
                }
            }
        }
    }

    private func loadRestData(forUserId userId: String, startingFrom date: Date, forDays days: Int) async throws {
        DispatchQueue.main.async {
            self.isDataLoading = true
        }
        var dataByTime: [(date: String, restMinutes: Double)] = []
        var dataByType: [String: Double] = [:]
        
        var dateComponents = DateComponents()
        for day in 0..<days {
            dateComponents.day = day
            guard let currentDate = calendar.date(byAdding: dateComponents, to: date) else { continue }
            do {
                try Task.checkCancellation()
                let rests = try await UserManager.shared.getRestsForUserOnDate(userId: userId, date: currentDate)
                let totalRestMinutes = rests.reduce(0) { (result, rest) in
                    let start = rest.startDate
                    let end = rest.endDate
                    let restDuration = end.timeIntervalSince(start) / 60
                    
                    let restType = rest.restType
                    if let currentMinutes = dataByType[restType] {
                        dataByType[restType] = currentMinutes + restDuration
                    } else {
                        dataByType[restType] = restDuration
                    }
                    
                    return result + restDuration
                }
                
                let date = (days == 7) ? weekTimeFormatter.string(from: currentDate) : monthTimeFormatter.string(from: currentDate)
                dataByTime.append((date: date, restMinutes: totalRestMinutes))
            } catch {
                print("Failed to fetch rests for date \(currentDate): \(error)")
            }
        }
        try Task.checkCancellation()
        let dataByTypeArray = dataByType.map { (type: $0.key, restMinutes: $0.value) }
        await updateData(dataByTime: dataByTime, dataByType: dataByTypeArray)
    }
    
    @MainActor
    private func updateData(
        dataByTime: [(date: String, restMinutes: Double)],
        dataByType: [(type: String, restMinutes: Double)]
    ) {
        self.restData = dataByTime
        self.restTypeData = dataByType
        self.isDataLoading = false
    }

    func fetchUserUid() async throws -> String {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        userId = authDataResult.uid
        return userId
    }
}
