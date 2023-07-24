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
            Text(NSLocalizedString("Add leisure", comment: ""))
                .font(.headline)
            DatePicker(NSLocalizedString("Leisure start:", comment: ""), selection: $createRestViewModel.startTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            DatePicker(NSLocalizedString("Leisure end:", comment: ""), selection: $createRestViewModel.endTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(DefaultDatePickerStyle())
            TextFieldStyleView(title: NSLocalizedString("Leisure note", comment: ""), text: $createRestViewModel.restNote, isSecure: false)
                .padding(.top, 20)
            Text(NSLocalizedString("Category selection", comment: ""))
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
                Text(NSLocalizedString("Back", comment: ""))
            }
            Spacer()
            Button(NSLocalizedString("Next", comment: "")) {
                let fullStartTime = createRestViewModel.mergeDateAndTime(date: mainViewModel.selectedDate, time: createRestViewModel.startTime)
                let fullEndTime = createRestViewModel.mergeDateAndTime(date: mainViewModel.selectedDate, time: createRestViewModel.endTime)
                Task {
                    let newRest = try await createRestViewModel.addNewRest(
                        restId: UUID().uuidString,
                        startDate: fullStartTime,
                        endDate: fullEndTime,
                        keyword: createRestViewModel.restNote,
                        restType: createRestViewModel.selectedCategory
                    )
                    
                    DispatchQueue.main.async {
                        self.mainViewModel.restsForSelectedDate.append(newRest)
                        self.mainViewModel.toastMessage = NSLocalizedString("Leisure added!", comment: "")
                        self.mainViewModel.toastImage = "checkmark.square"
                        self.mainViewModel.showToast = true
                    }
                    
                    mainViewModel.setRestTimers(for: [newRest])
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
                    .scaleEffect(1.5)
                Text("")
                Text(NSLocalizedString("\(category.name)", comment: ""))
                    .font(.caption)
            }
            .frame(width: 90, height: 90)
            .background(createRestViewModel.selectedCategory == category.name ? Color.green : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding(2)
        }
    }
}
