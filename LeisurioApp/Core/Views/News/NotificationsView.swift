//
//  NotificationsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 06.07.2023.
//

import SwiftUI

struct Notification: Identifiable {
    var id = UUID()
    var title: String
    var text: String
}

struct NotificationsView: View {
    @State private var notifications = [
        Notification(title: "Уведомление 1", text: "Текст уведомления 1"),
        Notification(title: "Уведомление 2", text: "Текст уведомления 2"),
        // добавьте больше уведомлений здесь, если это необходимо
    ]

    var body: some View {
        VStack {
            if notifications.isEmpty {
                Text("Уведомлений нет")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(notifications) { notification in
                        VStack {
                            Text(notification.title)
                                .font(.headline)
                            Text(notification.text)
                                .font(.subheadline)
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                    .onDelete(perform: delete)
                }
            }
            Spacer()
        }
    }

    private func delete(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
}
