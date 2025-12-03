//
//  Shimmer.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var move = false

    func body(content: Content) -> some View {
        content
            .overlay(
                shimmerOverlay
                    .mask(content)
            )
    }

    private var shimmerOverlay: some View {
        LinearGradient(
            colors: [.white.opacity(0.1), .white.opacity(0.45), .white.opacity(0.1)],
            startPoint: move ? .topLeading : .bottomTrailing,
            endPoint: move ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                move.toggle()
            }
        }
    }
}

extension View {
    func shimmer(_ active: Bool) -> some View {
        active ? self.redacted(reason: .placeholder).modifier(Shimmer()) as! Self : self
    }
}

