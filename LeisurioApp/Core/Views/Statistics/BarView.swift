//
//  BarView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 26.05.2023.
//

import SwiftUI
/**
struct BarChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(viewModel.weeklyRestData, id: \.date) { data in
                BarView(
                    value: data.restMinutes,
                    maxValue: viewModel.weeklyRestData.map { $0.restMinutes }.max() ?? 1,
                    label: data.date
                )
            }
        }
    }
}

struct BarView: View {
    var value: Double
    var maxValue: Double
    var label: String
    
    var body: some View {
        let barHeight = value/(maxValue == 0 ? 1 : maxValue) * 200
        
        VStack {
            Text("\(Int(value))")
                .font(.caption)
            Rectangle()
                .fill(Color.blue)
                .frame(width: 30, height: CGFloat(barHeight))
            Text(label)
                .font(.caption)
                .rotationEffect(.degrees(-35))
        }
    }
    
}
*/
