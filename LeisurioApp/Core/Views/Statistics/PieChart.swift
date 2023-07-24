//
//  PieChart.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 03.07.2023.
//

import SwiftUI

struct PieChartData: Identifiable {
    var id: UUID
    var label: String
    var restMinutes: Double
}

struct PieChart: View {
    let rawData: [PieChartData]
        var data: [PieChartData] {
            PieChart.arrangeData(rawData)
        }
    
    private let colors: [Color] = [
        .red,
        .green,
        .blue,
        .orange,
        .purple,
        .yellow,
        .brown,
        .gray,
        .indigo,
        .mint
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(data.enumerated().map({ $0 }), id: \.offset) { index, _ in
                    let startAngle = self.startAngle(for: index)
                    let endAngle = self.endAngle(for: index)
                    Path { path in
                        path.move(to: geometry.size.center)
                        path.addArc(center: geometry.size.center, radius: geometry.size.radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                    }
                    .fill(self.color(for: index, startAngle: startAngle, endAngle: endAngle))
                }

                ForEach(data.enumerated().map({ $0 }), id: \.offset) { index, _ in
                    let startAngle = self.startAngle(for: index)
                    let endAngle = self.endAngle(for: index)
                    if data[index].restMinutes > 0 {
                        Text(NSLocalizedString("\(data[index].label)", comment: ""))
                            .position(
                                x: geometry.size.center.x + geometry.size.radius * 0.8 * cos(startAngle.radians + (endAngle.radians - startAngle.radians)/2),
                                      
                                y: geometry.size.center.y + geometry.size.radius * 0.8 * sin(startAngle.radians + (endAngle.radians - startAngle.radians)/2)
                            )
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    private static func arrangeData(_ data: [PieChartData]) -> [PieChartData] {
        let sortedData = data.sorted { $0.restMinutes > $1.restMinutes }
        var arrangedData: [PieChartData] = []
        var index = 0
        
        while index < sortedData.count / 2 {
            arrangedData.append(sortedData[index])
            arrangedData.append(sortedData[sortedData.count - 1 - index])
            index += 1
        }
        
        if sortedData.count % 2 != 0 {
            arrangedData.append(sortedData[index])
        }
        
        return arrangedData
    }

    private func startAngle(for index: Int) -> Angle {
        if index == 0 {
            return Angle(degrees: 0)
        }
        let totalValue = data.map { $0.restMinutes }.reduce(0, +)
        let degrees = data[0..<index].map { $0.restMinutes }.reduce(0, +) / totalValue * 360
        return Angle(degrees: degrees)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let totalValue = data.map { $0.restMinutes }.reduce(0, +)
        let degrees = data[0...index].map { $0.restMinutes }.reduce(0, +) / totalValue * 360
        return Angle(degrees: degrees)
    }
    
    private func color(for index: Int, startAngle: Angle, endAngle: Angle) -> Color {
        return colors[index % colors.count]
    }
}

extension CGSize {
    var center: CGPoint { return CGPoint(x: width / 2, y: height / 2) }
    var radius: CGFloat { return min(width, height) / 2 }
}
