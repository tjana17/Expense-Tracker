//
//  CategorySpending.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 30/11/25.
//

import Foundation
import SwiftUI

// Aggregation of spending for a Firestore-backed category
struct CategorySpending: Identifiable {
    let id = UUID()
    let categoryId: String
    let categoryName: String
    let categoryIcon: String
    let amount: Double
}

// Reused as-is for chart x/y pairs
struct WeeklySpending: Identifiable {
    let id = UUID()
    let day: String
    let amount: Double
}

// Generic chart data used by donut and summary.
// Note: categoryName is used for display; color is derived locally.
struct CategoryData: Identifiable {
    let id = UUID()
    let categoryId: String
    let categoryName: String
    let amount: Double
    let color: Color
}

// Deterministic color palette for categories (fallback if no color stored in Firestore)
extension Color {
    static func colorForCategoryKey(_ key: String) -> Color {
        // Simple hash-based palette
        let palette: [Color] = [.orange, .teal, .purple, .blue, .pink, .green, .red, .yellow, .indigo, .mint, .brown, .cyan]
        let idx = abs(key.hashValue) % palette.count
        return palette[idx]
    }
}

