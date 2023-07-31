//
//  MainView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel = MainViewModel()
    @State private var isFirstLoad = true
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    datePickerToggleView()

                    if viewModel.isDatePickerShown {
                        DatePicker(
                            "",
                            selection: $viewModel.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .frame(height: 330)
                    }
                    
                    dateChangeView()
                    
                    Spacer()
                    
                    addLeisureButton()
                    leisureListView()
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
    
    private func datePickerToggleView() -> some View {
        Button(action: {
            viewModel.toggleDatePicker()
        }) {
            Text(
                viewModel.isDatePickerShown
                ? NSLocalizedString("Hide calendar", comment: "")
                : NSLocalizedString("Show calendar", comment: "")
            )
        }
    }
    
    private func dateChangeView() -> some View {
        HStack {
            Button(action: {
                viewModel.changeDate(by: -1)
            }) {
                Image(systemName: "arrow.left")
                    .scaleEffect(1.5)
                    
            }
            
            Text(" \(viewModel.selectedDate, formatter: viewModel.dateFormatter) ")
                .font(.largeTitle)
            
            Button(action: {
                viewModel.changeDate(by: 1)
            }) {
                Image(systemName: "arrow.right")
                    .scaleEffect(1.5)
            }
        }
    }
    
    private func addLeisureButton() -> some View {
        Button(NSLocalizedString("Add leisure", comment: "")) {
            viewModel.toggleRestView()
            viewModel.closeDatePicker()
        }
    }
}

extension MainView {
    private func leisureListView() -> some View {
        Section {
            List {
                if viewModel.isLoading {
                    loadingView()
                } else if !viewModel.restsForSelectedDate.isEmpty {
                    restListItems()
                } else {
                    emptyRestListView()
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

    private func loadingView() -> some View {
        HStack {
            ProgressView()
                .scaledToFit()
            Text(NSLocalizedString("  loading...", comment: ""))
        }
        .id(UUID())
    }

    private func restListItems() -> some View {
        ForEach(Array(viewModel.sortedRestsForSelectedDate.indices), id: \.self) { sortedIndex in
            let (_, rest) = viewModel.sortedRestsForSelectedDate[sortedIndex]
            
            NavigationLink(
                destination:
                    RestDetailView(
                        mainViewModel: viewModel,
                        rest: rest,
                        timeFormatter: viewModel.timeFormatter
                    )
            ) {
                RestView(viewModel: viewModel, sortedIndex: sortedIndex, rest: rest)
            }
            .id(rest.restId)
        }
        .onDelete { sortedIndex in
            viewModel.deleteRest(at: sortedIndex)
        }
    }

    private func emptyRestListView() -> some View {
        Button(action: {
            viewModel.toggleRestView()
            viewModel.closeDatePicker()
        }) {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                    Text(
                        NSLocalizedString(
                            "No events today. Add first one?",
                            comment: "")
                    )
                }
                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
