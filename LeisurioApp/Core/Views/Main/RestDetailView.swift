//
//  RestDetailView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 22.06.2023.
//

import SwiftUI

struct RestDetailView: View {
    @StateObject var viewModel: MainViewModel
    let rest: Rest
    let timeFormatter: DateFormatter
    @State private var preRestMood = 3
    @State private var postRestMood = 3
    @State private var finalRestMood = 3

    private var symbolName: String {
        viewModel.getHourglassSymbol(for: rest)
    }
    
    private func getStatusText(from symbolName: String) -> String {
        switch symbolName {
        case "hourglass.bottomhalf.filled":
            return "В ожидании"
        case "hourglass":
            return "В процессе"
        case "hourglass.tophalf.filled":
            return "Завершено"
        default:
            return "Неизвестный статус"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: symbolName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                                .foregroundColor(.blue)
                            Text(getStatusText(from: symbolName))
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        Text("\(timeFormatter.string(from: rest.startDate)) - \(timeFormatter.string(from: rest.endDate))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Тип отдыха: \(rest.restType )")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: viewModel.getSymbolName(from: rest.restType) ?? "ellipsis.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                }
                Text(rest.keyword )
                    .font(.title)
                    .padding(.top, 20)
                
                if symbolName == "hourglass.tophalf.filled" {
                    Divider()
                    Text("Ваше настроение до отдыха:")
                        .font(.headline)
                    HStack {
                        ForEach(1..<6) { index in
                            Button(action: {
                                self.preRestMood = index
                            }) {
                                Text("\(index)")
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(self.preRestMood == index ? Color.blue : Color.clear)
                            .clipShape(Circle())
                        }
                    }

                    Divider()
                    Text("Ваше настроение после отдыха:")
                        .font(.headline)
                    HStack {
                        ForEach(1..<6) { index in
                            Button(action: {
                                self.postRestMood = index
                            }) {
                                Text("\(index)")
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(self.postRestMood == index ? Color.blue : Color.clear)
                            .clipShape(Circle())
                        }
                    }
                    
                    Divider()
                    Text("Насколько вы удовлетворены отдыхом?")
                        .font(.headline)
                    HStack {
                        ForEach(1..<6) { index in
                            Button(action: {
                                self.finalRestMood = index
                            }) {
                                Text("\(index)")
                            }
                            .foregroundColor(.black)
                            .padding()
                            .background(self.finalRestMood == index ? Color.blue : Color.clear)
                            .clipShape(Circle())
                        }
                    }
                }
                Button(action: {
                    Task {
                        try await viewModel.updateRest(
                            restId: rest.restId,
                            startDate: rest.startDate,
                            endDate: rest.endDate,
                            keyword: rest.keyword,
                            restType: rest.restType,
                            preRestMood: preRestMood,
                            postRestMood: postRestMood,
                            finalRestMood: finalRestMood
                        )
                        let id = try await viewModel.fetchUserUid()
                        try await viewModel.getRestsForSelectedDate(userId: id)
                    }
                }) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationBarTitle("Информация об отдыхе", displayMode: .inline)
        }
        .onAppear {
            preRestMood = rest.preRestMood
            postRestMood = rest.postRestMood
            finalRestMood = rest.finalRestMood
        }
    }
}
