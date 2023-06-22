//
//  MainView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Button(action: {
                        viewModel.toggleDatePicker()
                    }) {
                        Text(viewModel.isDatePickerShown ? "Убрать календарь" : "Показать календарь")
                    }
                    
                    if viewModel.isDatePickerShown {
                        DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    
                    HStack {
                        Button(action: {
                            viewModel.changeDate(by: -1)
                        }) {
                            Image(systemName: "arrow.left")
                        }
                        
                        Text("\(viewModel.selectedDate, formatter: dateFormatter)").font(.largeTitle)
                        
                        Button(action: {
                            viewModel.changeDate(by: 1)
                        }) {
                            Image(systemName: "arrow.right")
                        }
                    }
                    Spacer()
                    Button("Добавить отдых") {
                        viewModel.toggleRestView()
                        viewModel.closeDatePicker()
                    }
                    Spacer()
                    updateListOfRests
                }
                .blur(radius: viewModel.isRestViewShown ? 4 : 0)
                .allowsHitTesting(!viewModel.isRestViewShown)
                
                if viewModel.isRestViewShown {
                    RestView(viewModel: viewModel)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        .padding([.leading, .trailing], 20)
                        .frame(alignment: .center)
                    
                }
            }
            Spacer()
        }
        .onAppear {
            Task {
                let id = try await viewModel.fetchUserUid()
                try await viewModel.getRestsForSelectedDate(userId: id)
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter
    }()
}

extension MainView {
    private var updateListOfRests: some View {
        Section {
            List {
                if !viewModel.restsForSelectedDate.isEmpty {
                    ForEach(viewModel.restsForSelectedDate.sorted(
                        by: { ($0.startDate ?? Date.distantPast) < ($1.startDate ?? Date.distantPast) })) { rest in
                            NavigationLink(destination: RestDetailView(rest: rest, timeFormatter: viewModel.timeFormatter)) {
                                VStack {
                                    Text(rest.keyword ?? "")
                                    Text(" с \(viewModel.timeFormatter.string(from: rest.startDate ?? Date()))")
                                    Text("до  \(viewModel.timeFormatter.string(from: rest.endDate ?? Date())) ")
                                    Text(rest.restType ?? "")
                                }
                                .bold()
                                .frame(height: 140)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                            }
                        }
                        .onDelete { item in
                            viewModel.deleteRest(at: item)
                        }
                } else {
                    Text("Сегодня событий нет")
                }
            }
        }
    }
}

struct RestView: View {
    @ObservedObject var viewModel: MainViewModel
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var categories: [(name: String, imageName: String)] = [
        ("Игры", "gamecontroller.fill"),
        ("Спорт", "sportscourt.fill"),
        ("Хобби", "paintpalette.fill"),
        ("Общение", "message.fill"),
        ("Прогулки", "figure.walk"),
        ("Другое", "ellipsis.circle.fill")
    ]
    
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
                    ForEach(categories.prefix(3), id: \.name) { category in
                        createCategoryButton(category)
                    }
                }
                HStack {
                    ForEach(categories.suffix(3), id: \.name) { category in
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
            .frame(width: 60, height: 60)
            .background(viewModel.selectedCategory == category.name ? Color.green : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(10)
        }
    }
}
