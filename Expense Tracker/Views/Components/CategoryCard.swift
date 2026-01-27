//
//  CategoryCard.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 24/01/26.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(colorForIcon(category.iconName.isEmpty ? "folder" : category.iconName).opacity(0.18))
                    .frame(width: 60, height: 60)
                Image(systemName: category.iconName.isEmpty ? "folder" : category.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(colorForIcon(category.iconName.isEmpty ? "folder" : category.iconName))
            }

            Text(category.name)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .contentShape(RoundedRectangle(cornerRadius: 14))
    }
}
