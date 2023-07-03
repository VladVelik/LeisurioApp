//
//  StatisticsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel = StatisticsViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Статистика")
                .fontWeight(.bold)
                .font(.title)
                .padding()
            ScrollView {
                Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                    ForEach(StatisticsViewModel.Timeframe.allCases) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: viewModel.selectedTimeframe) { newValue in
                    viewModel.fetchRestData()
                }
                DatePicker("Выберите начало периода", selection: $viewModel.selectedStartDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding(.bottom, 20)
                    .onChange(of: viewModel.selectedStartDate) { newValue in
                        viewModel.fetchRestData()
                    }
                
                if viewModel.isDataLoading {
                    Text("Построение графиков...")
                } else {
                    Chart(viewModel.preparedData) { day in
                        BarMark(
                            x: .value("Day", day.label),
                            y: .value("Minutes", day.restMinutes)
                        )
                    }
                    .foregroundColor(.red)
                    
                    Text("Статистика по времени")
                        .font(.title)
                        .padding()
                    
                    PieChart(data: viewModel.preparedData)
                        .padding()
                    
                    Text("Статистика по типу отдыха")
                        .font(.title)
                        .padding()
                    
                    PieChart(data: viewModel.typesData)
                        .padding()
                }
                
                Spacer()
            }
            .padding([.leading, .trailing, .bottom], 20)
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
