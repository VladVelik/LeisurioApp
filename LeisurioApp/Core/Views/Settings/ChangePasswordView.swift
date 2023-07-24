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
//                Text(NSLocalizedString("Password", comment: ""))
//                    .lineLimit(2)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .font(.title)
//                    .bold()
//                Text("")
                TextFieldStyleView(title: NSLocalizedString("Old password", comment: ""), text: $oldPassword, isSecure: true)
                TextFieldStyleView(title: NSLocalizedString("New password", comment: ""), text: $newPassword, isSecure: true)
                TextFieldStyleView(title: NSLocalizedString("Confirm new password", comment: ""), text: $confirmPassword, isSecure: true)
                Spacer()
                Button(action: {
                    if newPassword.count < 8 {
                        showError = true
                        errorMessage = NSLocalizedString("New password should be at least 8 characters!", comment: "")
                    } else if newPassword != confirmPassword {
                        showError = true
                        errorMessage = NSLocalizedString("New password and confirmation do not match.", comment: "")
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
                    Text(NSLocalizedString("Save", comment: ""))
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
                Alert(title: Text(NSLocalizedString("Error", comment: "")), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationTitle(NSLocalizedString("Update password", comment: ""))
            .navigationBarItems(
                trailing: Button(NSLocalizedString("Back", comment: "")) {
                    showingChangePassword = false
                }
            )
        }
    }
}
