//
//  MainViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 26.05.2023.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    private var cancellationToken: CancellationToken?
    
    @Published var selectedDate: Date = Date() {
        didSet {
            cancellationToken?.cancel()
            let task = Task {
                getRestsForSelectedDate(userId: userId) { result in
                    switch result {
                    case .success(_):
                        print("Successfully got rests for selected date.")
                        // Обработайте успешный результат здесь
                    case .failure(let error):
                        print("Failed to get rests for selected date: \(error)")
                        // Обработайте ошибку здесь
                    }
                }
            }

            cancellationToken = CancellationToken {
                task.cancel()
            }
        }
    }
    
    @Published var isDatePickerShown: Bool = false
    @Published var isRestViewShown: Bool = false
    @Published var restsForSelectedDate = [Rest]()
    @Published var isLoading = false
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastImage: String = ""
   
    let categories: [(name: String, imageName: String)] = [
        ("Игры", "gamecontroller.fill"),
        ("Спорт", "sportscourt.fill"),
        ("Хобби", "paintpalette.fill"),
        ("Общение", "message.fill"),
        ("Прогулки", "figure.walk"),
        ("Другое", "ellipsis.circle.fill")
    ]
    
    var userId: String = ""
    private var restTimers: [Timer] = []
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        
        return formatter
    }()
    
    func fetchUserUid() async throws -> String {
        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            userId = authDataResult.uid
            return userId
        } catch {
            throw error
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
    
    func updateData(completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                let id = try await fetchUserUid()
                getRestsForSelectedDate(userId: id) { result in
                    switch result {
                    case .success(_):
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getRestsForSelectedDate(userId: String, completion: @escaping (Result<[Rest], Error>) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        let task = Task {
            do {
                let rests = try await UserManager.shared.getRestsForUserOnDate(userId: userId, date: selectedDate)
                if Task.isCancelled { return }

                self.clearRestTimers()
                self.setRestTimers(for: rests)

                DispatchQueue.main.async {
                    self.restsForSelectedDate = rests
                    self.isLoading = false
                }
                completion(.success(rests))
            } catch {
                print("Failed to get rests for selected date: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                completion(.failure(error))
            }
        }
        
        cancellationToken = CancellationToken {
            task.cancel()
        }
    }

    
    func updateRest(_ rest: Rest) async {
        DispatchQueue.main.async {
            if let index = self.restsForSelectedDate.firstIndex(where: { $0.restId == rest.restId }) {
                self.restsForSelectedDate[index] = rest
            }
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

    func deleteRest(at offsets: IndexSet, completion: @escaping (Result<Void, Error>) -> Void) {
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
                completion(.success(()))
            } catch {
                print("Failed to delete rest: \(error)")
                completion(.failure(error))
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
    
    private func clearRestTimers() {
        for timer in restTimers {
            timer.invalidate()
        }
        restTimers.removeAll()
    }
    
    func setRestTimers(for rests: [Rest]) {
        for rest in rests {
            let startTimer = Timer(fire: rest.startDate, interval: 0, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            let endTimer = Timer(fire: rest.endDate, interval: 0, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            RunLoop.main.add(startTimer, forMode: .default)
            RunLoop.main.add(endTimer, forMode: .default)
            
            DispatchQueue.main.async {
                self.restTimers.append(contentsOf: [startTimer, endTimer])
            }
        }
    }
}
