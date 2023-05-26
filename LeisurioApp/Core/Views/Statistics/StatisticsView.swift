//
//  StatisticsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel = StatisticsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Статистика за неделю")
                    .font(.title)
                    .padding(.bottom, 10)
                
                DatePicker("Выберите начало недели", selection: $viewModel.selectedStartDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding(.bottom, 20)
                    .onChange(of: viewModel.selectedStartDate) { newValue in
                        viewModel.fetchWeeklyRestData()
                    }
                
                if viewModel.isDataLoading {
                    Text("Построение графика...")
                } else {
                    BarChartView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
