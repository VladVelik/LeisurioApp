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
        ZStack {
            VStack {
                ScrollView {
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
                    }
                    Spacer()
                    updateListOfRests
                }
                .blur(radius: viewModel.isRestViewShown ? 4 : 0)
                .allowsHitTesting(!viewModel.isRestViewShown)
                
                if viewModel.isRestViewShown {
                    RestView(viewModel: viewModel)
                        .frame(width: 350, height: 250)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                        .position(x: UIScreen.main.bounds.width / 2, y: 0)
                    
                }
            }
            .onAppear {
                Task {
                    let id = try await viewModel.fetchUserUid()
                    try await viewModel.getRestsForSelectedDate(userId: id)
                }
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
            if !viewModel.restsForSelectedDate.isEmpty {
                ForEach(viewModel.restsForSelectedDate) { rest in
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.green)
                            .frame(height: 40)
                            .overlay(
                                HStack {
                                    Text(rest.keyword ?? "")
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(" с \(viewModel.timeFormatter.string(from: rest.startDate ?? Date()))")
                                        .foregroundColor(.white)
                                        .bold()
                                    Text("до  \(viewModel.timeFormatter.string(from: rest.endDate ?? Date()))")
                                        .foregroundColor(.white)
                                        .bold()
                                }
                            )
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            } else {
                Text("Сегодня событий нет")
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
    
    var body: some View {
        VStack {
            Button(action: {
                viewModel.toggleRestView()
            }) {
                Text("Назад")
            }
            Spacer()
            Text("Добавить отдых")
                .font(.headline)
            
            DatePicker("Начало отдыха", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            
            DatePicker("Окончание отдыха", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            
            TextField("Заметка об отдыхе", text: $viewModel.restNote)
                .padding()
            
            Button("Далее") {
                let fullStartTime = viewModel.mergeDateAndTime(date: viewModel.selectedDate, time: viewModel.startTime)
                let fullEndTime = viewModel.mergeDateAndTime(date: viewModel.selectedDate, time: viewModel.endTime)
                Task {
                    try await viewModel.addNewRest(
                        restId: UUID().uuidString,
                        startDate: fullStartTime,
                        endDate: fullEndTime,
                        keyword: viewModel.restNote
                    )
                }
                viewModel.toggleRestView()
            }
            .disabled(viewModel.isIncorrect)
            .foregroundColor((viewModel.isIncorrect) ? .red : .blue)
        }
        .padding()
    }
}
