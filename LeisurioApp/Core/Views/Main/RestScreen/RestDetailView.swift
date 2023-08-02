//
//  RestDetailView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 22.06.2023.
//

import SwiftUI

struct RestDetailView: View {
    @StateObject var mainViewModel: MainViewModel
    @StateObject var restDetailViewModel: RestDetailViewModel

    @State var alertItem: AlertItem?
    
    private var symbolName: String {
        restDetailViewModel.getHourglassSymbol(for: restDetailViewModel.rest)
    }
    
    init(mainViewModel: MainViewModel, rest: Rest, timeFormatter: DateFormatter) {
        self._mainViewModel = StateObject(wrappedValue: mainViewModel)
        let storedNotificationOption = UserDefaults.standard.string(forKey: "notificationOption_\(rest.restId)") ?? "Don`t notify"
        self._restDetailViewModel = StateObject(wrappedValue: RestDetailViewModel(rest: rest, timeFormatter: timeFormatter, storedNotificationOption: storedNotificationOption))
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
                Text("\(restDetailViewModel.timeFormatter.string(from: restDetailViewModel.rest.startDate)) - \(restDetailViewModel.timeFormatter.string(from: restDetailViewModel.rest.endDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(NSLocalizedString("Leisure type: ", comment: "")) \(NSLocalizedString("\(restDetailViewModel.rest.restType)", comment: ""))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if !restDetailViewModel.isPastEvent() {
                    Text(NSLocalizedString("\(restDetailViewModel.selectedNotification)", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Image(systemName: mainViewModel.getSymbolName(from: restDetailViewModel.rest.restType) ?? "ellipsis.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                mainRestInfoView()
                
                Text(restDetailViewModel.rest.keyword)
                    .font(.title)
                    .padding(.top, 15)
                
                if symbolName == "hourglass.tophalf.filled" {
                    moodSelectionView(for: NSLocalizedString("Your mood before leisure:", comment: ""), mood: $restDetailViewModel.preRestMood)
                    moodSelectionView(for: NSLocalizedString("Your mood after leisure:", comment: ""), mood: $restDetailViewModel.postRestMood)
                    moodSelectionView(for: NSLocalizedString("Rate the leisure:", comment: ""), mood: $restDetailViewModel.finalRestMood)
                    
                    Button(action: {
                        if NetworkMonitor.shared.isConnected {
                            Task {
                                if let updatedRest = await restDetailViewModel.updateRest(
                                    rest: restDetailViewModel.rest,
                                    preRestMood: restDetailViewModel.preRestMood,
                                    postRestMood: restDetailViewModel.postRestMood,
                                    finalRestMood: restDetailViewModel.finalRestMood
                                ) {
                                    await mainViewModel.updateRest(updatedRest)
                                }
                            }
                        } else {
                            alertItem = AlertItem(
                                title: NSLocalizedString("Error", comment: ""),
                                message: NSLocalizedString("No internet connection", comment: ""))
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
            .alert(item: $alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarTitle(NSLocalizedString("Leisure information", comment: ""), displayMode: .inline)
            .navigationBarItems(trailing:
                                    Group {
                if !restDetailViewModel.isPastEvent() {
                    Button(action: {
                        restDetailViewModel.showNotificationOptions = true
                    }) {
                        Image(systemName: restDetailViewModel.selectedNotification == "Don`t notify" ? "bell.slash" : "bell")
                    }
                    .actionSheet(isPresented: $restDetailViewModel.showNotificationOptions) {
                        ActionSheet(title: Text(NSLocalizedString("Notification", comment: "")), message: Text(NSLocalizedString("Choose a notification time", comment: "")), buttons: restDetailViewModel.notificationOptions.map { option in
                                .default(Text(NSLocalizedString(option, comment: ""))) {
                                    restDetailViewModel.selectedNotification = option
                                    if restDetailViewModel.selectedNotification != "Don`t notify" {
                                        restDetailViewModel.scheduleNotificationForRest(restDetailViewModel.rest, with: restDetailViewModel.selectedNotification)
                                        
                                        Task {
                                            await mainViewModel.updateRest(restDetailViewModel.rest)
                                        }
                                    }
                                }
                        } + [.cancel(Text(NSLocalizedString("Cancel", comment: "")))])
                    }
                }
            }
            )
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
            restDetailViewModel.restMoodInit()
        }
    }
}
