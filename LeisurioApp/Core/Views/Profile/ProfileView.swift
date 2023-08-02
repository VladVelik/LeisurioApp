//
//  ProfileView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(NSLocalizedString("Profile", comment: ""))
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
                                .font(.body)
                                .minimumScaleFactor(0.4)
                                .lineLimit(1)
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
                    
                    if !viewModel.isLoadingImage && NetworkMonitor.shared.isConnected {
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images, photoLibrary: .shared()) {
                            Rectangle()
                                .frame(width: 100, height: 100)
                                .opacity(0.0)
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 20)
            
            HStack {
                drawRoundedRectangleView(
                    title: NSLocalizedString("Registration date", comment: ""),
                    text: viewModel.user?.dateCreated?.formatted(.dateTime.year().month().day()) ?? ""
                )
                
                drawRoundedRectangleView(
                    title: NSLocalizedString("Number of leisures", comment: ""),
                    text: "\(viewModel.user?.rests.count ?? 0)"
                )
            }
            .padding(.horizontal)
            
            HStack {
                drawRoundedRectangleView(
                    title: NSLocalizedString("Next leisure", comment: ""),
                    text: viewModel.nearestRest?.keyword
                    ?? NSLocalizedString("No upcoming leisures", comment: "")
                )

                drawRoundedRectangleView(
                    title: NSLocalizedString("Total rest time today", comment: ""),
                    text: "\(Int((viewModel.todayRestDuration ?? 0) / 60)) \(NSLocalizedString("minutes", comment: ""))"
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
            print("fetch")
            try? await viewModel.loadCurrentUser()
        }
        .onChange(of: viewModel.selectedItem, perform: { newValue in
            if NetworkMonitor.shared.isConnected {
                viewModel.imageChanging(newValue: newValue)
            }
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
                        .font(.body)
                        .minimumScaleFactor(scaleFactor(for: text))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                }
                .padding()
            )
    }
    
    private func scaleFactor(for text: String) -> CGFloat {
        let length = text.count
        
        if length <= 12 {
            return 1.0
        } else if length <= 15 {
            return 0.9
        } else {
            return 0.7
        }
    }
}
