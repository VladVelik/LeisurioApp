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
                    Text("Домой")
                }
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Статистика")
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

struct ScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
