//
//  CancellationToken.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 31.07.2023.
//

import Foundation

struct CancellationToken {
    private let onCancel: () -> Void
    
    init(_ onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }
    
    func cancel() {
        onCancel()
    }
}
