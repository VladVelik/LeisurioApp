//
//  CreateRestView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 28.06.2023.
//

import SwiftUI

struct CreateRestView: View {
    @StateObject var mainViewModel: MainViewModel
    @StateObject var createRestViewModel = CreateRestViewModel()
    
    var body: some View {
        VStack {
            Text("Добавить отдых")
                .font(.headline)
            DatePicker("Начало отдыха:", selection: $createRestViewModel.startTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            DatePicker("Окончание отдыха:", selection: $createRestViewModel.endTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            TextFieldStyleView(title: "Заметка об отдыхе", text: $createRestViewModel.restNote, isSecure: false)
                .padding(.top, 20)
            Text("Выбор категории:")
            VStack {
                HStack {
                    ForEach(mainViewModel.categories.prefix(3), id: \.name) { category in
                        createCategoryButton(category)
                    }
                }
                HStack {
                    ForEach(mainViewModel.categories.suffix(3), id: \.name) { category in
                        createCategoryButton(category)
                    }
                }
            }
            restViewButtons()
        }
        .padding()
        .onAppear {
            createRestViewModel.clearData()
        }
    }
    
    private func restViewButtons() -> some View {
        HStack {
            Button(action: {
                mainViewModel.toggleRestView()
            }) {
                Text("Назад")
            }
            Spacer()
            Button("Далее") {
                let fullStartTime = createRestViewModel.mergeDateAndTime(date: mainViewModel.selectedDate, time: createRestViewModel.startTime)
                let fullEndTime = createRestViewModel.mergeDateAndTime(date: mainViewModel.selectedDate, time: createRestViewModel.endTime)
                Task {
                    try await createRestViewModel.addNewRest(
                        restId: UUID().uuidString,
                        startDate: fullStartTime,
                        endDate: fullEndTime,
                        keyword: createRestViewModel.restNote,
                        restType: createRestViewModel.selectedCategory
                    )
                    try await mainViewModel.updateData()
                }
                mainViewModel.toggleRestView()
            }
            .disabled(createRestViewModel.isIncorrect)
            .foregroundColor((createRestViewModel.isIncorrect) ? .red : .blue)
        }
    }
    
    private func createCategoryButton(_ category: (name: String, imageName: String)) -> some View {
        Button(action: {
            createRestViewModel.selectedCategory = category.name
        }) {
            VStack {
                Image(systemName: category.imageName)
                Text(category.name)
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(createRestViewModel.selectedCategory == category.name ? Color.green : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(10)
        }
    }
}
