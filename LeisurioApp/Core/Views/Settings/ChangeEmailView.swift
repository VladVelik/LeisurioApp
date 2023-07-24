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
                TextFieldStyleView(title: NSLocalizedString("New Email", comment: ""), text: $newEmail, isSecure: false)
                Spacer()
                Button(action: {
                    if newEmail.count < 1 {
                        showError = true
                        errorMessage = NSLocalizedString("Email cannot be empty!", comment: "")
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
            .navigationTitle(NSLocalizedString("Change Email", comment: ""))
            .navigationBarItems(
                trailing: Button(NSLocalizedString("Back", comment: "")) {
                    showingChangeEmail = false
                }
            )
        }
    }
}
