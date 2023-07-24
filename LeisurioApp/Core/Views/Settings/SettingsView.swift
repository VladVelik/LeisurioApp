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
    
    var body: some View {
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
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button(NSLocalizedString("Update password", comment: "")) {
                showingChangePassword = true
            }
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
                showingChangeEmail = true
            }
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
                showingChangeUserName = true
            }
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
            
            Button(role: .destructive) {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text(NSLocalizedString("Delete account", comment: ""))
            }
        } header: {
            Text(NSLocalizedString("Account", comment: ""))
        }
    }
}
