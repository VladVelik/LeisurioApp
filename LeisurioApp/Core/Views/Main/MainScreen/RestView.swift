//
//  RestView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 28.06.2023.
//

import SwiftUI

struct RestView: View {
    let sortedIndex: Int
    let rest: Rest
    let viewModel: MainViewModel

    var body: some View {
        VStack {
            HStack {
                Text("\(sortedIndex + 1)").bold()
                Spacer()
                Text("\(viewModel.timeFormatter.string(from: rest.startDate)) - \(viewModel.timeFormatter.string(from: rest.endDate))").bold()
                Image(systemName: viewModel.getHourglassSymbol(for: rest))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
            }
            Spacer()
            Image(systemName: viewModel.getSymbolName(from: rest.restType) ?? "ellipsis.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
            Spacer()
            HStack {
                Text(rest.keyword)
                Spacer()
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.green)
        .cornerRadius(10)
    }
}
