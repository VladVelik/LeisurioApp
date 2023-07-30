//
//  AuthenticationView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 16.05.2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showSignInEmailView = false
    @Binding var showSignInView: Bool
    
    @State private var isSignIn = true
    
    @State private var showErrorAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack {
            VStack {
                Text(isSignIn ? "Welcome back!" : "Welcome!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .padding()
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView, isSignIn: $isSignIn)
                } label: {
                    ImageButton(action: {}, imageName: "envelope", text: isSignIn ? "Sign In with Mail" : "Sign Up with Mail", isButton: false)
                }
                
                ImageButton(action: {
                    Task {
                        do {
                            try await viewModel.signWithGoogle(isSignIn: isSignIn)
                            showSignInView = false
                        } catch {
                            if let userError = error as? GoogleError {
                                switch userError {
                                case .accountAlreadyExists:
                                    alertTitle = "Account Error"
                                    alertMessage = "An account with this email already exists."
                                case .noAccountExists:
                                    alertTitle = "Account Error"
                                    alertMessage = "No account exists with this email."
                                }
                                showErrorAlert = true
                            }
                        }
                    }
                }, imageName: "google", text: isSignIn ? "Sign In with Google" : "Sign Up with Google", systemImage: false)
                
                
                ImageButton(action: {
                    print("apple")
                }, imageName: "applelogo", text: isSignIn ? "Sign In with Apple" : "Sign Up with Apple")
                
                HStack {
                    Spacer()
                    Text(isSignIn ? "Don't have an account?" : "Already have an account?")
                        .bold()
                    Button(isSignIn ? "Sign Up" : "Sign In") {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isSignIn.toggle()
                        }
                    }
                    Spacer()
                }
                .scaleEffect(0.9)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .background(
                Image("background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .offset(x: -UIScreen.main.bounds.width / 10)
                    .opacity(0.3)
            )
            
        }
    }
}
