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
                .padding([.top, .leading])
            ScrollView {
                Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                    ForEach(StatisticsViewModel.Timeframe.allCases) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing], 20)
                .onChange(of: viewModel.selectedTimeframe) { newValue in
                    viewModel.fetchRestData()
                }
                
                DatePicker("Выберите начало периода", selection: $viewModel.selectedStartDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding([.leading, .trailing, .bottom], 20)
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
                    .padding()
                    
                    Text("Статистика по времени")
                        .font(.title2)
                    
                    PieChart(rawData: viewModel.preparedData)
                        .padding()
                    
                    Text("Статистика по типу отдыха")
                        .font(.title2)
                    
                    PieChart(rawData: viewModel.typesData)
                        .padding()
                }
            }
            .padding(.bottom, 10)
            .onAppear {
                viewModel.onAppear()
            }
        }
    }
}
