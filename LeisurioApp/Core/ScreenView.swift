//
//  ScreenView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

struct ScreenView: View {
    @Binding var showSignInView: Bool
    
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(NSLocalizedString("Home", comment: ""))
                }
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text(NSLocalizedString("Statistics", comment: ""))
                }
            NewsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text(NSLocalizedString("News", comment: ""))
                }
            NavigationView {
                ProfileView(showSignInView: $showSignInView)
            }
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text(NSLocalizedString("Profile", comment: ""))
                }
        }
    }
}
