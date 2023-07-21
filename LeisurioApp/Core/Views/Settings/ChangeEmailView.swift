//
//  ChangeEmailView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 21.07.2023.
//

import SwiftUI

struct ChangeEmailView: View {
    @State private var newEmail = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Binding var showingChangeEmail: Bool
    let completion: (Bool) -> Void
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                TextFieldStyleView(title: "New Email", text: $newEmail, isSecure: false)
                Spacer()
                Button(action: {
                    if newEmail.count < 1 {
                        showError = true
                        errorMessage = "New user name should be at least 1 characters long."
                    } else {
                        Task {
                            do {
                                try await viewModel.updateEmail(newEmail: newEmail)
                                showingChangeEmail = false
                                completion(true)
                                showError = false
                            } catch {
                                completion(false)
                                showError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                }) {
                    Text("Сохранить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
            }
            .padding()
            .alert(isPresented: $showError) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Change Email")
            .navigationBarItems(
                leading: Button("Back") {
                    showingChangeEmail = false
                }
            )
        }
    }
}
