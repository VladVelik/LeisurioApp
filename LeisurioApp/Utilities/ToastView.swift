//
//  ToastView.swift
//  LeisurioApp
//
//  Created by Vladislav Sosin on 21.07.2023.
//

import SwiftUI

struct Toast {
    var title: String
    var image: String
}

struct ToastView: View {
    let toast: Toast
    
    @Binding var show: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: toast.image)
                Text(toast.title)
            }
            .font(.headline)
            .padding(.vertical, 10)
            .padding(.horizontal, 30)
            .background(.gray.opacity(0.2), in: Capsule())
        }
        .frame(width: UIScreen.main.bounds.width / 1.25)
        .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
        .padding(.bottom, 20)
        .onTapGesture {
            withAnimation {
                self.show = false
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    self.show = false
                }
            }
        }
    }
}

struct Overlay<T: View>: ViewModifier {
    @Binding var show: Bool
    let overlayView: T
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                overlayView
            }
        }
    }
    
}

extension View {
    func overlay<T: View>(overlayView: T, show: Binding<Bool>) -> some View {
        self.modifier(Overlay(show: show, overlayView: overlayView))
    }
}
