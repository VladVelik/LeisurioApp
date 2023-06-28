//
//  RestDetailView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 22.06.2023.
//

import SwiftUI

struct RestDetailView: View {
    @StateObject var mainViewModel: MainViewModel
    @StateObject var restDetailViewModel = RestDetailViewModel()
    
    let rest: Rest
    let timeFormatter: DateFormatter
    
    private var symbolName: String {
        restDetailViewModel.getHourglassSymbol(for: rest)
    }
    
    private func moodSelectionView(for title: String, mood: Binding<Int>) -> some View {
        VStack {
            Divider()
            Text(title)
                .font(.headline)
            HStack {
                ForEach(1..<6) { index in
                    Button(action: {
                        restDetailViewModel.updateMood(for: index, mood: mood)
                    }) {
                        Text("\(index)")
                    }
                    .foregroundColor(.black)
                    .padding()
                    .background(mood.wrappedValue == index ? Color.blue : Color.clear)
                    .clipShape(Circle())
                }
            }
        }
    }
    
    private func mainRestInfoView() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: symbolName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .foregroundColor(.blue)
                    Text(restDetailViewModel.getStatusText(from: symbolName))
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Text("\(timeFormatter.string(from: rest.startDate)) - \(timeFormatter.string(from: rest.endDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Тип отдыха: \(rest.restType)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: mainViewModel.getSymbolName(from: rest.restType) ?? "ellipsis.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                mainRestInfoView()
                
                Text(rest.keyword)
                    .font(.title)
                    .padding(.top, 15)
                
                if symbolName == "hourglass.tophalf.filled" {
                    moodSelectionView(for: "Ваше настроение до отдыха:", mood: $restDetailViewModel.preRestMood)
                    moodSelectionView(for: "Ваше настроение после отдыха:", mood: $restDetailViewModel.postRestMood)
                    moodSelectionView(for: "Насколько вы удовлетворены отдыхом?", mood: $restDetailViewModel.finalRestMood)
                    
                    Button(action: {
                        Task {
                            await restDetailViewModel.updateRest(
                                rest: rest,
                                preRestMood: restDetailViewModel.preRestMood,
                                postRestMood: restDetailViewModel.postRestMood,
                                finalRestMood: restDetailViewModel.finalRestMood
                            )
                        }
                    }) {
                        Text(restDetailViewModel.isSaved ? "Сохранено" : "Сохранить")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(restDetailViewModel.isSaved)
                }
            }
            .padding()
            .navigationBarTitle("Информация об отдыхе", displayMode: .inline)
            .onDisappear {
                if restDetailViewModel.isSaved {
                    Task {
                        try await mainViewModel.updateData()
                    }
                }
                restDetailViewModel.toggleIsSaved()
            }
        }
        .onAppear {
            restDetailViewModel.preRestMood = rest.preRestMood
            restDetailViewModel.postRestMood = rest.postRestMood
            restDetailViewModel.finalRestMood = rest.finalRestMood
        }
    }
}
