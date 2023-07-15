//
//  NotificationsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 06.07.2023.
//

import SwiftUI

struct NotificationsView: View {
    var body: some View {
        ListView(viewModel: NotificationsViewModel()) { notification in
            NewsElementView(newsEvent: notification)
        }
    }
}
