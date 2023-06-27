//
//  MainView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var isFirstLoad = true
    
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
                            .frame(height: 330)
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
                if isFirstLoad {
                    let id = try await viewModel.fetchUserUid()
                    try await viewModel.getRestsForSelectedDate(userId: id)
                    isFirstLoad = false
                }
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}

extension MainView {
    private var updateListOfRests: some View {
        Section {
            List {
                if viewModel.isLoading {
                    Text("Загрузка событий...")
                } else if !viewModel.restsForSelectedDate.isEmpty {
                    ForEach(Array(viewModel.sortedRestsForSelectedDate.indices), id: \.self) { sortedIndex in
                        let (_, rest) = viewModel.sortedRestsForSelectedDate[sortedIndex]
                        NavigationLink(destination: RestDetailView(viewModel: viewModel, rest: rest, timeFormatter: viewModel.timeFormatter)) {
                            VStack {
                                HStack {
                                    Text("\(sortedIndex + 1)").bold()
                                    Spacer()
                                    Text("\(viewModel.timeFormatter.string(from: rest.startDate)) - \(viewModel.timeFormatter.string(from: rest.endDate))").bold()
                                    Image(systemName: viewModel.getHourglassSymbol(for: rest))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 30)
                                }
                                Spacer()
                                Image(systemName: viewModel.getSymbolName(from: rest.restType) ?? "ellipsis.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                Spacer()
                                HStack {
                                    Text(rest.keyword)
                                    Spacer()
                                }
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                    }
                    .onDelete { sortedIndex in
                        viewModel.deleteRest(at: sortedIndex)
                    }
                } else {
                    Text("Сегодня событий нет")
                }
            }
        }
    }
}
