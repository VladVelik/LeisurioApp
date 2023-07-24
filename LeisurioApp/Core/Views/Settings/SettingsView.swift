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
        .navigationTitle("Settings")
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
            Button("Update Password") {
                showingChangePassword = true
            }
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView(showingChangePassword: $showingChangePassword, completion: { success in
                    if success {
                        self.viewModel.toastMessage = "Password updated!"
                        self.viewModel.toastImage = "checkmark.square"
                        self.viewModel.showToast = true
                    }
                }, viewModel: viewModel)
            }
            
            Button("Update email") {
                showingChangeEmail = true
            }
            .sheet(isPresented: $showingChangeEmail) {
                ChangeEmailView(showingChangeEmail: $showingChangeEmail, completion: { success in
                    if success {
                        self.viewModel.toastMessage = "Email updated!"
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
            Button("Update Username") {
                showingChangeUserName = true
            }
            .sheet(isPresented: $showingChangeUserName) {
                ChangeUserNameView(showingChangeUserName: $showingChangeUserName, completion: { success in
                    if success {
                        self.viewModel.toastMessage = "Username updated!"
                        self.viewModel.toastImage = "checkmark.square"
                        self.viewModel.showToast = true
                    }
                }, viewModel: viewModel)
            }
        } header: {
            Text("Username")
        }
    }
    
    private var accountSection: some View {
        Section {
            Button("Log out") {
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
                Text("Delete account")
            }
        } header: {
            Text("Account")
        }
    }
}
