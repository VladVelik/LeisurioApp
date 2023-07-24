//
//  ChangeUserNameView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 21.07.2023.
//

import SwiftUI

struct ChangeUserNameView: View {
    @State private var newUserName = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Binding var showingChangeUserName: Bool
    let completion: (Bool) -> Void
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                TextFieldStyleView(title: NSLocalizedString("New Username", comment: ""), text: $newUserName, isSecure: false)
                Spacer()
                Button(action: {
                    if newUserName.count < 1 {
                        showError = true
                        errorMessage = NSLocalizedString("New Username cannot be empty!", comment: "")
                    } else {
                        Task {
                            do {
                                try await viewModel.updateUserName(newUserName: newUserName)
                                showingChangeUserName = false
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
            .navigationTitle(NSLocalizedString("Change Username", comment: ""))
            .navigationBarItems(
                trailing: Button(NSLocalizedString("Back", comment: "")) {
                    showingChangeUserName = false
                }
            )
        }
    }
}
