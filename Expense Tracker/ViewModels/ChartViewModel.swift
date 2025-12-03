//
//  ChartViewModel.swift
//  Expense Tracker
//
//  Created by Janarthanan Kannan on 03/12/25.
//

import SwiftUI
import Combine

class ChartViewModel: ObservableObject {

    @Published var weeklySpending: [WeeklySpending] = [
        .init(day: "Mon", amount: 800),
        .init(day: "Tue", amount: 1200),
        .init(day: "Wed", amount: 1650),
        .init(day: "Thu", amount: 700),
        .init(day: "Fri", amount: 1300),
        .init(day: "Sat", amount: 1800),
        .init(day: "Sun", amount: 1900)
    ]

    @Published var categoryData: [CategoryData] = [
        .init(category: .food, amount: 7500, color: .orange),
        .init(category: .transport, amount: 1200, color: .blue),
        .init(category: .projects, amount: 1600, color: .pink),
        .init(category: .entertainment, amount: 1800, color: .purple)
    ]

    @Published var selectedCategory: ExpenseCategory = .food

    @Published var transactions: [TransactionItem] = [
        .init(title: "Dinner", amount: -89.69, category: .food, categoryIcon: "", isPositive: false, date: .now),
        .init(title: "Fast Food", amount: 120.53, category: .food, categoryIcon: "", isPositive: true, date: .now.addingTimeInterval(-86400))
    ]
}
