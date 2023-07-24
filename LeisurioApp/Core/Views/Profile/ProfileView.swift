//
//  ProfileView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    @State var selectedItem: PhotosPickerItem? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Профиль")
                    .fontWeight(.bold)
                    .font(.title)
                
                Spacer()
                NavigationLink(destination: SettingsView(showSignInView: $showSignInView)) {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                }
            }
            .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    if let user = viewModel.user {
                        Text("\(user.userName ?? "User")")
                            .font(.title2)
                            .imageScale(.large)
                        if let email = user.email {
                            Text(email)
                        }
                    }
                }
                Spacer()
                
                ZStack {
                    let defaultImage = Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    if let photoUrl = viewModel.user?.photoUrl, !photoUrl.isEmpty {
                        AsyncImage(url: URL(string: photoUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(50)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 100, height: 100)
                        }
                    } else {
                        defaultImage
                    }
                    
                    if !viewModel.isLoadingImage {
                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Rectangle()
                                .frame(width: 100, height: 100)
                                .opacity(0.0)
                        }
                    }
                }

            }
            .padding()
            
            HStack {
                drawRoundedRectangleView(
                    title: "Дата регистрации",
                    text: viewModel.user?.dateCreated?.formatted(.dateTime.year().month().day()) ?? ""
                )
                
                drawRoundedRectangleView(
                    title: "Количество активностей",
                    text: "\(viewModel.user?.rests.count ?? 0)"
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
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
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .onChange(of: selectedItem, perform: { newValue in
            viewModel.imageChanging(newValue: newValue)
        })
    }
    
    private func drawRoundedRectangleView(title: String, text: String) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(.black, lineWidth: 1)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray.opacity(0.2))
            )
            .frame(height: 100)
            .overlay(
                VStack {
                    Text(title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .padding(.bottom, 10)
                    Text(text)
                        .multilineTextAlignment(.center)
                }
                .padding()
            )

    }
    
}
