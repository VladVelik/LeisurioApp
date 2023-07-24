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
                        
                        Text("\(viewModel.selectedDate, formatter: viewModel.dateFormatter)").font(.largeTitle)
                        
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
                    CreateRestView(mainViewModel: viewModel)
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
            if isFirstLoad {
                Task {
                    try await viewModel.updateData()
                    isFirstLoad = false
                }
            }
        }
    }
}

extension MainView {
    private var updateListOfRests: some View {
        Section {
            List {
                if viewModel.isLoading {
                    HStack {
                        ProgressView()
                            .scaledToFit()
                        Text("  загрузка событий...")
                    }
                    .id(UUID())
                } else if !viewModel.restsForSelectedDate.isEmpty {
                    ForEach(Array(viewModel.sortedRestsForSelectedDate.indices), id: \.self) { sortedIndex in
                        let (_, rest) = viewModel.sortedRestsForSelectedDate[sortedIndex]
                        NavigationLink(destination: RestDetailView(mainViewModel: viewModel, rest: rest, timeFormatter: viewModel.timeFormatter)) {
                            RestView(sortedIndex: sortedIndex, rest: rest, viewModel: viewModel)
                        }
                        .id(rest.restId)
                    }
                    .onDelete { sortedIndex in
                        viewModel.deleteRest(at: sortedIndex)
                    }
                } else {
                    Text("Сегодня событий нет")
                }
            }
            .overlay(
                overlayView:
                    ToastView(toast:
                                Toast(
                                    title: viewModel.toastMessage,
                                    image: viewModel.toastImage),
                              show: $viewModel.showToast
                             ),
                show: $viewModel.showToast
            )
        }
    }
}
