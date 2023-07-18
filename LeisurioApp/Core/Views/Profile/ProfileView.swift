//
//  ProfileView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 25.05.2023.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isImagePickerPresented = false
    @Binding var showSignInView: Bool
    @State private var selectedImage: UIImage? = nil

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
            //List {
                //Text(viewModel.user. ?? "9")
            HStack {
                VStack(alignment: .leading) {
                    if let user = viewModel.user {
                        Text("\(user.userName ?? "User")")
                            .font(.title2)
                        if let email = user.email {
                            Text(email)
                        }
                    }
                }
                Spacer()
                if let photoUrl = viewModel.user?.photoUrl {
                    AsyncImage(url: photoUrl)
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            isImagePickerPresented = true
                        }
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .onTapGesture {
                            isImagePickerPresented = true
                        }
                }
            }
            .padding()
            
            Spacer()
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
        }
        .task {
            try? await viewModel.loadCurrentUser()
            if let image = selectedImage {
                try? await viewModel.updateUserPhotoUrl(newPhoto: image)
            }
        }
    }
}
struct AsyncImage: View {
    @StateObject private var loader: ImageLoader

    init(url: String) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
    }

    var body: some View {
        Image(uiImage: loader.image ?? UIImage())
            .resizable()
            .onAppear { loader.load() }
    }
}
class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: String

    init(url: String) {
        self.url = url
    }

    func load() {
        guard let url = URL(string: url) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }

        task.resume()
    }
}

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if !results.isEmpty {
                results[0].itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    if let uiImage = object as? UIImage {
                        DispatchQueue.main.async {
                            self?.parent.image = uiImage
                        }
                    }
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
