//
//  ListView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 14.07.2023.
//

import SwiftUI

protocol ListViewModel: ObservableObject {
    associatedtype Item: Identifiable
    var items: [Item] { get }
    var text: String { get }
    func refresh()
    func delete(at offsets: IndexSet)
}

struct ListView<ViewModel: ObservableObject & ListViewModel, Content: View>: View {
    @ObservedObject var viewModel: ViewModel
    var content: (ViewModel.Item) -> Content

    var body: some View {
        VStack {
            if viewModel.items.isEmpty {
                ScrollView {
                    
                    HStack {
                        if (!viewModel.text.contains(NSLocalizedString("yet", comment: ""))) {
                            ProgressView()
                        }
                        Text("\(viewModel.text)")
                    }
                    .id(UUID())
                }
                .refreshable {
                    Task {
                        viewModel.refresh()
                    }
                }
            } else {
                List {
                    ForEach(viewModel.items, id: \.id) { item in
                        content(item)
                    }
                    .onDelete(perform: viewModel.delete)
                }
                .refreshable {
                    Task {
                        viewModel.refresh()
                    }
                }
            }
            Spacer()
        }
    }
}
