//
//  RecommendationsView.swift
//  LeisurioApp
//
//  Created by Sosin Vladislav on 06.07.2023.
//

import SwiftUI

struct RecommendationsView: View {
    var body: some View {
        ListView(viewModel: RecommendationsViewModel()) { recommendation in
            NewsElementView(newsEvent: recommendation)
        }
    }
}
