//
//  NewsElementView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 14.07.2023.
//

import SwiftUI

struct NewsElementView: View {
    var newsEvent: NewsModel
    
    var body: some View {
        VStack {
            HStack {
                Text(newsEvent.title)
                    .font(.headline)
                    .padding([.top, .leading])
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Text(newsEvent.text)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(5)
                    .padding([.bottom, .leading, .trailing])
                Spacer()
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}
