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
    
    @State var alertItem: AlertItem?
    
    var body: some View {
        ZStack {
            VStack {
                Text(isSignIn ? NSLocalizedString("Welcome back!", comment: "") : NSLocalizedString("Welcome!", comment: ""))
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                    .padding()
                NavigationLink {
                    SignInEmailView(showSignInView: $showSignInView, isSignIn: $isSignIn)
                } label: {
                    ImageButton(action: {}, imageName: "envelope", text: isSignIn ? NSLocalizedString("Sign In with Email", comment: "") : NSLocalizedString("Sign Up with Email", comment: ""), isButton: false)
                }
                
                ImageButton(action: {
                    Task {
                        do {
                            try await viewModel.signWithGoogle(isSignIn: isSignIn)
                            showSignInView = false
                        } catch let error as LocalizedError {
                            alertItem = AlertItem(
                                title: NSLocalizedString("Error", comment: ""),
                                message: NSLocalizedString(error.localizedDescription, comment: ""))
                        }
                    }
                }, imageName: "google", text: isSignIn ? NSLocalizedString("Sign In with Google", comment: "") : NSLocalizedString("Sign Up with Google", comment: ""), systemImage: false)
                
                
                ImageButton(action: {
                    Task {
                        do {
                            try await viewModel.signWithApple(isSignIn: isSignIn)
                            showSignInView = false
                        } catch let error as LocalizedError {
                            alertItem = AlertItem(
                                title: NSLocalizedString("Error", comment: ""),
                                message: NSLocalizedString(error.localizedDescription, comment: ""))
                        }
                    }
                }, imageName: "applelogo", text: isSignIn ? NSLocalizedString("Sign In with Apple", comment: "") : NSLocalizedString("Sign Up with Apple", comment: ""))
                
                HStack {
                    Spacer()
                    Text(isSignIn ? NSLocalizedString("Don't have an account?", comment: "") : NSLocalizedString("Already have an account?", comment: ""))
                        .bold()
                    Button(isSignIn ? NSLocalizedString("Sign Up", comment: "") : NSLocalizedString("Sign In", comment: "")) {
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
            .alert(item: $alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
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
