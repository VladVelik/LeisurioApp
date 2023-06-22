//
//  RestDetailView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 22.06.2023.
//

import SwiftUI

struct RestDetailView: View {
    let rest: Rest
    let timeFormatter: DateFormatter
    
    var body: some View {
        VStack {
            Text("Заметка: \(rest.keyword ?? "")")
            Text("Начало: \(timeFormatter.string(from: rest.startDate ?? Date()))")
            Text("Конец: \(timeFormatter.string(from: rest.endDate ?? Date()))")
            Text("Тип отдыха: \(rest.restType ?? "")")
        }
        .padding()
        .navigationBarTitle("Информация об отдыхе", displayMode: .inline)
    }
}
