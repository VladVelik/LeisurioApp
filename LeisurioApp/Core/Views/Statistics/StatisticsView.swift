//
//  StatisticsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI
import Charts

struct ChartInfo {
    let title: String
    let explanation: String
}

struct StatisticsView: View {
    @ObservedObject var viewModel = StatisticsViewModel()
    
    @State private var showChartExplanation: [Bool] = [false, false, false]
    
    let chartInfo = [
        ChartInfo(
            title: NSLocalizedString("Daily statistics", comment: ""),
            explanation: NSLocalizedString("The data displayed here indicates the amount of time, in minutes, scheduled for leisures per day (for a week view) and over a three-day period (for a month view).", comment: "")
        ),
        ChartInfo(
            title: NSLocalizedString("Time statistics", comment: ""),
            explanation: NSLocalizedString("This pie chart illustrates how planned time for leisures is distributed across specific periods. In the context of a weekly overview, each sector of the chart represents a single day, and for a monthly overview, it represents a three-day span. The size of each sector is proportional to the total number of minutes scheduled for leisures during the corresponding period, allowing for an easy visual comparison of how one's time planning is distributed across different periods.", comment: "")
        ),
        ChartInfo(
            title: NSLocalizedString("Leisure statistics", comment: ""),
            explanation: NSLocalizedString("This pie chart illustrates the distribution of scheduled leisure time by types. Each sector of the chart corresponds to a distinct type of leisure, and the size of each sector is proportional to the total amount of minutes planned for the respective type. Thus, it allows for an easy comparison of how much time was allocated to different types of leisures.", comment: "")
        )
    ]
    
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
                    statisticsTitleView(title: chartInfo[0].title, explanation: chartInfo[0].explanation, showExplanation: $showChartExplanation[0])
                    
                    Chart(viewModel.preparedData) { day in
                        BarMark(
                            x: .value("Day", day.label),
                            y: .value("Minutes", day.restMinutes)
                        )
                    }
                    .foregroundColor(.red)
                    .padding()
                    
                    statisticsTitleView(title: chartInfo[1].title, explanation: chartInfo[1].explanation, showExplanation: $showChartExplanation[1])
                    
                    PieChart(rawData: viewModel.preparedData)
                        .padding()
                    
                    statisticsTitleView(title: chartInfo[2].title, explanation: chartInfo[2].explanation, showExplanation: $showChartExplanation[2])
                    
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
    
    private func statisticsTitleView(title: String, explanation: String, showExplanation: Binding<Bool>) -> some View {
        HStack {
            Text(NSLocalizedString(title, comment: ""))
                .font(.title2)
            Spacer()
            Button(action: {
                showExplanation.wrappedValue = true
            }) {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
                    .scaleEffect(1.5)
            }
            .alert(isPresented: showExplanation) {
                Alert(title: Text(title),
                      message: Text(explanation),
                      dismissButton: .default(Text(NSLocalizedString("Got it", comment: ""))))
            }
        }
        .padding()
    }
}
