//
//  SettingsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 16.05.2023.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State private var newUserName: String = ""
    
    @State var showingChangePassword = false
    @State var showingChangeUserName = false
    @State var showingChangeEmail = false
    
    @State private var showDeleteConfirmation = false
    @State private var isDeletingAccount = false
    
    @State var alertItem: AlertItem?
    
    var body: some View {
        ZStack {
            List {
                userNameSection
                
                if viewModel.authProviders.contains(.email) {
                    emailSection
                }
                
                accountSection
            }
            .onAppear {
                viewModel.loadAuthProviders()
                Task {
                    try await viewModel.loadCurrentUser()
                }
            }
            .navigationTitle(NSLocalizedString("Settings", comment: ""))
            .overlay(
                overlayView:
                    ToastView(toast:
                                Toast(
                                    title: viewModel.toastMessage,
                                    image: viewModel.toastImage),
                              show: $viewModel.showToast
                             ),
                show: $viewModel.showToast
            )
            
            if isDeletingAccount {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2)
                    .opacity(isDeletingAccount ? 1 : 0)
            }
        }
        .alert(item: $alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button(NSLocalizedString("Update password", comment: "")) {
                if NetworkMonitor.shared.isConnected {
                    showingChangePassword = true
                } else {
                    alertItem = AlertItem(
                        title: NSLocalizedString("Error", comment: ""),
                        message: NSLocalizedString("No internet connection", comment: ""))
                }
                
            }
            .disabled(isDeletingAccount)
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView(showingChangePassword: $showingChangePassword, completion: { success in
                    if success {
                        self.viewModel.toastMessage = NSLocalizedString("Password updated!", comment: "")
                        self.viewModel.toastImage = "checkmark.square"
                        self.viewModel.showToast = true
                    }
                }, viewModel: viewModel)
            }
            
            Button(NSLocalizedString("Update email", comment: "")) {
                if NetworkMonitor.shared.isConnected {
                    showingChangeEmail = true
                } else {
                    alertItem = AlertItem(
                        title: NSLocalizedString("Error", comment: ""),
                        message: NSLocalizedString("No internet connection", comment: ""))
                }
            }
            .disabled(isDeletingAccount)
            .sheet(isPresented: $showingChangeEmail) {
                ChangeEmailView(showingChangeEmail: $showingChangeEmail, completion: { success in
                    if success {
                        self.viewModel.toastMessage = NSLocalizedString("Email updated!", comment: "")
                        self.viewModel.toastImage = "checkmark.square"
                        self.viewModel.showToast = true
                    }
                }, viewModel: viewModel)
            }
        } header: {
            Text("Email functions")
        }
        
    }
    
    var userNameSection: some View {
        Section {
            Button(NSLocalizedString("Update Username", comment: "")) {
                if NetworkMonitor.shared.isConnected {
                    showingChangeUserName = true
                } else {
                    alertItem = AlertItem(
                        title: NSLocalizedString("Error", comment: ""),
                        message: NSLocalizedString("No internet connection", comment: ""))
                }
            }
            .disabled(isDeletingAccount)
            .sheet(isPresented: $showingChangeUserName) {
                ChangeUserNameView(showingChangeUserName: $showingChangeUserName, completion: { success in
                    if success {
                        self.viewModel.toastMessage = NSLocalizedString("Username updated!", comment: "")
                        self.viewModel.toastImage = "checkmark.square"
                        self.viewModel.showToast = true
                    }
                }, viewModel: viewModel)
            }
        } header: {
            Text(NSLocalizedString("Username", comment: ""))
        }
    }
    
    private var accountSection: some View {
        Section {
            Button(NSLocalizedString("Log out", comment: "")) {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            .disabled(isDeletingAccount)
            
            Button(role: .destructive) {
                if NetworkMonitor.shared.isConnected {
                    showDeleteConfirmation = true
                } else {
                    alertItem = AlertItem(
                        title: NSLocalizedString("Error", comment: ""),
                        message: NSLocalizedString("No internet connection", comment: ""))
                }
                
            } label: {
                Text(NSLocalizedString("Delete account", comment: ""))
            }
            .disabled(isDeletingAccount)
            .alert(NSLocalizedString("Confirm delete", comment: ""), isPresented: $showDeleteConfirmation, actions: {
                Button(NSLocalizedString("Delete", comment: ""), role: .destructive) {
                    Task {
                        isDeletingAccount = true
                        do {
                            try await viewModel.deleteAccount()
                            showSignInView = true
                        } catch {
                            print(error)
                        }
                        isDeletingAccount = false
                    }
                }
                Button(NSLocalizedString("Cancel", comment: ""), role: .cancel) {}
            }, message: {
                Text(NSLocalizedString("Are you sure you want to delete your account?", comment: ""))
            })
        } header: {
            Text(NSLocalizedString("Account", comment: ""))
        }
    }
}
