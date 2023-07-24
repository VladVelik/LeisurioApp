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
            Text(NSLocalizedString("Statistics", comment: ""))
                .fontWeight(.bold)
                .font(.title)
                .padding([.top, .leading])
            ScrollView {
                Picker("Timeframe", selection: $viewModel.selectedTimeframe) {
                    ForEach(StatisticsViewModel.Timeframe.allCases) { timeframe in
                        Text(timeframe.displayName).tag(timeframe)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.leading, .trailing], 20)
                .onChange(of: viewModel.selectedTimeframe) { newValue in
                    viewModel.fetchRestData()
                }
                
                DatePicker(NSLocalizedString("Choose period start", comment: ""), selection: $viewModel.selectedStartDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding([.leading, .trailing, .bottom], 20)
                    .onChange(of: viewModel.selectedStartDate) { newValue in
                        viewModel.fetchRestData()
                    }
                
                if viewModel.isDataLoading {
                    HStack {
                        ProgressView()
                            .scaledToFit()
                        Text(NSLocalizedString("  diagramming...", comment: ""))
                    }
                    .id(UUID())
                } else {
                    Text(NSLocalizedString("Daily statistics", comment: ""))
                        .font(.title2)
                    
                    Chart(viewModel.preparedData) { day in
                        BarMark(
                            x: .value("Day", day.label),
                            y: .value("Minutes", day.restMinutes)
                        )
                    }
                    .foregroundColor(.red)
                    .padding()
                    
                    Text(NSLocalizedString("Time statistics", comment: ""))
                        .font(.title2)
                    
                    PieChart(rawData: viewModel.preparedData)
                        .padding()
                    
                    Text(NSLocalizedString("Leisure statistics", comment: ""))
                        .font(.title2)
                    
                    PieChart(rawData: viewModel.typesData)
                        .padding()
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
            
            Spacer()
        }
    }
}
