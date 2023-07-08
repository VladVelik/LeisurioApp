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
                    Text("Главная")
                }
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Статистика")
                }
            NewsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Новости")
                }
            NavigationView {
                ProfileView(showSignInView: $showSignInView)
            }
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Профиль")
                }
        }
    }
}
