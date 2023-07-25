//
//  RestDetailViewModel.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 28.06.2023.
//

import SwiftUI

final class RestDetailViewModel: ObservableObject {
    @Published var preRestMood = 3
    @Published var postRestMood = 3
    @Published var finalRestMood = 3
    @Published var isSaved = false
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var toastImage: String = ""
    
    @Published var showNotificationOptions = false
     
    func getStatusText(from symbolName: String) -> String {
        switch symbolName {
        case "hourglass.bottomhalf.filled":
            return NSLocalizedString("Waiting", comment: "")
        case "hourglass":
            return NSLocalizedString("In progress", comment: "")
        case "hourglass.tophalf.filled":
            return NSLocalizedString("Finished", comment: "")
        default:
            return "Undefined"
        }
    }
    
    var notificationOptions: [String] {
        return [
            "Notify in 15 minutes",
            "Notify in 30 minutes",
            "Notify in 1 hour",
            "Don`t notify"
        ]
    }
    
    let rest: Rest
    let timeFormatter: DateFormatter
    
    @Published var selectedNotification: String {
        didSet {
            UserDefaults.standard.set(selectedNotification, forKey: "notificationOption_\(rest.restId)")
        }
    }
    
    init(rest: Rest, timeFormatter: DateFormatter, storedNotificationOption: String) {
        self.rest = rest
        self.timeFormatter = timeFormatter
        self._selectedNotification = Published(initialValue: storedNotificationOption)
    }
    
    func setupRest(_ rest: Rest, with storedNotificationOption: String) {
        if storedNotificationOption != "Don`t notify" {
            scheduleNotificationForRest(rest, with: storedNotificationOption)
        }
    }
    
    func scheduleNotificationForRest(_ rest: Rest, with notificationOption: String) {
        var notificationOffset: TimeInterval
        
        NotificationManager.shared.deleteNotification(with: rest.restId)
        
        switch notificationOption {
        case "Notify in 15 minutes":
            notificationOffset = 15 * 60
        case "Notify in 30 minutes":
            notificationOffset = 30 * 60
        case "Notify in 1 hour":
            notificationOffset = 60 * 60
        default:
            NotificationManager.shared.deleteNotification(with: rest.restId)
            return
        }
        
        NotificationManager.shared.scheduleNotification(restId: rest.restId, startDate: rest.startDate, notificationOffset: notificationOffset, note: rest.keyword)
        NotificationManager.shared.saveNotification(restId: rest.restId, startDate: rest.startDate, notificationOffset: notificationOffset, note: rest.keyword)
    }
    
    func updateMood(for index: Int, mood: Binding<Int>) {
        mood.wrappedValue = index
    }
    
    func updateRest(rest: Rest, preRestMood: Int, postRestMood: Int, finalRestMood: Int) async -> Rest? {
        do {
            let updatedRest = try await updateRest(
                restId: rest.restId,
                startDate: rest.startDate,
                endDate: rest.endDate,
                keyword: rest.keyword,
                restType: rest.restType,
                preRestMood: preRestMood,
                postRestMood: postRestMood,
                finalRestMood: finalRestMood,
                isRated: true
            )

            DispatchQueue.main.async {
                self.toastMessage = NSLocalizedString("Rate saved!", comment: "")
                self.toastImage = "checkmark.square"
                self.showToast = true
            }

            return updatedRest
        } catch {
            print("Failed to update rest: \(error)")
            return nil
        }
    }

    
    func toggleIsSaved() {
        isSaved = false
    }
    
    func updateRest(
        restId: String,
        startDate: Date,
        endDate: Date,
        keyword: String,
        restType: String,
        preRestMood: Int,
        postRestMood: Int,
        finalRestMood: Int,
        isRated: Bool
    ) async throws -> Rest {
        let updatedRest = Rest(
            restId: restId,
            startDate: startDate,
            endDate: endDate,
            keyword: keyword,
            restType: restType,
            preRestMood: preRestMood,
            postRestMood: postRestMood,
            finalRestMood: finalRestMood,
            isRated: isRated
        )

        do {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try await UserManager.shared.updateRestForUser(userId: authDataResult.uid, rest: updatedRest)
            print("Rest updated successfully")
        } catch {
            print("Failed to update rest: \(error)")
        }
        
        return updatedRest
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
    
    func restMoodInit() {
        preRestMood = rest.preRestMood
        postRestMood = rest.postRestMood
        finalRestMood = rest.finalRestMood
    }
    
    func isPastEvent() -> Bool {
        let now = Date()
        if rest.endDate < now {
            return true
        } else {
            return false
        }
    }
}
