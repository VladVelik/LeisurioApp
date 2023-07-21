//
//  ChangePasswordView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 21.07.2023.
//

import SwiftUI

struct ChangePasswordView: View {
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Binding var showingChangePassword: Bool
    let completion: (Bool) -> Void
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                TextFieldStyleView(title: "Old Password", text: $oldPassword, isSecure: true)
                TextFieldStyleView(title: "New Password", text: $newPassword, isSecure: true)
                TextFieldStyleView(title: "Confirm New Password", text: $confirmPassword, isSecure: true)
                Spacer()
                Button(action: {
                    if newPassword.count < 8 {
                        showError = true
                        errorMessage = "New password should be at least 8 characters long."
                    } else if newPassword != confirmPassword {
                        showError = true
                        errorMessage = "New password and confirmation do not match."
                    } else {
                        Task {
                            do {
                                try await viewModel.updatePassword(newPassword: newPassword)
                                showingChangePassword = false
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
            .navigationTitle("Change Password")
            .navigationBarItems(
                leading: Button("Back") {
                    showingChangePassword = false
                }
            )
        }
    }
}
