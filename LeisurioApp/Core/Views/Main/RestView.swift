//
//  RestView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 23.06.2023.
//

import SwiftUI

struct RestView: View {
    @StateObject var viewModel: MainViewModel
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Добавить отдых")
                .font(.headline)
            DatePicker("Начало отдыха:", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            DatePicker("Окончание отдыха:", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            TextField("Заметка об отдыхе", text: $viewModel.restNote)
                .padding()
            Text("Выбор категории:")
            VStack {
                HStack {
                    ForEach(viewModel.categories.prefix(3), id: \.name) { category in
                        createCategoryButton(category)
                    }
                }
                HStack {
                    ForEach(viewModel.categories.suffix(3), id: \.name) { category in
                        createCategoryButton(category)
                    }
                }
            }
            HStack {
                Button(action: {
                    viewModel.toggleRestView()
                }) {
                    Text("Назад")
                }
                Spacer()
                Button("Далее") {
                    let fullStartTime = viewModel.mergeDateAndTime(date: viewModel.selectedDate, time: viewModel.startTime)
                    let fullEndTime = viewModel.mergeDateAndTime(date: viewModel.selectedDate, time: viewModel.endTime)
                    Task {
                        try await viewModel.addNewRest(
                            restId: UUID().uuidString,
                            startDate: fullStartTime,
                            endDate: fullEndTime,
                            keyword: viewModel.restNote,
                            restType: viewModel.selectedCategory
                        )
                    }
                    viewModel.toggleRestView()
                }
                .disabled(viewModel.isIncorrect)
                .foregroundColor((viewModel.isIncorrect) ? .red : .blue)
            }
        }
        .padding()
        .onAppear {
            viewModel.clearData()
        }
    }
    
    private func createCategoryButton(_ category: (name: String, imageName: String)) -> some View {
        Button(action: {
            viewModel.selectedCategory = category.name
        }) {
            VStack {
                Image(systemName: category.imageName)
                Text(category.name)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(viewModel.selectedCategory == category.name ? Color.green : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(10)
        }
    }
}
