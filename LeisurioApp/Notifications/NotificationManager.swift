//
//  NotificationManager.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 26.05.2023.
//

import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestNotificationPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
            } else {
                print("Permission denied")
            }
        }
    }
    
    func scheduleNotification(restId: String, startDate: Date, notificationOffset: TimeInterval, note: String) {
        let content = UNMutableNotificationContent()
        content.title = "Leisurio"
        
        let minutesUntilEvent = notificationOffset / 60
        
        let timeUntilEventString: String
        
        timeUntilEventString = String(format: "%.0f", minutesUntilEvent)
        
        content.body = String(format: NSLocalizedString("Don't forget about %@! This leisure will start in just %@ minutes!", comment: ""), note, timeUntilEventString)
        content.sound = UNNotificationSound.default
        
        let notificationDate = startDate.addingTimeInterval(-notificationOffset)
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: restId, content: content, trigger: trigger)
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

    
    func saveNotification(restId: String, startDate: Date, notificationOffset: TimeInterval, note: String) {
        let notification = ["restId": restId, "startDate": startDate, "notificationOffset": notificationOffset, "note": note] as [String : Any]
        let currentNotifications = getSavedNotifications()
        var newNotifications = currentNotifications
        newNotifications.append(notification)
        
        let defaults = UserDefaults.standard
        defaults.set(newNotifications, forKey: "notifications")
    }
    
    func getSavedNotifications() -> [[String: Any]] {
        let defaults = UserDefaults.standard
        if let savedNotifications = defaults.object(forKey: "notifications") as? [[String: Any]] {
            return savedNotifications
        }
        return []
    }
    
    func deleteNotification(with restId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [restId])
        
        let notifications = getSavedNotifications()
        let filteredNotifications = notifications.filter { $0["restId"] as? String != restId }
        
        let defaults = UserDefaults.standard
        defaults.set(filteredNotifications, forKey: "notifications")
    }
    
    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "notifications")
    }
}
