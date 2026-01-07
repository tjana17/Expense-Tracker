//
//  ConfirmItem.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 07/01/26.
//

import SwiftUI

// Generic confirm item builder
@ViewBuilder
func confirmItem<Content: View>(icon: String, title: String, @ViewBuilder value: () -> Content) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 12) {
        Image(systemName: icon)
            .foregroundColor(.white.opacity(0.8))
        LabeledContent(title) {
            value()
        }
        .foregroundStyle(.white.opacity(0.7))
        Spacer()
    }
    .padding(10)
    .background(Color.white.opacity(0.04))
    .clipShape(RoundedRectangle(cornerRadius: 10))
}
