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
                Text("\(NSLocalizedString("Leisure type: ", comment: "")) \(NSLocalizedString("\(rest.restType)", comment: ""))")
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
                    moodSelectionView(for: NSLocalizedString("Your mood before leisure:", comment: ""), mood: $restDetailViewModel.preRestMood)
                    moodSelectionView(for: NSLocalizedString("Your mood after leisure:", comment: ""), mood: $restDetailViewModel.postRestMood)
                    moodSelectionView(for: NSLocalizedString("Rate the leisure:", comment: ""), mood: $restDetailViewModel.finalRestMood)
                    
                    Button(action: {
                        Task {
                            if let updatedRest = await restDetailViewModel.updateRest(
                                rest: rest,
                                preRestMood: restDetailViewModel.preRestMood,
                                postRestMood: restDetailViewModel.postRestMood,
                                finalRestMood: restDetailViewModel.finalRestMood
                            ) {
                                await mainViewModel.updateRest(updatedRest)
                            }
                        }
                    }) {
                        Text(NSLocalizedString("Save", comment: ""))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .navigationBarTitle(NSLocalizedString("Leisure information", comment: ""), displayMode: .inline)
        }
        .overlay(
            overlayView:
                ToastView(toast:
                            Toast(
                                title: restDetailViewModel.toastMessage,
                                image: restDetailViewModel.toastImage),
                          show: $restDetailViewModel.showToast
                         ),
            show: $restDetailViewModel.showToast
        )
        .onAppear {
            restDetailViewModel.preRestMood = rest.preRestMood
            restDetailViewModel.postRestMood = rest.postRestMood
            restDetailViewModel.finalRestMood = rest.finalRestMood
        }
    }
}
