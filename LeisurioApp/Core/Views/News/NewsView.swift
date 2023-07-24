//
//  NewsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 27.06.2023.
//

import SwiftUI

struct NewsView: View {
    @State private var currentPage = 0

    var body: some View {
        VStack {
            Picker("", selection: $currentPage) {
                Text(NSLocalizedString("Notifications", comment: "")).tag(0)
                Text(NSLocalizedString("Recommendations", comment: "")).tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    NotificationsView()
                        .frame(width: geometry.size.width)
                    RecommendationsView()
                        .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(self.currentPage) * geometry.size.width, y: 0)
                .animation(
                    .easeInOut(duration: 2),
                    value: 1.0
                )
            }
        }
    }
}
